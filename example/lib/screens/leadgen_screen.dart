import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LeadGenScreen extends StatefulWidget {

  LeadGenScreen({Key key}) : super(key: key);

  @override
  _LeadGenScreenState createState() => _LeadGenScreenState();
}

class _LeadGenScreenState extends State<LeadGenScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LeadGen'),
      ),
    );
  }
}
