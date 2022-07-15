import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:merchant_app/global/global.dart';
import 'package:merchant_app/mainScreens/home_screen.dart';
import 'package:merchant_app/widgets/custom_text_field.dart';
import 'package:merchant_app/widgets/error_dialog.dart';
import 'package:merchant_app/widgets/loading_dialog.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:image_picker/image_picker.dart';
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
  TextEditingController locationController = TextEditingController();
  TextEditingController storeNameController = TextEditingController();

  // XFile? imageXFile;
  // final ImagePicker _picker = ImagePicker();

  Position? position;
  List<Placemark>? placeMarks;

  String sellerImageUrl = "";
  String completeAddress = "";


  // Future<void> _getImage() async
  // {
  //   imageXFile = await _picker.pickImage(source: ImageSource.gallery);
  //   setState(() {
  //     imageXFile;
  //   });
  // }
  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

  }
  getCurrentLocation() async
  { _determinePosition();
    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high    );

    position = newPosition;

    placeMarks = await placemarkFromCoordinates(
      position!.latitude,
      position!.longitude,
    );
    print(placeMarks);

    Placemark pMark = placeMarks![0];

    completeAddress = '${pMark.street}, ${pMark.name}, ${pMark.subThoroughfare}, ${pMark.thoroughfare}, ${pMark.subLocality}, ${pMark.locality}, ${pMark.subAdministrativeArea},${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';

    locationController.text = completeAddress;
  }

  Future<void> formValidation() async
  {


      if(passwordController.text == confirmPasswordController.text)
      {
        if(confirmPasswordController.text.isNotEmpty && emailController.text.isNotEmpty && nameController.text.isNotEmpty && phoneController.text.isNotEmpty && locationController.text.isNotEmpty && storeNameController.text.isNotEmpty)
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

          // String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          // fStorage.Reference reference = fStorage.FirebaseStorage.instance.ref().child("sellers").child(fileName);
          // fStorage.UploadTask uploadTask = reference.putFile(File(imageXFile!.path));
          // fStorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
          // await taskSnapshot.ref.getDownloadURL().then((url) {
          //   sellerImageUrl = url;
          //
            //save info to firestore
            authenticateMerchantAndSignUp();
          // });
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


  void authenticateMerchantAndSignUp() async
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
    FirebaseFirestore.instance.collection("merchants").doc(currentUser.uid).set({
      "merchantUID": currentUser.uid,
      "storeName" : storeNameController.text.trim(),
      "merchantEmail": currentUser.email,
      "merchantName": nameController.text.trim(),
      //"sellerAvatarUrl": sellerImageUrl,
      "phone": phoneController.text.trim(),
      "address": completeAddress,
      "status": "approved",
      "earnings": 0.0,
      "lat": position!.latitude,
      "lng": position!.longitude,
    });

    //save data locally
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("email", currentUser.email.toString());
    await sharedPreferences!.setString("phone", phoneController.text.trim());
    await sharedPreferences!.setString("name", nameController.text.trim());
    await sharedPreferences!.setString("storeName", storeNameController.text.trim());
    await sharedPreferences!.setString("address",completeAddress.trim());

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
                    controller: storeNameController,
                    hintText: "Store Name",
                    isObsecre: false,
                    keyboard: TextInputType.name,
                  ),
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
                  CustomTextField(
                    data: Icons.my_location,
                    controller: locationController,
                    hintText: "Cafe/Restaurant Address",
                    isObsecre: false,
                    enabled: false,
                  ),
                  Container(
                    width: 400,
                    height: 40,
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      label: const Text(
                        "Get my Current Location",
                        style: TextStyle(color: Colors.white),
                      ),
                      icon: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      onPressed: ()
                      {print("clicked");
                        getCurrentLocation();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
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
