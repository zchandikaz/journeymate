import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:zoom_widget/zoom_widget.dart';

import 'support.dart';
import 'classes.dart';

class StartRecordJourneyPage extends StatelessWidget {
  final TextEditingController txtName = new TextEditingController();

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
                controller: txtName,
              ),
              new RaisedButton(
                  onPressed: () => CA.navigateWithoutBack(context, Pages.recordJourney(txtName.text)),
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

class AddMilestonePage extends StatelessWidget {
  final txtTitle = new TextEditingController();
  final txtNote = new TextEditingController();

  AddMilestonePage();

  AddMilestonePage.edit(title, note){
    txtTitle.text = title;
    txtNote.text = note;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(CS.title),
        ),
        body: new Container(
          margin: EdgeInsets.symmetric(horizontal: CA.getScreenWidth(context)*0.07),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text("New Milestone", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
              new ListTile(
                leading: const Icon(Icons.title),
                title: new TextField(
                  controller: txtTitle,
                  decoration: new InputDecoration(
                    hintText: "Title",
                  ),
                )
              ),
              new ListTile(
                leading: const Icon(Icons.note),
                title: TextField(
                  controller: txtNote,
                  decoration: InputDecoration(
                    hintText: 'Note',
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
              ),
              new RaisedButton(
                  onPressed: (){
                    if(txtTitle.text.length==0)
                      CA.alert(context, "Please fill the fields.");
                    else
                      CA.navigateBack(context, {"title":txtTitle.text, "note":txtNote.text});
                  },
                  padding: EdgeInsets.only(left: 3.0, top: 17, bottom: 17),
                  color: CS.bgColor1,
                  child: new Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Container(
                          padding: EdgeInsets.only(left: 30.0,right: 30.0),
                          child: new Text("SAVE",style: TextStyle(
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
  String name;
  bool loadFromJson = false;

  RecordJourneyPage();

  RecordJourneyPage.begin(this.name);
//
//  RecordJourneyPage.continueJourney(){
//    this.name = "";
//    this.loadFromJson = true;
//  }

  @override
  _RecordJourneyPageState createState() => _RecordJourneyPageState(name, loadFromJson);
}

class _RecordJourneyPageState extends State<RecordJourneyPage> {
  JourneyMap journeyMap;
  String name;
  bool loadFromJson = false;

  _restoreFromSP() async {
    var json = await CA.readStringSP('current_recording_journey');
    setState(() {
      journeyMap = JourneyMap.fromJson(jsonDecode(json)).of(context);
    });

  }

  _RecordJourneyPageState(name, loadFromJson){
    this.name = name;
    this.loadFromJson = loadFromJson;
    if(loadFromJson) _restoreFromSP();
  }

  void _select(String choice) {
    if(choice=='Cancel') CA.navigateWithoutBack(context, Pages.newsFeed);
  }

  void _recordMilestone(){
    Geolocator().isLocationServiceEnabled().then((var result){
      if(result){
        CA.getCurLocation().then((location){
          CA.navigate(context, Pages.addMilestone).then((v){
            if(v!=null)
              setState((){
                journeyMap.add(location.latitude, location.longitude, v['title'], new MilestoneNote(v['note']));
                saveCurrentJourneySP();
              });
          });
        });
      }else{
        CA.alert(context, "Please activate GPS.");
      }
    });
  }

  void saveCurrentJourneySP(){
    String json = jsonEncode(journeyMap);
    CA.saveStringSP('current_recording_journey', json);
  }

  void _cancel() {
    if(journeyMap.localFile==null) {
      CA.confirm(context, 'Do you want to cancel the journey without saving ?').then((v) {
        if (v == 'yes')
          CA.navigateWithoutBack(context, Pages.newsFeed);
        CA.saveStringSP('current_recording_journey', "");
      });
    } else {
      journeyMap.saveToLocalFile();
      CA.confirm(context, 'Do you want to exit from recording the journey ?').then((v) {
        if (v == 'yes')
          CA.navigateWithoutBack(context, Pages.newsFeed);
        CA.saveStringSP('current_recording_journey', "");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    journeyMap ??= new JourneyMap(name).of(context);

    int mCount = 0;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(CS.title),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                journeyMap.saveToLocalFile();
                CA.alert(context, "Journey map saved.");
              },
            ),
            // action button
            IconButton(
              icon: Icon(Icons.cancel),
              onPressed: _cancel,
            ),

            PopupMenuButton<String>(
              onSelected: _select,
              itemBuilder: (BuildContext context) {
                return ['Settings'].map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ]
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: CA.getScreenWidth(context),
            child: Zoom(
              width: 1000,
              height: 1000,
              child: journeyMap.getWidget(),
              canvasColor: Colors.black54,
              colorScrollBars: Colors.black54,
              opacityScrollBars: 1,
              initZoom: 0.0,
            ),
          ),
          Container(
            height: CA.getScreenHeight(context)-CA.getScreenWidth(context) - 80,
            child: ListView(
              scrollDirection: Axis.vertical,
              children: journeyMap.milestones.map((Milestone m){
                return Container(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.6, color: Colors.black38))),
                  child: new ListTile(
                    onTap: MilestoneListTile(mCount).getI((i){
                      CA.navigate(context, Pages.editMilestone(journeyMap.milestones[i].title, journeyMap.milestones[i].note.text)).then((v){
                        if(v!=null)
                          setState((){
                            journeyMap
                              ..milestones[i].title = v['title']
                              ..milestones[i].note.text = v['note'];
                            saveCurrentJourneySP();
                          });
                      });
                    }),
                    trailing: new FlatButton(
                        onPressed: MilestoneListTile(mCount).getI((i){
                          setState(() {
                            journeyMap.milestones.removeAt(i);
                          });
                        }),
                        child: Icon(Icons.delete)
                    ),
                    leading: Text('${++mCount}'),
                    title: Text(m.title, style: TextStyle(fontSize: 15),),
                  ),
                );
              }).toList(),
            ),
          ),

        ],  
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _recordMilestone,
        tooltip: 'Milestone',
        child: Icon(Icons.add),
      ),
    );
  }
}

