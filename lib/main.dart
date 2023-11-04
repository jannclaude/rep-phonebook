import 'package:phonepage/jwt_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:phonepage/listDB.dart';
import 'new_contact.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
            statusBarColor: Color(0xff1f1f1f),
            systemNavigationBarColor: Color(0xff1f1f1f)
        )
    );//color set to transparent or set your own color

    return MaterialApp(
        title: 'Phonepage',
        theme: ThemeData(
            appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.light,
            ),
            primaryColor: Color(0xff1f1f1f),
            textSelectionTheme: TextSelectionThemeData(
                cursorColor: Color(0xffc8c8c8),
                selectionColor: Color(0xffc8c8c8),
                selectionHandleColor: Color(0xffc8c8c8),
            ),
            hintColor: Color(0xff303030)
        ),
        debugShowCheckedModeBanner: false,
        //
        home: Authenticate(),
        routes: <String, WidgetBuilder>{
          '/authenticate': (BuildContext context) => new Authenticate(),
          '/contact list': (BuildContext context) => new Phonepage(),
          '/new contact': (BuildContext context) => new NewContacts(),
        }
    );
  }

}