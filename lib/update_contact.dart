import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:phonepage/listDB.dart';

class contactValues {
  final String lname;
  final String fname;
  final List<String> phone;

  contactValues(this.lname, this.fname, this.phone);
}

Future<SpecificContact> fetchSpecificContact(String id) async {
  final response = await http.get(Uri.parse('https://phonelist.onrender.com/api/friends/' + id));
  if (response.statusCode == 200) {
    return SpecificContact.fromJson(json.decode(response.body));
  } else {
    throw Exception('Status [Failed]: Cannot load Contact');
  }
}

class SpecificContact {
  SpecificContact({
    required this.phone,
    required this.id,
    required this.fname,
    required this.lname,
    required this.v,
  });

  List<String> phone;
  String id;
  String fname;
  String lname;
  int v;

  factory SpecificContact.fromJson(Map<String, dynamic> json) =>
      SpecificContact(
        phone: List<String>.from(json["phone"].map((x) => x)),
        id: json["_id"],
        fname: json["fname"],
        lname: json["lname"],
        v: json["__v"],
      );
}

class UpdateContacts extends StatefulWidget {
  final String specificID;

  const UpdateContacts({Key? key, required this.specificID}) : super(key: key);
  @override
  _UpdateContactsState createState() => _UpdateContactsState(specificID);
}

class _UpdateContactsState extends State<UpdateContacts> {
  String specificID;
  _UpdateContactsState(this.specificID);

  int key = 0, checkButton = 0, count = 1;

  late TextEditingController _fnameController;
  late TextEditingController _lnameController;

  List<TextEditingController> _numberController = <TextEditingController>[
    TextEditingController()
  ];

  List<contactValues> contactsAppend = <contactValues>[];

  late Future<SpecificContact> fetchSpecificId;

  void saveContact() {
    List<String> phoneNums = <String>[];
    for (int i = 0; i < count; i++) {
      phoneNums.add(_numberController[i].text);
    }

    setState(() {
      contactsAppend.insert(0,contactValues(_lnameController.text, _fnameController.text, phoneNums));
    });
  }

  @override
  void initState() {
    super.initState();
    _fnameController = TextEditingController();
    _lnameController = TextEditingController();
    fetchSpecificId = fetchSpecificContact(specificID);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff303030),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Update Contact'),
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
                            todo: contactsAppend, specificID: specificID)),
                        (_) => false);
              }
          )
        ],
      ),
      body: GestureDetector(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: FutureBuilder<SpecificContact>(
            future: fetchSpecificId,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                String? fnameData = Text(snapshot.data!.fname.toString()).data;
                String? lnameData = Text(snapshot.data!.lname.toString()).data;
                List<String> listphone = <String>[];
                for (int i = 0; i < snapshot.data!.phone.length; i++) {
                  listphone.add(snapshot.data!.phone[i]);
                }
                return nameText(fnameData!, lnameData!, listphone, context);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xff1c1c1c))));
            },
          ),
        ),
      ),
    );
  }

  nameText(String fnameCon, String lnameCon, List<String> listphone, context) {
    return Container(
      margin: EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _fnameController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: fnameCon,
              hintStyle: TextStyle(color: Colors.white38),
              fillColor: Color(0xff1f1f1f),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.all(15),
            ),
          ),
          SizedBox(height: 18),
          TextFormField(
            controller: _lnameController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: lnameCon,
              hintStyle: TextStyle(color: Colors.white38),
              fillColor: Color(0xff1f1f1f),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.all(15),
            ),
          ),
          SizedBox(height: 30),
          Flexible(
            child: ListView.builder(
                reverse: true,
                shrinkWrap: true,
                itemCount: count,
                itemBuilder: (context, index) {
                  return phoneList(index, context);
                }),
          ),
        ],
      ),
    );
  }
  phoneList(int key, context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(1.5),
          child: SizedBox(
            width: 54,
            height: 54,
            child: addRemoveNum(key == checkButton, key),
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

  Widget addRemoveNum(bool isTrue, int index) {
    return InkWell(
      onTap: () {
        if (isTrue) {
          setState(() {
            count++;
            checkButton++;
            _numberController.insert(0, TextEditingController());
          });
        } else {
          setState(() {
            count--;
            checkButton--;
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
        ),
        child: Icon(
          (isTrue) ? Icons.add : Icons.remove,
          color: Colors.black45,
        ),
      ),
    );
  }
}

class CheckScreen extends StatelessWidget {
  final List<contactValues> todo;
  final String specificID;

  const CheckScreen({Key? key, required this.todo, required this.specificID})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<http.Response> fetchContact(String fname, String lname, List phone) {
      return http.patch(
        Uri.parse('https://phonelist.onrender.com/update/' + specificID),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'fname': fname,
          'lname': lname,
          'phone': phone,
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
            fetchContact(todo[index].fname, todo[index].lname,
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
