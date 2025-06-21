import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';


//pick image for profile picture from gallery
pickImage(ImageSource source)async{
  final ImagePicker _imagePicker=ImagePicker();
 XFile? _file=await _imagePicker.pickImage(source: source);

 if(_file!=null){
  return await _file.readAsBytes();
 }
}

showSnackBar(String content,BuildContext context){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    )
  );
}
class Utils{

  void toastMessage(String message){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey.withOpacity(0.8),
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

}