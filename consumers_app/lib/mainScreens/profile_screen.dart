import 'package:flutter/material.dart';
import 'package:consumers_app/global/global.dart';
import 'package:consumers_app/authentication/auth_screen.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 25, bottom: 10),
            child: Column(
              children: [
                Text(
                  sharedPreferences!.getString("name")!,
                  style: const TextStyle(color: Colors.black, fontSize: 35, fontFamily: "Train",fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8,),
                Text(
                  sharedPreferences!.getString("email")!,
                  style: const TextStyle(color: Colors.black54, fontSize: 25, fontFamily: "Acme",fontWeight: FontWeight.w300),
                ),
                const SizedBox(height: 8,),
                Text(
                  sharedPreferences!.getString("phone")!,
                  style: const TextStyle(color: Colors.black54, fontSize: 25, fontFamily: "Acme",fontWeight: FontWeight.w300),
                ),
                const SizedBox(height: 8,),
                Text(
                  "consumer id: ${sharedPreferences!.getString("uid")!}",
                  style: const TextStyle(color: Colors.black54, fontSize: 15, fontFamily: "Acme",fontWeight: FontWeight.w300),
                ),
                const SizedBox(height: 8,),
                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 2,
                ),
              ],
            ),

          ),



          //body drawer
          Container(
            padding: const EdgeInsets.only(top: 1.0),
            child: Column(
              children: [



                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 2,
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.black,),
                  title: const Text(
                    "Sign Out",
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: ()
                  {
                    firebaseAuth.signOut().then((value){
                      Navigator.push(context, MaterialPageRoute(builder: (c)=> const AuthScreen()));
                    });
                  },
                ),
                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    ),);
  }
}
