import 'package:flutter/material.dart';

import 'support.dart';

class StartRecordJourneyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(CS.title),
        ),
        body: new Container(
          margin: EdgeInsets.symmetric(horizontal: CA.getScreenWidth(context)*0.15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Journey Name',
                ),
                style: TextStyle(
                  fontSize: 23,
                ),
                textAlign: TextAlign.center,
              ),
              new RaisedButton(
                  onPressed: () => CA.NavigateNoBack(context, Pages.recordJourney),
                  padding: EdgeInsets.only(left: 3.0, top: 17, bottom: 17),
                  color: CS.bgColor1,
                  child: new Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Container(
                          padding: EdgeInsets.only(left: 30.0,right: 30.0),
                          child: new Text("START RECORDING",style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1
                            ),
                          )
                      ),
                    ],
                  )
              )
            ],
          ),
        )
    );
  }
}



class RecordJourneyPage extends StatefulWidget {
  @override
  _RecordJourneyPageState createState() => _RecordJourneyPageState();
}

class _RecordJourneyPageState extends State<RecordJourneyPage> {
  JourneyMap journeyMap;


  _RecordJourneyPageState(){
    journeyMap = new JourneyMap(context);
  }

  void _select(String choice) {
    if(choice=='Cancel') CA.NavigateNoBack(context, Pages.newsFeed);
  }

  void _recordMilestone(){
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(CS.title),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: _select,
              itemBuilder: (BuildContext context) {
                return ['Cancel'].map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ]
      ),
      body: journeyMap.getWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: _recordMilestone,
        tooltip: 'Milestone',
        child: Icon(Icons.add),
      ),
    );
  }
}

class MilestoneNote{
  String text;
  // should be contained audio, vedio or etc.
}

class Milestone{
  JourneyMap parent;
  double lat;
  double lng;
  String title;
  MilestoneNote note;

  Milestone(this.parent, this.lat, this.lng, this.title, this.note);

  Positioned getWidget(){
    double screenWidth = CA.getScreenWidth(parent.context);
    double screenHeight = CA.getScreenHeight(parent.context);

    return Positioned(
      left: 50,
      top: 75,
      width: 10,
      height: 10,
      child: Icon(Icons.flag),
    );
  }
}

class JourneyMap{
  var context;
  List<Milestone> milestones = new List();

  JourneyMap(this.context);

  add(double lat, double lng, String title, MilestoneNote note){
    milestones.add(new Milestone(this, lat, lng, title, note));
  }

  getWidget(){
    return Stack(
      children: milestones.map((Milestone milestone)=>milestone.getWidget()).toList(),
    );
  }
}