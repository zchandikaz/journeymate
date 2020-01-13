import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:json_annotation/json_annotation.dart';
import 'package:random_string/random_string.dart';


import 'support.dart';

class IndexKeeper{
  int i;

  IndexKeeper(this.i);

  GestureTapCallback getI(Function f){
    return ()=>f(i);
  }

}

@JsonSerializable()
class MilestoneNote{
  String text = "";

  MilestoneNote(this.text);
// should be contained audio, vedio or etc.

  factory MilestoneNote.fromJson(Map<String, dynamic> json) => new MilestoneNote(json['text']);

  Map<String, dynamic> toJson()=><String, dynamic>{
    'text': this.text,
  };
}

@JsonSerializable()
class Milestone{
  double lat;
  double lng;
  String title = "";
  MilestoneNote note;

  Milestone(this.lat, this.lng, this.title, this.note);

  factory Milestone.fromJson(Map<String, dynamic> json) => new Milestone(json['lat'], json['lng'], json['title'], MilestoneNote.fromJson(json['note']));

  Map<String, dynamic> toJson()=><String, dynamic>{
    'lat': this.lat,
    'lng': this.lng,
    'title': this.title,
    'note': this.note.toJson()
  };
}

@JsonSerializable()
class JourneyMap{
  var context;
  CacheFile localFile;

  String name;
  List<Milestone> milestones;
  DateTimeJE createdDate;

  JourneyMap(name, {milestones, localFile, createdDate}){
    this.createdDate = createdDate??DateTimeJE.now;
    this.milestones = milestones??new List();
    this.localFile = localFile;
    this.name = name;
  }
  
  JourneyMap of(context){
    this.context = context;
    return this;
  }

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

//    CA.log('minLat:$minLat maxLat:$maxLat minLng:$minLng maxLng:$maxLng');


    List<double> xs = new List();
    List<double> ys = new List();

    List<Coord> coords = milestones.map((Milestone milestone){
      double left, top;

//      CA.log(('Lng:${milestone.lng} Lat:${milestone.lat} screenWidth:$screenWidth');
//      CA.log(('left:$left top:$top');

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

  factory JourneyMap.fromJson(Map<String, dynamic> json){
    String name = json['name'];
    List m = json['milestones'];
    List<Milestone> milestones = m.map((v)=>Milestone.fromJson(v)).toList();
    return JourneyMap(name, createdDate: DateTimeJE.fromJson(json['createdDate']) ,milestones: milestones, localFile:CacheFile(json['localFile'], i:1));
  }

  Map<String, dynamic> toJson()=><String, dynamic>{
    'milestones': this.milestones,
    'name': this.name,
    'localFile': this.localFile==null?'':this.localFile.fileName,
    'createdDate': this.createdDate,
    'accessedDate': DateTimeJE.now,
  };

  void saveToLocalFile() async {
    if(this.localFile==null){

      List<FileSystemEntity> jmFileList = await CacheFile.listOfFiles(
          '__my_journey_map_list__');

      List<String> names = jmFileList.map((FileSystemEntity fileSystemEntity)
        =>fileSystemEntity.toString()).toList();

      String fileName;
      do{
        fileName = randomAlphaNumeric(8);
      }while(names.contains(fileName));
      this.localFile = CacheFile(fileName, i:1);
    }
    this.localFile.write(jsonEncode(this.toJson()));
  }
}

class JourneyMapManger{
  static JourneyMapManger _instance;
  List<JourneyMap> jmList;

  static Future<JourneyMapManger> getInstance() async {
    if(_instance!=null && _instance.jmList!=null)
      return _instance;

    _instance = JourneyMapManger._();

    List<FileSystemEntity> jmFileList = await CacheFile.listOfFiles(
        '__my_journey_map_list__');

    List<JourneyMap> jmList = new List();


    for (FileSystemEntity f in jmFileList) {
      CacheFile cacheFile = CacheFile.fromPath(f.path, i:1);

      String jsonText = await cacheFile.read();
      JourneyMap journeyMap = JourneyMap.fromJson(jsonDecode(jsonText));
      journeyMap.localFile = cacheFile;
      jmList.add(journeyMap);
    }
    _instance.jmList = jmList;
    return _instance;
  }

  void removeAt(int i) async {
    CA.logi(0.1, jmList[i].localFile.file.path);
    await jmList[i].localFile.file.delete();
    jmList.removeAt(i);
  }

  JourneyMapManger._();
}

class Coord{
  double left, top;

  Coord(this.left, this.top);

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

@JsonSerializable()
class DateTimeJE{
  DateTime dateTime;

  int get year => dateTime.year;
  int get month => dateTime.month;
  int get day => dateTime.day;
  int get hour => dateTime.hour;
  int get minute => dateTime.minute;
  int get second => dateTime.second;
  int get millisecond => dateTime.millisecond;
  int get microsecond => dateTime.microsecond;

  factory DateTimeJE.fromJson(Map<String, dynamic> json)=>DateTimeJE.utc(
    json['year'],
    month:json['month'],
    day:json['day'],
    hour:json['hour'],
    minute:json['minute'],
    second:json['second'],
    millisecond:json['millisecond'],
    microsecond:json['microsecond'],
  );

  Map<String, dynamic> toJson()=><String, dynamic>{
    'year': this.dateTime.year,
    'month': this.dateTime.month,
    'day': this.dateTime.day,
    'hour': this.dateTime.hour,
    'minute': this.dateTime.minute,
    'second': this.dateTime.second,
    'millisecond': this.dateTime.millisecond,
    'microsecond': this.dateTime.microsecond,
  };

  DateTimeJE.utc(int year, {int month=1, int day=1, int hour=0, int minute=0, int second=0, int millisecond=0, int microsecond=0}){
    this.dateTime = DateTime.utc(year, month, day, hour, minute, second, millisecond, microsecond);
  }

  DateTimeJE(this.dateTime);

  static DateTimeJE get now => DateTimeJE(DateTime.now());

  @override
  String toString() {
    return "$year-${10>month?'0':''}$month-${10>day?'0':''}$day ${10>hour?'0':''}$hour:${10>minute?'0':''}$minute:${10>second?'0':''}$second";
  }


}