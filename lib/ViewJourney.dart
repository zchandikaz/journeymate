import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:zoom_widget/zoom_widget.dart';
import 'package:draggable_fab/draggable_fab.dart';

import 'support.dart';
import 'classes.dart';

class ViewJourneyDetailsPage extends StatefulWidget {
  final JourneyMap journeyMap;

  ViewJourneyDetailsPage(this.journeyMap);

  @override
  _ViewJourneyDetailsPageState createState() => _ViewJourneyDetailsPageState(this.journeyMap);
}

class _ViewJourneyDetailsPageState extends State<ViewJourneyDetailsPage> {
  final JourneyMap journeyMap;

  _ViewJourneyDetailsPageState(this.journeyMap);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
          title: Text(CS.title),
      ),
      body: Container(
        height: 450,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.title),
              title: const Text('Name'),
              subtitle: Text(journeyMap.name),
              trailing: new FlatButton(
                  onPressed: (){},
                  child: Icon(Icons.edit)
              ),
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Creadted Date'),
              subtitle: Text(journeyMap.createdDate.toString()),
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Published Date'),
              subtitle: Text("-"),
            ),
            RaisedButton(
                onPressed: () {},
                padding: EdgeInsets.only(left: 3.0, top: 17, bottom: 17),
                color: Colors.white,
                //shape: ContinuousRectangleBorder(side:BorderSide(color:Colors.grey)),
                child: new Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Container(
                        padding: EdgeInsets.only(left: 30.0,right: 30.0),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.cloud_upload, color: Colors.black87,),
                            new Text("  PUBLISH",style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                fontSize: 12
                            ),
                            )
                          ],
                        )
                    ),
                  ],
                )
            ),
            RaisedButton(
                onPressed: () {},
                padding: EdgeInsets.only(left: 3.0, top: 17, bottom: 17),
                color: Colors.white,
                //shape: ContinuousRectangleBorder(side:BorderSide(color:Colors.grey)),
                child: new Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Container(
                        padding: EdgeInsets.only(left: 30.0,right: 30.0),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.delete_outline, color: Colors.black87,),
                            new Text("  DELETE",style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                fontSize: 12
                            ),
                            )
                          ],
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