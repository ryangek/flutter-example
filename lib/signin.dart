import 'dart:convert';
import 'package:flutter_appl/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'components/loader.dart';

class SignIn extends StatefulWidget {
  SignIn({Key key, this.api}) : super(key: key);

  final String api;

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  bool _togglePasswordDisplay = false;
  bool _isLoading = false;
  String _email = "";
  String _password = "";

  Map<String, String> get headers => {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

  signIn(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map<String, dynamic> data = {"email": email, "password": password};

    // debugging request data
    print(json.encode(data));

    var response = await http.post(
      widget.api + '/auth/login',
      headers: headers,
      body: json.encode(data),
    );

    // debugging response data
    print(json.decode(response.body));

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
        var user = json.decode(response.body)["user"];
        sharedPreferences.setString('_uuid', user["uuid"]);
        sharedPreferences.setString('_email', user["email"]);
        sharedPreferences.setString('_name', user["name"]);
        sharedPreferences.setString('_token', user["access_token"]);

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => Home(api: widget.api)),
            (Route<dynamic> route) => false);
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    print(widget.api);
    debugPrint("On initial state...");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: new BoxDecoration(color: Colors.white10),
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(50.0, 100.0, 50.0, 100.0),
          child: Column(
            // children: _counters,
            children: [
              Container(
                padding: EdgeInsets.only(left: 50.0, right: 50.0),
                margin: EdgeInsets.only(bottom: 50.0),
                child: Image.asset('images/free.png'),
              ),
              _isLoading
                  ? Loader()
                  : Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(fontSize: 18.0),
                            decoration: const InputDecoration(
                              hintText: 'Enter your email',
                              suffixIcon: Padding(
                                padding: EdgeInsets.all(1.0),
                                child: Icon(Icons.email),
                              ),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter email';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              setState(() {
                                _email = value;
                              });
                            },
                          ),
                          TextFormField(
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: !_togglePasswordDisplay,
                            style: TextStyle(fontSize: 18.0),
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _togglePasswordDisplay =
                                        !_togglePasswordDisplay;
                                  });
                                },
                                icon: Icon(Icons.remove_red_eye),
                              ),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter password';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              setState(() {
                                _password = value;
                              });
                            },
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  _formKey.currentState.save();
                                  if (_formKey.currentState.validate()) {
                                    // Process signing in.
                                    signIn(_email, _password);
                                  }
                                },
                                child: Text('Submit'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
