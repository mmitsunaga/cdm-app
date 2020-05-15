import 'package:flutter/material.dart';
import 'package:chatter/widget/chat_screen.dart';

void main () {
  runApp(MaterialApp(
    title: 'Chatter',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor: Colors.blueAccent,
      iconTheme: IconThemeData (
        color: Colors.blue
      )
    ),
    home: ChatScreen(),
  ));
}
