import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:scgateway_flutter_plugin_example/gateway.dart';

class LeadGenScreen extends StatefulWidget {

  LeadGenScreen({Key key}) : super(key: key);

  @override
  _LeadGenScreenState createState() => _LeadGenScreenState();
}

class _LeadGenScreenState extends State<LeadGenScreen> {

  String _name = "", _email = "", _contact = "", _pincode = "";

  Future<void> _executeLeadGen() async {
    // ScgatewayFlutterPlugin.leadGen(_name, _email, _contact, _pincode);
    Gateway.leadGen(_name, _email, _contact, _pincode);
  }

  Widget inputName() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Name '),
        SizedBox(width: 250, height: 30, child: TextField(decoration: InputDecoration(
          filled: true,
          labelText: '',
        ),
          onChanged: (value) {
            setState(() {
              _name = value;
            });
          },
        ),
        )
      ],
    );
  }

  Widget inputEmail() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Email '),
        SizedBox(width: 250, height: 30, child: TextField(decoration: InputDecoration(
          filled: true,
          labelText: '',
        ),
          onChanged: (value) {
            setState(() {
              _email = value;
            });
          },
        ),
        )
      ],
    );
  }

  Widget inputContact() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Contact '),
        SizedBox(width: 250, height: 30, child: TextField(decoration: InputDecoration(
          filled: true,
          labelText: '',
        ),
          onChanged: (value) {
            setState(() {
              _contact = value;
            });
          },
        ),
        )
      ],
    );
  }

  Widget inputPincode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Pin Code '),
        SizedBox(width: 250, height: 30, child: TextField(decoration: InputDecoration(
          filled: true,
          labelText: '',
        ),
          onChanged: (value) {
            setState(() {
              _pincode = value;
            });
          },
        ),
        )
      ],
    );
  }

  Widget btnStarteLeadGen() {
    return SizedBox(width: 300, height: 35, child: RaisedButton(
      onPressed: _executeLeadGen,
      child: const Text('LEAD GEN', style: TextStyle(fontSize: 20)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lead Gen'),
      ),
      body: SafeArea(

        child: ListView(

          padding: EdgeInsets.only(top: 10, left: 15, right: 10),

          children: <Widget>[
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: inputName(),
            ),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: inputEmail(),
            ),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: inputContact(),
            ),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: inputPincode(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: FittedBox(
                alignment: Alignment.center,
                fit: BoxFit.none,
                child: btnStarteLeadGen(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
