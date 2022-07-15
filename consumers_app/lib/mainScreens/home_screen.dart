import 'package:consumers_app/mainScreens/explore_screen.dart';
import 'package:consumers_app/mainScreens/profile_screen.dart';
import 'package:consumers_app/mainScreens/shopping_screen.dart';
import 'package:flutter/material.dart';

import '../authentication/auth_screen.dart';
import '../global/global.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}



class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _pages =[const ShoppingScreen(),const ExploreScreen(),const ProfileScreen()];
  int _selectedPageIndex= 0;
  void _selectPage(int index){
    setState((){
      _selectedPageIndex=index;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        flexibleSpace: Container(
          decoration: boxDecorationDesign,
        ),
        title: Text(
          sharedPreferences!.getString("name")!,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _pages[_selectedPageIndex],
      // Center(
      //   child: ElevatedButton(
      //     style: ElevatedButton.styleFrom(
      //       primary: Colors.cyan,
      //     ),
      //     onPressed: ()
      //     {
      //       firebaseAuth.signOut().then((value){
      //         Navigator.push(context, MaterialPageRoute(builder: (c)=> const AuthScreen()));
      //       });
      //     },
      //     child: const Text("Logout"),
      //   ),
      // ),
      bottomNavigationBar: Container(
        decoration:  boxDecorationDesign,
        child: BottomNavigationBar(
          currentIndex: _selectedPageIndex,
          onTap: _selectPage,
          showUnselectedLabels: true,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          unselectedItemColor: Colors.white,
          selectedItemColor: Colors.redAccent ,
          iconSize: 28,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label:
              "My Shopping",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_rounded),
              label:
              "Explore",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label:
              "Profile",

            ),
          ],
        ),
      ),
    );
  }
}
