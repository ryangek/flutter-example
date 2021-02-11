import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appl/pages/songs.dart';
import 'package:flutter_appl/signin.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'components/widgets.dart';

class Home extends StatefulWidget {
  Home({Key key, this.api}) : super(key: key);

  final String api;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SharedPreferences _sharedPreferences;

  String _token = "";
  int _itemsLength = 10;

  Map<String, String> get headers => {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $_token",
      };

  @override
  void initState() {
    super.initState();
    onCheckSignInStatus();
    debugPrint("On initial state...");
  }

  onCheckSignInStatus() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    if (_sharedPreferences.getString("_token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => SignIn(api: widget.api)),
          (Route<dynamic> route) => false);
    } else {
      setState(() {
        _token = _sharedPreferences.getString("_token");
      });
    }
  }

  onLogout() async {
    var response =
        await http.delete(widget.api + "/auth/logout", headers: headers);
    if (response.statusCode == 200 &&
        json.decode(response.body)["success"] == true) {
      _sharedPreferences.clear();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => SignIn(api: widget.api)),
          (Route<dynamic> route) => false);
    } else {
      print(json.decode(response.body));
    }
  }

  Future<void> onRefreshData() {
    return Future.delayed(
      // This is just an arbitrary delay that simulates some network activity.
      const Duration(seconds: 2),
      () => {print("Refreshed")},
    );
  }

  Widget _drawer() {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Icon(
                Icons.account_circle,
                color: Colors.green.shade800,
                size: 96,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.music_note),
            title: Text("Songs"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Songs(api: widget.api)));
            },
          ),
          ListTile(
            leading: Icon(Icons.chat),
            title: Text("News"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push<void>(
                  context, MaterialPageRoute(builder: (context) => Scaffold()));
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text("Profile"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push<void>(
                  context, MaterialPageRoute(builder: (context) => Scaffold()));
            },
          ),
          // Long drawer contents are often segmented.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push<void>(
                  context, MaterialPageRoute(builder: (context) => Scaffold()));
            },
          ),
          // Long drawer contents are often segmented.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout"),
            onTap: () {
              onLogout();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [],
      ),
      drawer: _drawer(),
      body: RefreshIndicator(
          onRefresh: onRefreshData,
          child: Container(
            child: Text("Home Page"),
          )),
    );
  }
}
