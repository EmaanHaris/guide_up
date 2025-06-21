/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onDocumentUpdated}=require("firebase-functions/v2/firestore");
const {initializeApp}=require("firebase-admin/app");
const {getFirestore}=require("firebase-admin/firestore");
const axios=require("axios");//to make http requests to flask

initializeApp();
const db = getFirestore();

//function triggers when profile is changed
exports.sendProfile=onDocumentUpdated("Mentees/{id}",async (change)=>{
    const before=change.before.data(); 
    const after=change.after.data();   
    const userId=change.params.id;

    //check for changes done in skills,education or interests fields
    const skillsChange=JSON.stringify(before.skills) !== JSON.stringify(after.skills);
    const eduChange=before.education !== after.education;
    

    if(!skillsChange && !eduChange){
        console.log("No relevant profile updates.");
        return;
    }
    const profileData = {
        skills: after.skills || [],
        education: after.education || "",
    };
})


// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
