from flask import Flask, request, jsonify
from flask_cors import CORS
import tensorflow as tf
import joblib
import numpy as np
import requests
import json
import re

app=Flask(__name__)
CORS(app)

model=tf.keras.models.load_model('career_predictor.h5')
vectorizer=joblib.load('tfidf_vectorizer.pkl')
encoder=joblib.load('label_encoder.pkl')

GEMINI_API_KEY = "AIzaSyCeuSo9eeORz7V-rdOr_wgJEoNklHLq1Ro" 
GEMINI_URL = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={GEMINI_API_KEY}"

def extract_json(text):
    try:
        json_match = re.search(r'\{.*\}', text, re.DOTALL)
        if json_match:
            return json_match.group(0)
        else:
            raise ValueError("No JSON object found in the response.")
    except Exception as e:
        raise ValueError(f"JSON extraction failed: {e}")

@app.route('/')
def home():
    return "Career Prediction API is working"
    

@app.route('/predict',methods=["POST"])
def predict():
    data=request.get_json()
    skills = data.get("skills","")
    education = data.get("education","")
    interests=data.get("interests","")
    workExp= data.get("experience","") 

    if not skills and not education and not interests:
        return jsonify({"error": "Skills,education and interest data required"}), 400
    
    #predicting career only using ML model
    #combine all data
    input_combined=f"{skills}{education}{interests}{workExp}"
    #vectorize input
    input_vector= vectorizer.transform([input_combined]).toarray()
    #make prediction
    prediction=model.predict(input_vector)
    label_prediction=np.argmax(prediction, axis=1)
    #convert numeric prediction
    career_prediction=encoder.inverse_transform(label_prediction)[0]
    
    #use the predicton in prompt given to gemini model
    prompt = f"""
    Generate a career roadmap for someone pursuing {career_prediction}.
    User Background:
    - Education: {education}
    - Work Experience: {workExp}
    - Existing Skills: {skills}
    Please avoid suggesting steps that cover skills the user already possesses. Instead, build on their current background to suggest next-level skills, projects, and learning resources to help them grow into the {career_prediction} role.
    Return the output strictly in the following JSON format:
    {{
      "steps": [
        {{
          "title": "Step Title",
          "skills": ["Skill 1", "Skill 2"],
          "projects": ["Project 1", "Project 2"],
          "resources": ["https://example.com"]
        }}
      ]
    }}
    Do not include any extra commentary, just return pure JSON.
    """
    body = {
        "contents": [
            {
                "parts": [{"text": prompt}]
            }
        ]
    }
    headers = {"Content-Type": "application/json"}
    
    try:
        response = requests.post(GEMINI_URL, headers=headers, data=json.dumps(body))
        if response.status_code == 200:
            content = response.json()
            raw_text = content['candidates'][0]['content']['parts'][0]['text']
            cleaned_json = extract_json(raw_text)
            roadmap = json.loads(cleaned_json)

            return jsonify({
                "career_prediction": career_prediction,
                "roadmap": roadmap
            })
        else:
            return jsonify({"error": f"Gemini API failed: {response.status_code}", "details": response.text}), 500
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    



if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)

