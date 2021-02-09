import 'dart:convert';
import 'package:flutter_appl/signin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  Home({Key key, this.api}) : super(key: key);

  final String api;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SharedPreferences _sharedPreferences;

  String _token = "";

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
      _sharedPreferences.commit();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => SignIn(api: widget.api)),
          (Route<dynamic> route) => false);
    } else {
      print(json.decode(response.body));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Flutter Example",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          ElevatedButton.icon(
            label: Text("Logout"),
            onPressed: onLogout,
            icon: Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: new BoxDecoration(color: Colors.white10),
          width: double.infinity,
          child: Column(
            children: [],
          ),
        ),
      ),
    );
  }
}
