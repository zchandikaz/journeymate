import 'package:flutter/material.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';

import 'support.dart';

class NewsFeedPage extends StatefulWidget {
  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FabCircularMenu(
          child: DefaultTabController(
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
                  Icon(Icons.directions_car),
                  Icon(Icons.directions_transit),
                  new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        width: 150.0,
                        height: 150.0,
                        decoration:  new BoxDecoration(
                          /*boxShadow: [new BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 10,
                          offset: Offset(0, 0), // changes position of shadow
                        )],*/
                            borderRadius: BorderRadius.all(Radius.circular(100.0)),
                            image: new DecorationImage(
                                image: new NetworkImage(SignInSupport.currentUser.photoUrl),
                                fit: BoxFit.cover
                            )
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
                        padding: EdgeInsets.all(0),
                        onPressed: () => SignInSupport.signOut().
                        then((var r){ CA.NavigateNoBack(context, Pages.login); })
                            .catchError((e)=>print(e)),
                        child: new RaisedButton(
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
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
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
              print('JOURNEY');
            },),
            //IconButton(icon: Icon(Icons.border_color, size:  CA.getScreenWidth(context)*0.1, color: CS.fgColor1), onPressed: () { print('Pressed!'); }),
          ]
      )
    );
  }
}
