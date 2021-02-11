import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appl/components/widgets.dart';
import 'package:flutter_appl/pages/songs-detail.dart';
import 'package:flutter_appl/signin.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Songs extends StatefulWidget {
  Songs({Key key, this.api}) : super(key: key);

  final String api;

  @override
  _SongsState createState() => _SongsState();
}

class _SongsState extends State<Songs> {
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
    debugPrint("On initial state...");
  }

  Future<void> onRefreshData() {
    return Future.delayed(
      // This is just an arbitrary delay that simulates some network activity.
      const Duration(seconds: 2),
      () => {print("Refreshed")},
    );
  }

  Widget _listBuilder(BuildContext context, int index) {
    if (index >= _itemsLength) return null;

    return SafeArea(
      top: false,
      bottom: false,
      child: Hero(
        tag: index,
        child: HeroAnimatingSongCard(
          imageUri: "https://placehold.it/256x256?text=Hero $index",
          song: "Hero $index",
          color: Colors.green,
          heroAnimation: AlwaysStoppedAnimation(0),
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (context) => SongDetailTab(
                id: index,
                song: "Hero $index",
                color: Colors.green,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Songs"),
        actions: [],
      ),
      body: RefreshIndicator(
        onRefresh: onRefreshData,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 12),
          itemBuilder: _listBuilder,
        ),
      ),
    );
  }
}
