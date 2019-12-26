import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:zoom_widget/zoom_widget.dart';

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

// user defined function

class RecordJourneyPage extends StatefulWidget {
  @override
  _RecordJourneyPageState createState() => _RecordJourneyPageState();
}

class _RecordJourneyPageState extends State<RecordJourneyPage> {
  JourneyMap journeyMap;

  void _select(String choice) {
    if(choice=='Cancel') CA.NavigateNoBack(context, Pages.newsFeed);
  }

  void _recordMilestone(){
    Geolocator().isLocationServiceEnabled().then((var result){
      if(result){
        CA.getCurLocation().then((location){
          setState((){
            journeyMap.add(location.latitude, location.longitude, "", new MilestoneNote());
          });
        });
      }else{
        CA.alert(context, "Please activate GPS.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    journeyMap ??= new JourneyMap(context);

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
          )
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

class MilestoneNote{
  String text;
  // should be contained audio, vedio or etc.
}

class Milestone{
  double lat;
  double lng;
  String title;
  MilestoneNote note;

  Milestone(this.lat, this.lng, this.title, this.note);
}

class Coord{
  double left;
  double top;

  Coord(this.left, this.top);
}

class JourneyMap{
  var context;
  List<Milestone> milestones = new List();

  JourneyMap(this.context);

  add(double lat, double lng, String title, MilestoneNote note){
    milestones.add(new Milestone(lat, lng, title, note));
  }

  getWidget(){
    if(milestones.isEmpty) return Stack(children:[]);

    final double milestoneSize = 40;
    final double mapPadding = 20;
    final double screenSize = 1000;
    double screenWidth = screenSize - milestoneSize - 2*mapPadding;//CA.getScreenWidth(context)-milestoneSize;

    List<double> lats = milestones.map((Milestone m)=>m.lat).toList();
    List<double> lngs = milestones.map((Milestone m)=>m.lng).toList();

    var minF = (double curr, double next) => curr < next? curr: next;
    var maxF = (double curr, double next) => curr > next? curr: next;

    double minLat = lats.reduce(minF);
    double maxLat = lats.reduce(maxF);

    double minLng = lngs.reduce(minF);
    double maxLng = lngs.reduce(maxF);

    print('minLat:$minLat maxLat:$maxLat minLng:$minLng maxLng:$maxLng');


    List<double> xs = new List();
    List<double> ys = new List();

    List<Coord> coords = milestones.map((Milestone milestone){
      double left, top;

      print('Lng:${milestone.lng} Lat:${milestone.lat} screenWidth:$screenWidth');
      print('left:$left top:$top');

      if((minLng-maxLng).abs()>(minLat-maxLat).abs()){
        left = (minLng==maxLng)?0:((milestone.lng-minLng)/(maxLng-minLng).abs()*screenWidth);
        top = (minLat==maxLat)?0:((milestone.lat-minLat)/(maxLng-minLng).abs()*screenWidth);
      }else{
        top = (minLat==maxLat)?0:((milestone.lat-minLat)/(maxLat-minLat).abs()*screenWidth);
        left = (minLng==maxLng)?0:((milestone.lng-minLng)/(maxLat-minLat).abs()*screenWidth);
      }

      xs.add(left);
      ys.add(top);

      return Coord(left, top);
    }).toList();

    double minX = xs.reduce(minF);
    double maxX = xs.reduce(maxF);

    double minY = ys.reduce(minF);
    double maxY = ys.reduce(maxF);

    double centerOffsetX = (screenWidth - (maxX-minX))/2;
    double centerOffsetY = (screenWidth - (maxY-minY))/2;

    int i = 0;

    List<Positioned> milestoneFlags = coords.map((Coord coord){
      return Positioned(
        left: mapPadding + coord.left + centerOffsetX,
        top: mapPadding + coord.top + centerOffsetY,
        width: milestoneSize,
        height: milestoneSize,
        child: new InkResponse(
          child: new Container(
            decoration: new BoxDecoration(
              border: Border.all(color: Colors.white, width: 5),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text((++i).toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),)
              ],
            ),
          ),
        ),
      );
    }).toList();

    return Stack(
      children: milestoneFlags
    );
  }
}

class Line extends CustomPainter {
  var p1, p2;

  Line(this.p1, this.p2);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4;
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }

  static CustomPaint draw(context, p1, p2){
    return CustomPaint(
      size: Size(CA.getScreenWidth(context), CA.getScreenHeight(context)),
      painter: Line(p1, p2),
    );
  }
}