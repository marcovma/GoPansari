import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:consumers_app/global/global.dart';
import 'package:consumers_app/mainScreens/home_screen.dart';
import 'package:consumers_app/widgets/custom_text_field.dart';
import 'package:consumers_app/widgets/error_dialog.dart';
import 'package:consumers_app/widgets/loading_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:shared_preferences/shared_preferences.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  // XFile? imageXFile;
  // final ImagePicker _picker = ImagePicker();







  Future<void> formValidation() async
  {


      if(passwordController.text == confirmPasswordController.text)
      {
        if(confirmPasswordController.text.isNotEmpty && emailController.text.isNotEmpty && nameController.text.isNotEmpty && phoneController.text.isNotEmpty)
        {
          //start uploading image
          showDialog(
            context: context,
            builder: (c)
            {
              return LoadingDialog(
                message: "Registering Account",
              );
            }
          );
            authenticateConsumerAndSignUp();
        }
        else
        {
          showDialog(
              context: context,
              builder: (c)
              {
                return ErrorDialog(
                  message: "Please write the complete required info for Registration.",
                );
              }
          );
        }
      }
      else
      {
        showDialog(
            context: context,
            builder: (c)
            {
              return ErrorDialog(
                message: "Password do not match.",
              );
            }
        );
      }
    }


  void authenticateConsumerAndSignUp() async
  {
    User? currentUser;

    await firebaseAuth.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    ).then((auth) {
      currentUser = auth.user;
    }).catchError((error){
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c)
          {
            return ErrorDialog(
              message: error.message.toString(),
            );
          }
      );
    });

    if(currentUser != null)
    {
      saveDataToFirestore(currentUser!).then((value) {
        Navigator.pop(context);
        //send user to homePage
        Route newRoute = MaterialPageRoute(builder: (c) => HomeScreen());
        Navigator.pushReplacement(context, newRoute);
      });
    }
  }

  Future saveDataToFirestore(User currentUser) async
  {
    FirebaseFirestore.instance.collection("consumers").doc(currentUser.uid).set({
      "consumerUid ": currentUser.uid,
      "consumerEmail": currentUser.email,
      "consumerName": nameController.text.trim(),
      //"sellerAvatarUrl": sellerImageUrl,
      "phone": phoneController.text.trim(),
      "status": "approved",
      "savings": 0.0,

    });

    //save data locally
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("email", currentUser.email.toString());
    await sharedPreferences!.setString("phone", phoneController.text.trim());
    await sharedPreferences!.setString("name", nameController.text.trim());

   // await sharedPreferences!.setString("photoUrl", sellerImageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 10,),
            Form(
              key: _formKey,
              child: Column(
                children: [

                  CustomTextField(
                    data: Icons.person,
                    controller: nameController,
                    hintText: "Name",
                    keyboard: TextInputType.name,
                    isObsecre: false,
                  ),
                  CustomTextField(
                    data: Icons.email,
                    controller: emailController,
                    hintText: "Email",
                    keyboard: TextInputType.emailAddress,
                    isObsecre: false,
                  ),
                  CustomTextField(
                    data: Icons.lock,
                    controller: passwordController,
                    hintText: "Password",
                    isObsecre: true,
                    keyboard: TextInputType.visiblePassword,
                  ),
                  CustomTextField(
                    data: Icons.lock,
                    controller: confirmPasswordController,
                    hintText: "Confirm Password",
                    keyboard: TextInputType.visiblePassword,
                    isObsecre: true,
                  ),
                  CustomTextField(
                    data: Icons.phone,
                    controller: phoneController,
                    hintText: "Phone",
                    keyboard: TextInputType.phone,
                    isObsecre: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30,),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.cyan,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              ),
              onPressed: ()
              {
                formValidation();
              },
              child: const Text(
                "Sign Up",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
              ),
            ),
            const SizedBox(height: 30,),
          ],
        ),
      ),
    );
  }
}
