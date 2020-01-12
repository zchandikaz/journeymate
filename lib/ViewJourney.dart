import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:zoom_widget/zoom_widget.dart';
import 'package:draggable_fab/draggable_fab.dart';

import 'support.dart';
import 'classes.dart';

class ViewJourneyPage extends StatefulWidget {
  final JourneyMap journeyMap;

  ViewJourneyPage(this.journeyMap);

  @override
  _ViewJourneyPageState createState() => _ViewJourneyPageState(this.journeyMap);
}

class _ViewJourneyPageState extends State<ViewJourneyPage> {
  final JourneyMap journeyMap;


  _ViewJourneyPageState(this.journeyMap);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
          title: Text(CS.title),
      ),
      body: Container()
    );
  }
}