import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SstScreen extends StatefulWidget {

  SstScreen({Key key}) : super(key: key);

  @override
  _SstScreenState createState() => _SstScreenState();
}

class _SstScreenState extends State<SstScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SST'),
      ),
    );
  }
}
