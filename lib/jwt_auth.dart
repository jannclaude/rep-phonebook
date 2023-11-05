// import 'dart:ui';
// import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  var email;
  var password;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: const Color(0xff303030),
        resizeToAvoidBottomInset: false,
        child: Container(
            padding: const EdgeInsets.fromLTRB(13, 230, 13, 0),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'images/phonepage_icon.png'
                ),
                alignment: Alignment(0,-0.7),
                scale: 8,
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Phonepage',
                  style: new TextStyle(
                      fontSize: 30,
                      fontFamily: 'system',
                      color: Colors.white,
                      decoration: TextDecoration.none
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 18,
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CupertinoTextField(
                      keyboardType: TextInputType.emailAddress,
                      placeholder: "Email/Username",
                      onChanged: (value) {
                        email = value;
                      },
                      style: TextStyle(
                        height: 1.5,
                      ),
                    )
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CupertinoTextField(
                      keyboardType: TextInputType.visiblePassword,
                      placeholder: "Password",
                      obscureText: true,
                      onChanged: (value) {
                        password = value;
                      },

                      style: TextStyle(
                        height: 1.5,
                      ),
                    )
                ),
                SizedBox(
                  height: 24,
                ),
                ElevatedButton(
                  child: Text('Log In'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () async {
                    await login(email, password);
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String? token = prefs.getString("token");
                    String respL = prefs.getString("responseL") ?? "default_value";
                    var res = respL.replaceAll('msg', '');
                    var resL = res.replaceAll(new RegExp(r'\W'),' ');
                    if (token != null) {
                        Navigator.of(context).pushNamedAndRemoveUntil('/contact list', (Route<dynamic> route) => false);
                    } else {
                      Fluttertoast.showToast(
                        msg: resL.toString(),
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Color(0xff303030),
                        textColor: Colors.redAccent
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 3,
                ),
                ElevatedButton(
                    child: Text('Sign Up'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white30,
                    ),
                    onPressed: () async {
                      await signup(email, password);
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      String? token = prefs.getString("token");
                      String respS = prefs.getString("responseS") ?? "default_value";
                      var res = respS.replaceAll(new RegExp(r'msg'), '');
                      var resS = res.replaceAll(new RegExp(r'\W'),' ');
                      if (token != null) {
                        Navigator.of(context).pushNamedAndRemoveUntil('/contact list', (Route<dynamic> route) => false);
                      } else {
                        Fluttertoast.showToast(
                            msg: resS.toString(),
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Color(0xff303030),
                            textColor: Colors.redAccent
                        );
                      }
                    }),
                SizedBox(
                  height: 18,
                ),
                Text(
                  'To sign up, enter your email and password above\nand click Sign up.',
                  style: new TextStyle(
                      fontSize: 13,
                      fontFamily: 'system',
                      color: Colors.white,
                      decoration: TextDecoration.none
                  ),
                  textAlign: TextAlign.center,

                )
              ],
            )
        )
    );
  }
}

login(email, password) async {
  final Uri url = Uri.parse("https://phonelist.onrender.com/login"); // iOS

  final http.Response response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'email': email,
      'password': password,
    }),
  );
  print(response.body);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var parse = jsonDecode(response.body);

  await prefs.setString('token', parse["token"]);
  await prefs.setString('responseL', response.body.toString());
}

signup(email, password) async {
  final Uri url = Uri.parse("https://phonelist.onrender.com/signup");

  final http.Response response = await http.post(
    url,
    headers: <String, String> {
      'Content-Type': 'application/json; charset=UTF-8'
    },
    body: jsonEncode(<String, String> {
      'email': email,
      'password': password
    }),
  );
  print(response.body);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var parse = jsonDecode(response.body);

  await prefs.setString('token', parse["token"]);
  await prefs.setString('responseS', response.body.toString());
}