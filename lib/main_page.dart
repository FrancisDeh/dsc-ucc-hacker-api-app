import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


const _primaryColor = Color(0xFFFFDE03);
class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  bool _isConnectedToNetwork = false;
  bool _isLoading = true;
  List _newsList = new List();

  String _userName = "John Doe";
  String _userEmail = "johndoe@gmail.com";


  @override
  void initState() {
    super.initState();

    //authenticate user
    _authenticateUser();

    //check network connectivity
    _checkNetworkConnectivity();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hacker News", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing:  2.0),),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.view_list), onPressed: (){},)
        ],
      ),
      drawer: _buildDrawer(),
      body: _isConnectedToNetwork ? _loadData() : _showNetworkView(),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _loadData() {
    return _isLoading ? Center(child: CircularProgressIndicator(),) : _listBuilder();
  }

  Widget _listBuilder () {
    return _newsList.length == 0 ? _emptyView() : Container(
      child: ListView.builder(
          padding: EdgeInsets.only(bottom: 65.0),
          itemCount: _newsList.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int position) {
            var _newsItem = _newsList[position];

            return Dismissible(
                key: Key(_newsItem['title']),
              onDismissed: (DismissDirection dir) {
                  print("dismissing $position");
                  print(_newsList);
                setState(() {
                  this._newsList.removeAt(position);
                });
                  print(_newsList);

                  _deleteSnackBar(context, position, _newsItem);
              },
                child: _buildList(_newsList[position]),
              background: Container(
                color: _primaryColor,
                child: Icon(Icons.delete, color: Colors.red,),
                alignment: Alignment.centerLeft,
              ),
              secondaryBackground: Container(
                color: _primaryColor,
                child: Icon(Icons.delete, color: Colors.red,),
                alignment: Alignment.centerRight,
              ),
            );
          }
      ),
    );
  }


  Widget _emptyView () {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.show_chart, color: Colors.brown, size: 60.0,),
          Text("Empty! Refresh to load data." , style: TextStyle(fontSize: 20.0, color: Colors.brown))
        ],
      ),
    );
  }

  Widget _showNetworkView () {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.cloud_off, color: Colors.brown, size: 60.0,),
          Text("No Network! Connect and Refresh." , style: TextStyle(fontSize: 20.0, color: Colors.brown))
        ],
      ),
    );
  }

  Widget _buildList(Map<String, dynamic> story) {
    return Card(
      elevation: 1.0,
      child: ListTile(
        onTap: () {
          _showReadAlertDialog(story);
        },
        contentPadding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0),
        leading: CircleAvatar(
          child: Text("${story['type'].toString().substring(0, 1)}", style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.brown,
        ),
        trailing: IconButton(
          icon: Icon(Icons.share, color: Colors.grey,),
          onPressed: () {
            Share.share("Check out this *Hacker News article* titled *${story['title']}* by *${story['by']}* at ${story['url']}");
          },
        ),
        title: Text("${story['title']}", style: TextStyle( fontSize: 20.0),),
        subtitle: Text("by ${story['by']}", style: TextStyle( fontSize: 14.0, color: Colors.redAccent)),
      ),
    );

  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountEmail: Text("$_userEmail", style: TextStyle( fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18.0),),
            accountName: Text("$_userName", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20.0)),
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.account_circle, color: Colors.white,),
              backgroundColor: Colors.brown,
            ),
            decoration: BoxDecoration(
              color: _primaryColor
            ),
          ),
          SizedBox(height: 20.0),
          ListTile(
            leading: Icon(Icons.info_outline, color: Colors.blueAccent,),
            title: Text("About Us", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, letterSpacing: 2.0),),
            onTap: () {
              Navigator.pop(context);
              _showAboutUsDialog();
            },
          ),
          ListTile(
            leading: Icon(Icons.close, color: Colors.redAccent, ),
            title: Text("Logout", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
            onTap: () {
              _logOut();
            },
          )
        ],
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () {
        _checkNetworkConnectivity();
      },
      child: Icon(Icons.refresh),
    );
  }

   _checkNetworkConnectivity () async {
     try {
       final result = await InternetAddress.lookup('google.com');
       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
         //load data
         print("network");
         setState(() {
           _isConnectedToNetwork = true;
         });

         //load data
         _getDataFromHackerNewsApi();
       } else {
         // show no network state
         setState(() {
           _isConnectedToNetwork = false;
           print("no network");
         });
       }
     } on SocketException catch(_) {
       print("error");
       // show no network state
       setState(() {
         _isConnectedToNetwork = false;
         print("no network");
       });
     }

  }

   _getDataFromHackerNewsApi () async {

    _newsList.clear();
    setState(() {
      _isLoading = true;
    });

   var topStoriesUrl = "https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty";
   var response = await http.get("$topStoriesUrl");
   if(response.statusCode == 200) {
//     print(convert.jsonDecode(response.body));
     List storyList = convert.jsonDecode(response.body);
//     print(storyList);

     //get only 10 records
     var size = storyList.length > 10 ? 10 : storyList.length;

     for (int index = 0; index < size; index++) {
       var singleStoryUrl = "https://hacker-news.firebaseio.com/v0/item/${storyList[index]}.json?print=pretty";
       var response2 = await http.get("$singleStoryUrl");

       var myStorySet = {
           'by': convert.jsonDecode(response2.body)['by'],
           'id': convert.jsonDecode(response2.body)['id'],
           'title': convert.jsonDecode(response2.body)['title'],
           'type' : convert.jsonDecode(response2.body)['type'],
           'url' : convert.jsonDecode(response2.body)['url']

         };

       if(index == 0) {
         setState(() {
           _isLoading = false;
         });
       }

       setState(() {
         var isfound = _newsList.map((story) {
            return story['id'] == myStorySet['id'];
         });

       if(!isfound.contains(true)) {
         _newsList.insert(0, myStorySet);
       }
       });
     }


   } else {
     print("Request failed with status: ${response.statusCode}.");
     setState(() {
       _isLoading = false;
       _isConnectedToNetwork = false;
     });
   }
  }

  _deleteSnackBar(context, int indexOfNews, newsItem) {
    return Scaffold.of(context).showSnackBar(
      SnackBar(
          content: Text("You have successfully deleted item.", style: TextStyle(color: _primaryColor),),
        backgroundColor: Colors.black,
        action: SnackBarAction(
            label: "UNDO",
            textColor: _primaryColor,
            onPressed: () {
              setState(() {
                _newsList.insert(indexOfNews, newsItem);
              });
            }
        ),
      )
    );
  }

  _showReadAlertDialog(Map<String, dynamic> story) {
    return showDialog(context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: _primaryColor,
        elevation: 4.0,
        title: Text("Confirm Action"),
        content: Text("Do you want to read '${story['title']}' news article?"),
        actions: <Widget>[
          FlatButton(child: Text("Cancel"), onPressed: () {
            Navigator.pop(context);
          }
          ,),
          FlatButton(child: Text("Read"), onPressed: () {
            Navigator.pop(context);
            _launchURL("${story['url']}");
          },)
        ],
      );
    });
  }

  _launchURL(String url) async {
    print(url);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


    _showAboutUsDialog() {
     showAboutDialog(
      context: context,
      applicationIcon: Icon(Icons.show_chart),
      applicationName: "DUMA",
      applicationVersion: "1.0",
      children: [
        Text('This app is built by DSC UCC. It includes functionality that allows you to access the Hacker News API to fetch for news.')
      ]
    );
  }

  _authenticateUser () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('status') ?? false;
    print(isLoggedIn);
    if(isLoggedIn) {
      setState(() {
        _userName = prefs.getString('name');
        _userEmail = prefs.getString('email');
      });
      print(_userEmail);
      print(_userName);
    } else {
      Navigator.of(context).pushReplacementNamed('/');
    }

  }

  _logOut () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
     prefs.setBool('status', false);
     prefs.setString('name', null);
     prefs.setString('email', null);

     Navigator.of(context).pushReplacementNamed('/');

  }
}
