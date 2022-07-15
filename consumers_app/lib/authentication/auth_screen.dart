import 'package:flutter/material.dart';
import 'package:consumers_app/authentication/login.dart';
import 'package:consumers_app/authentication/register.dart';
import 'package:consumers_app/global/global.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: boxDecorationDesign
          ),
          automaticallyImplyLeading: false,
          title: const Text(
              "GoPansari",
            style: TextStyle(
              fontSize: 60,
              color: Colors.white,
              fontFamily: "Train",
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.lock, color: Colors.white,),
                text: "Login",
              ),
              Tab(
                icon: Icon(Icons.person, color: Colors.white,),
                text: "Register",
              ),
            ],
            indicatorColor: Colors.white38,
            indicatorWeight: 6,
          ),
        ),
        body: Container(
          decoration:boxDecorationDesign,
          child: const TabBarView(
            children: [
              LoginScreen(),
              RegisterScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
