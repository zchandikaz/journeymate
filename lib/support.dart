import 'package:flutter/material.dart';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';

import 'LoginPage.dart';
import 'NewsFeedPage.dart';
import 'RecordJourneyPage.dart';

// Common Settings
class CS{
  static const String title = 'Journey Mate';
  static Color bgColor1 = const Color(0xff4285ff);
  static Color fgColor1 = const Color(0xffffffff);
}

class Pages {
  static LoginPage get login => LoginPage();
  static NewsFeedPage get newsFeed => NewsFeedPage();
  static SplashPage get splash => SplashPage();
  static StartRecordJourneyPage get startRecordJourney => StartRecordJourneyPage();
  static RecordJourneyPage get recordJourney => RecordJourneyPage();
  static AddMilestonePage get addMilestone => AddMilestonePage();
  static AddMilestonePage editMilestone(title, note) => AddMilestonePage.edit(title, note);
}

// Common Actions
class CA{
  static void navigateWithoutBack(context, page){
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => page),
          (Route<dynamic> route) => false,
    );
  }
  static Future navigate(context, page) async {
    return await Navigator
        .of(context)
        .push(MaterialPageRoute<dynamic>(builder:(BuildContext context){
          return page;
        })
    );
  }
  static final navigateBack = Navigator.pop;

  static double getScreenWidth(var context) => MediaQuery.of(context).size.width;
  static double getScreenHeight(var context) => MediaQuery.of(context).size.height;

  static Future<Position> getCurLocation() async {
    return Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }

  static void alert(var context, var content, {var title = CS.title}) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(content),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static double convertRange(double value, double fromMin, double fromMax, double toMin, double toMax){
    return (fromMin==fromMax)?((toMin+toMax)/2):((value-fromMin)/(fromMax-fromMin).abs()*(toMax-toMin).abs() + toMin);
  }
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

  static Future signOut(context)  async{
    await FirebaseAuth.instance.signOut();
    GoogleSignIn _googleSignIn = GoogleSignIn();
    await _googleSignIn.signOut();
    CA.navigateWithoutBack(context, Pages.login);
  }

  static Future<FirebaseUser> getCurrentUser () async{
    currentUser = await FirebaseAuth.instance.currentUser();
    print("USER: $currentUser ");
    return currentUser;
  }
}

