import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';

import 'package:phonepage/listDB.dart';

class NewContacts extends StatefulWidget {
  @override
  _NewContactsState createState() => _NewContactsState();
}

class ContactSchema {
  final String lname;
  final String fname;
  final List<String> phone;

  ContactSchema(this.lname, this.fname, this.phone);
}

class _NewContactsState extends State<NewContacts> {
  int key = 0, checkAdd = 0, listNumber = 1, _count = 1;
  String val = '';

  late TextEditingController _lnameController, _fnameController;

  List<TextEditingController> _numberController = <TextEditingController>[
    TextEditingController()
  ];

  List<ContactSchema> contactsAppend = <ContactSchema>[];

  void saveContact() {
    List<String> phoneList = <String>[];
    for (int i = 0; i < _count; i++) {
      phoneList.add(_numberController[i].text);
    }

    setState(() {
      contactsAppend.insert(0, ContactSchema(_lnameController.text, _fnameController.text, phoneList));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _lnameController = TextEditingController();
    _fnameController = TextEditingController();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff303030),
      appBar: AppBar(
        centerTitle: true,
        title: Text('New Contact'),
        actions: [
          IconButton(
              icon: Icon(
                Icons.save_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                saveContact();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CheckScreen(
                            todo: contactsAppend)),
                        (_) => false);
              }
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _fnameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: ' First Name',
                hintStyle: TextStyle(color: Colors.white38),
                fillColor: Color(0xff1f1f1f),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.all(18),
              ),
            ),
            SizedBox(height: 18),
            TextFormField(
              controller: _lnameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: ' Last Name',
                hintStyle: TextStyle(color: Colors.white38),
                fillColor: Color(0xff1f1f1f),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.all(18),
              ),
            ),
            SizedBox(height: 30),
            Flexible(
              child: ListView.builder(
                  reverse: true,
                  shrinkWrap: true,
                  itemCount: _count,
                  itemBuilder: (context, index) {
                    return _phoneList(index, context);
                  }),
            ),
            SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }

  _phoneList(int key, context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(1.5),
          child: SizedBox(
            width: 54,
            height: 54,
            child: _addRemoveNum(key == checkAdd, key),
          ),
        ),
        Expanded(
          child: TextFormField(
            style: TextStyle(color: Colors.white),
            controller: _numberController[key],
            maxLength: 11,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            decoration: new InputDecoration(
              prefixIcon: Icon(
                Icons.phone,
                size: 23,
                color: Colors.white,
              ),
              hintText: ' Phone Number',
              hintStyle: TextStyle(color: Colors.white38),
              fillColor: Color(0xff1f1f1f),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8)
                ),
                borderSide: BorderSide(
                  color: Color(0xff1f1f1f),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addRemoveNum(bool isTrue, int index) {
    return InkWell(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        if (isTrue) {
          setState(() {
            _count++;
            checkAdd++;
            listNumber++;
            _numberController.insert(0, TextEditingController());
          });
        } else {
          setState(() {
            _count--;
            checkAdd--;
            listNumber--;
            _numberController.removeAt(index);
          });
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: (isTrue) ? Colors.green : Colors.redAccent,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8)
            ),
        ), // Add,remove phone numbers
        child: Icon(
          (isTrue) ? Icons.add : Icons.remove,
          color: Colors.black45,
        ),
      ),
    );
  }
}

class CheckScreen extends StatelessWidget {
  final List<ContactSchema> todo;

  const CheckScreen({Key? key, required this.todo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<http.Response> saveContact(String fname, String lname, List phoneList) {
      return http.post(
        Uri.parse('https://phonelist2.herokuapp.com/api/friends/add'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'fname': fname,
          'lname': lname,
          'phone': phoneList,
        }),
      );
    }

    List<int> listNumbers = [];
    for (int i = 0; i < todo[0].phone.length; i++) {
      listNumbers.add(i + 1);
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Color(0xff303030),
        appBar: AppBar(
          title: Text('Confirm'),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.done_sharp,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Phonepage()),
                          (_) => false);
                }
            )
          ],
        ),
        body: ListView.builder(
          itemCount: todo.length,
          itemBuilder: (context, index) {
            saveContact(todo[index].fname, todo[index].lname,
                todo[index].phone);
            return Container(
              margin: EdgeInsets.all(18),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: ' ${todo[index].fname}',
                      hintStyle: TextStyle(color: Colors.white),
                      fillColor: Color(0xff1f1f1f),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.all(18),
                    ),
                  ),
                  SizedBox(height: 18),
                  TextFormField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: '${todo[index].lname}',
                      hintStyle: TextStyle(color: Colors.white),
                      fillColor: Color(0xff1f1f1f),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.all(18),
                    ),
                  ),
                  SizedBox(height: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      listNumbers.length,
                          (index) {
                        return Container(
                          child: Column(
                            children: [
                              TextFormField(
                                enabled: false,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.phone,
                                      size: 23,
                                      color: Colors.white,
                                    ),
                                    hintText: '${todo[0].phone[index].toString()}',
                                    hintStyle: TextStyle(color: Colors.white),
                                    fillColor: Color(0xff1f1f1f),
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: EdgeInsets.all(18)
                                ),
                              ),
                              SizedBox(
                                height: 28,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

  }
}