import 'package:flutter/material.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:journeymate/classes.dart';

import 'support.dart';

class NewsFeedPage extends StatefulWidget {
  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  @override
  Widget build(BuildContext context) {
//    JourneyMapManger.getInstance().then((JourneyMapManger journeyMapManger){
//      print(journeyMapManger.jmList);
//    });
//
//    JourneyMapManger.getInstance().then((JourneyMapManger journeyMapManger){
//      CA.logi(201, journeyMapManger.jmList);
//      journeyMapManger.jmList.map((JourneyMap journeyMap){
//        print(journeyMap.name);
//        return Container(
//          decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.6, color: Colors.black38))),
//          child: new ListTile(
//            onTap: (){},
//            trailing: new FlatButton(
//                onPressed: (){},
//                child: Icon(Icons.delete)
//            ),
//            title: Text(journeyMap.name, style: TextStyle(fontSize: 15),),
//          ),
//        );
//      }).toList();
//    });

    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(CS.title),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.web)),
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.account_box)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              FabCircularMenu(
                  child: Icon(Icons.directions_car),
                  ringColor: CS.bgColor1,
                  ringDiameter: CA.getScreenWidth(context)*0.8,
                  ringWidth: CA.getScreenWidth(context)*0.8/3,
                  fabColor: CS.bgColor1,
                  fabOpenIcon: Icon(Icons.add),
                  options: <Widget>[
                    IconButton(icon: ImageIcon(AssetImage('assets/images/publish_post.png'), size:  CA.getScreenWidth(context)*0.1, color: CS.fgColor1), onPressed: () {
                      print('POST');
                    }),
                    IconButton(icon: ImageIcon(AssetImage('assets/images/record_journey.png'), size:  CA.getScreenWidth(context)*0.1, color: CS.fgColor1), onPressed: (){
                      CA.navigate(context, Pages.startRecordJourney);
                    },),
                  ]
              ),
              FutureBuilder(
                future: getJourneyList(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if(snapshot.hasData)
                    return snapshot.data;
                  else
                    return CA.waitSpin;
                },
              ),
              new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: 150,
                    height: 150,
                    child: AspectRatio(
                      aspectRatio: 1/1,
                      child: ClipOval(
                        child: FadeInImage.assetNetwork(
                          fit: BoxFit.cover,
                          placeholder: 'assets/images/user_profile.png',
                          image: SignInSupport.currentUser.photoUrl,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.all(20),),
                      Icon(Icons.person),
                      Padding(padding: EdgeInsets.all(10),),
                      Text(SignInSupport.currentUser.displayName, style: TextStyle(fontSize: 18),),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.all(20),),
                      Icon(Icons.email),
                      Padding(padding: EdgeInsets.all(10),),
                      Text(SignInSupport.currentUser.email, style: TextStyle(fontSize: 18),),
                    ],
                  ),
                  new RaisedButton(
                      onPressed: () => SignInSupport.signOut(context).
                      then((var r){ CA.navigateWithoutBack(context, Pages.login); })
                          .catchError((e)=>print(e)),
                      padding: EdgeInsets.only(left: 3.0, top: 17, bottom: 17),
                      color: CS.bgColor1,
                      child: new Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Container(
                              padding: EdgeInsets.only(left: 30.0,right: 30.0),
                              child: new Text("Sign Out",style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              )
                          ),
                        ],
                      )
                  )
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
  JourneyMapManger journeyMapManger;
  getJourneyList() async {
    journeyMapManger = await JourneyMapManger.getInstance();
    CA.logi(0.2, journeyMapManger.jmList);

    int jCount = 0;
    return  ListView(
      scrollDirection: Axis.vertical,
      children: journeyMapManger.jmList.map((JourneyMap m){
        return Container(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.6, color: Colors.black38))),
          child: new ListTile(
            onTap: IndexKeeper(jCount++).getI((i){
              CA.navigate(context, Pages.viewJourneyDetailsPage(journeyMapManger.jmList[i]));
            }),
            title: Text(m.name, style: TextStyle(fontSize: 15),),
          ),
        );
      }).toList(),
    );
  }
}
