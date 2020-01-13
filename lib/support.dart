import 'package:flutter/material.dart';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:geolocator/geolocator.dart';
import 'package:journeymate/classes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'LoginPage.dart';
import 'NewsFeedPage.dart';
import 'RecordJourneyPage.dart';
import 'ViewJourney.dart';

final dbRef = FirebaseDatabase.instance.reference();

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
  static RecordJourneyPage recordJourney(name) => RecordJourneyPage.begin(name);
  //static RecordJourneyPage continueRecordJourney() => RecordJourneyPage.continueJourney();
  static AddMilestonePage get addMilestone => AddMilestonePage();
  static AddMilestonePage editMilestone(title, note) => AddMilestonePage.edit(title, note);
  static ViewJourneyDetailsPage viewJourneyDetailsPage(JourneyMap journeyMap) => ViewJourneyDetailsPage(journeyMap);
}

// Common Actions
class CA{
  static void log(val){
      print('###$val###');
  }

  static void logi(i, val){
    print('### [$i] | $val###');
  }

  static void navigateWithoutBack(context, page){
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => page
      ),
      (Route<dynamic> route) => false,
    );
  }
  static Future navigate(context, page) async {
    return await Navigator
        .of(context)
        .push(
          MaterialPageRoute<dynamic>(builder:(BuildContext context)=>page
        )
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
          content: new Text(content, style: new TextStyle(fontSize: 20.0)),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("OK", style: new TextStyle(fontSize: 22.0)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

  }

  static Future readStringSP(key, {defval=""}) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key) ?? defval;
    return value;
  }

  static saveStringSP(key, val) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, val);
  }

  static Future confirm(var context, var content, {var title = CS.title, var btnTexts = const ['Yes', 'No']}) async {
    return await showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          title: new Text(title),
          content: new Text(content,
            style: new TextStyle(fontSize: 20.0),),
          actions: <Widget>[
            new FlatButton(onPressed: () {Navigator.of(context).pop('yes');}, child: new Text(btnTexts[0], style: new TextStyle(fontSize: 22.0))),
            new FlatButton(onPressed: () {Navigator.of(context).pop('no');}, child: new Text(btnTexts[1], style: new TextStyle(fontSize: 22.0))),
          ],
        )
    );
  }

  static double convertRange(double value, double fromMin, double fromMax, double toMin, double toMax){
    return (fromMin==fromMax)?((toMin+toMax)/2):((value-fromMin)/(fromMax-fromMin).abs()*(toMax-toMin).abs() + toMin);
  }

  static get waitSpin{
    return SpinKitDoubleBounce( //Ripple
      color: CS.bgColor1,
      size: 50.0,
    );
  }
}

class CacheFile{
  File file;
  String fileName;

  List<String> _fileLocationList = ['', '__my_journey_map_list__'];
  int _fileLocationIndex = 0;


  CacheFile(fileName, {i=0}){
    this.fileName = fileName;
    this._fileLocationIndex = i;
  }

  CacheFile.fromPath(path, {i=0}){
    this.fileName = path?.split("/")?.last;
    this._fileLocationIndex = i;
  }
  CacheFile.fromFile(File file){
    this.fileName = file?.path?.split("/")?.last;
    this.file = file;
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> get path async {
    final path = await _localPath;
    return '$path/'+(this._fileLocationIndex==0?'':this._fileLocationList[this._fileLocationIndex]+'/')+'${this.fileName}';
  }

  Future<File> write(String data) async {
    file ??= File(await path);
    return file.writeAsString(data);
  }

  Future<String> read() async {
    try {
      file ??= File(await path);
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      CA.log('CacheFile[${ this.file.path }] Read Error [${ e.toString() }]');
      return null;
    }
  }

  static Future<List<FileSystemEntity>> listOfFiles(path) async {
    Directory _dir = Directory("${await CacheFile._localPath}/$path/");
    if(!(await _dir.exists())){
      _dir.create(recursive: true);
      return List();
    }
    return _dir.listSync();
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

    await _auth.signInWithCredential(credential);
    currentUser = await _auth.currentUser();

    print("User Name: ${currentUser.displayName}");

    return currentUser;
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



