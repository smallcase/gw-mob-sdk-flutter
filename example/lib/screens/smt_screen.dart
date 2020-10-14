import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SmtScreen extends StatefulWidget {

  SmtScreen({Key key}) : super(key: key);

  @override
  _SmtScreenState createState() => _SmtScreenState();
}

class _SmtScreenState extends State<SmtScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SMT'),
      ),
    );
  }
}
