import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

import 'package:phonepage/new_contact.dart';
import 'package:phonepage/update_contact.dart';
import 'package:phonepage/jwt_auth.dart';

class Phonepage extends StatefulWidget {
  @override
  _PhonepageState createState() => _PhonepageState();
}

class contactValues {
  final String lname;
  final String fname;
  final List<String> phone;

  contactValues(this.lname, this.fname, this.phone);
}

class _PhonepageState extends State<Phonepage> {
  List users = [];

  @override
  void initState() {
    super.initState();
    this.fetchUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final String getUrl = "https://phonelist2.herokuapp.com/api/friends/";
  List<dynamic> _users = [];
  fetchUser() async {
    var result = await http.get(Uri.parse(getUrl));
    setState(() {
      _users = jsonDecode(result.body);
    });
  }

  String _names(dynamic user) {
    return user['fname'] + " " + user['lname'];
  }

  Future<http.Response> deleteContact(String id) {
    return http.delete(
        Uri.parse('https://phonelist2.herokuapp.com/delete/' + id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff303030),
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
                Icons.logout_rounded,
                color: Colors.white
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return Authenticate();
              }));
            }
        ),
        title: Text('Phonepage'),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(
                Icons.add_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return NewContacts();
                }));
              }
          )
        ],
      ),
      body: Container(
        child: FutureBuilder<List<dynamic>>(
          builder: (context, snapshot) {
            return _users.length != 0
                ? RefreshIndicator(
              child: ListView.builder(
                  padding: EdgeInsets.all(12.0),
                  itemCount: _users.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Dismissible(
                      key: Key(_users[index].toString()),
                      direction: DismissDirection.horizontal,
                      background: Container(
                        margin: const EdgeInsets.all(10),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.delete_rounded,
                                  color: Colors.black54),
                              Text("Delete",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0,
                                      color: Colors.black38))
                            ]),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      secondaryBackground: Container(
                        margin: const EdgeInsets.all(10),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Icon(Icons.edit_rounded,
                                  color: Colors.black54),
                              Text("Edit",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0,
                                      color: Colors.black38))
                            ]),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        if(direction == DismissDirection.endToStart) {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) =>
                              UpdateContacts(specificID: _users[index]['_id'].toString())
                              )
                          );
                          String editContact = _users[index]['fname'].toString() + " " + _users[index]['lname'].toString();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('You are editing $editContact from your Contacts', style: TextStyle(color: Colors.black87)),
                              backgroundColor: Colors.greenAccent,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return false;
                        } else if (direction == DismissDirection.startToEnd) {
                          String id = _users[index]['_id'].toString();
                          String delContact = _users[index]['fname'].toString() + " " + _users[index]['lname'].toString();
                          deleteContact(id);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('You deleted $delContact from your Contacts'),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return true;
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              tileColor: Color(0xff1f1f1f),
                              leading: Icon(Icons.account_circle_rounded, size: 30, color: Colors.white,),
                              title: Text(_names(_users[index]),
                                style: TextStyle(
                                    color: Color(0xffc8c8c8),
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18),
                              ),
                              onTap: () {
                                List<int> listNumbers = [];
                                for (int i = 0; i < _users[index]['phone'].length; i++) {
                                  listNumbers.add(i + 1);
                                }
                                showDialog<String>(
                                  barrierColor: Color(0xff1f1f1f),
                                  context: context,
                                  builder: (BuildContext context) =>
                                      Padding(
                                        padding: const EdgeInsets.all(0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context).size.width + 90,
                                              height: MediaQuery.of(context).size.height - 50,
                                              child: AlertDialog(
                                                contentPadding: EdgeInsets.fromLTRB(55,13,3,200),
                                                elevation: 0,
                                                backgroundColor: Colors.transparent,
                                                titlePadding: EdgeInsets.all(1.0),
                                                title: RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      WidgetSpan(
                                                        child: Icon(
                                                          Icons.arrow_back_rounded,
                                                          size: 19,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                          text:'  Back to Phonelist\n\n',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                          ),
                                                          recognizer: TapGestureRecognizer()
                                                            ..onTap = () {
                                                              Navigator.pop(context);
                                                            }
                                                      ),
                                                      TextSpan(
                                                        text: "        ",
                                                      ),
                                                      WidgetSpan(
                                                          child: Icon(
                                                              Icons.account_circle_rounded,
                                                              size: 30,
                                                              color: Colors.white
                                                          )
                                                      ),
                                                      TextSpan(
                                                          text: " ${_names(_users[index])}",
                                                          style: TextStyle (
                                                            fontSize: 30,
                                                            fontWeight: FontWeight.bold,
                                                          )
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                content: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: List.generate(
                                                          listNumbers.length, (iter) {
                                                          return Column(
                                                            children: [
                                                              SizedBox(
                                                                height: 18,
                                                              ),
                                                              RichText(
                                                                text: TextSpan(
                                                                  children: [
                                                                    WidgetSpan(
                                                                        child: Icon(
                                                                            Icons.phone,
                                                                            size: 16,
                                                                            color: Colors.white
                                                                        )
                                                                    ),
                                                                    TextSpan(
                                                                      text: "  ${_users[index]['phone'][iter].toString()}",
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              onRefresh: getContacts,
            )
              : Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white24),
                backgroundColor: Colors.white10,
              ));
          },
        ),

      ),
    );
  }

  Future<void> getContacts() async {
    setState(() {
      fetchUser();
    });
  }
}
