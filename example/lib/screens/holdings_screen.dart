import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HoldingsScreen extends StatefulWidget {

  HoldingsScreen({Key key}) : super(key: key);

  @override
  _HoldingsScreenState createState() => _HoldingsScreenState();
}

class _HoldingsScreenState extends State<HoldingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Holdings'),
      ),
    );
  }
}
