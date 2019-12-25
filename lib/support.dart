import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'LoginPage.dart';
import 'NewsFeedPage.dart';

// Common Settings
class CS{
  static final String title = 'Journey Mate';
  static Color bgColor1 = const Color(0xff4285ff);
  static Color fgColor1 = const Color(0xffffffff);
}

class Pages {
  static LoginPage get login => LoginPage();
  static NewsFeedPage get newsFeed => NewsFeedPage();
  static SplashPage get splash => SplashPage();

}

// Common Actions
class CA{
  static void NavigateNoBack(context, page){
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => page),
          (Route<dynamic> route) => false,
    );
  }
  static double getScreenWidth(var context) => MediaQuery.of(context).size.width;
  static double getScreenHeight(var context) => MediaQuery.of(context).size.height;

}

class SignInSupport{
  static FirebaseUser currentUser;

  static Future<FirebaseUser> signIn() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = new GoogleSignIn();

    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user = await _auth.signInWithCredential(credential);
    currentUser = await _auth.currentUser();



    print("User Name: ${user.displayName}");

    return user;
  }

  static Future signOut()  async{
    await FirebaseAuth.instance.signOut();
  }

  static Future<FirebaseUser> getCurrentUser () async{
    currentUser = await FirebaseAuth.instance.currentUser();
    print("USER: $currentUser ");
    return currentUser;
  }
}

