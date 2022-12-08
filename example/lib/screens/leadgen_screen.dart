import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin_example/gateway.dart';

class LeadGenScreen extends StatefulWidget {
  LeadGenScreen({Key key}) : super(key: key);

  @override
  _LeadGenScreenState createState() => _LeadGenScreenState();
}

class _LeadGenScreenState extends State<LeadGenScreen> {
  String _name = "", _email = "", _contact = "", _pincode = "";
  bool showLoginCta = true;

  Future<void> _executeLeadGen({bool withLoginCta = false}) async {
    // Gateway.leadGen(_name, _email, _contact, _pincode);
    if (withLoginCta) {
      final res = await Gateway.leadGenWithLoginCta(_name, _email, _contact,
          showLoginCta: showLoginCta);
      _showAlertDialog(res);
      return;
    }
    Gateway.leadGenWithStatus(_name, _email, _contact)
        .then((value) => _showAlertDialog(value));
  }

  Future<void> _logout() async {
    Gateway.logout().then((value) => _showAlertDialog(value));
  }

  Future<void> _showAlertDialog(String message) async {
    if (message != null && message.isNotEmpty) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Gateway'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[Text(message)],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                  onPressed: () {
                    FlutterClipboard.copy(message);
                  },
                  child: Text('Copy'))
            ],
          );
        },
      );
    }
  }

  Widget inputName() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Name '),
        SizedBox(
          width: 250,
          height: 30,
          child: TextField(
            decoration: InputDecoration(
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
        SizedBox(
          width: 250,
          height: 30,
          child: TextField(
            decoration: InputDecoration(
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
        SizedBox(
          width: 250,
          height: 30,
          child: TextField(
            decoration: InputDecoration(
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

  Widget btnStartLeadGen() {
    return SizedBox(
        width: 300,
        height: 35,
        child: ElevatedButton(
          onPressed: _executeLeadGen,
          child: const Text('LEAD GEN', style: TextStyle(fontSize: 20)),
        ));
  }

  Widget btnLogoutUser() {
    return SizedBox(
        width: 300,
        height: 35,
        child: ElevatedButton(
          onPressed: _logout,
          child: const Text('Logout User', style: TextStyle(fontSize: 20)),
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
            // FittedBox(
            //   alignment: Alignment.centerLeft,
            //   fit: BoxFit.none,
            //   child: inputPincode(),
            // ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: FittedBox(
                alignment: Alignment.center,
                fit: BoxFit.none,
                child: btnStartLeadGen(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Show Login CTA?"),
                Switch.adaptive(
                  value: showLoginCta,
                  onChanged: (value) {
                    setState(() {
                      showLoginCta = value;
                    });
                  },
                ),
              ],
            ),
            ElevatedButton(
                onPressed: () => _executeLeadGen(withLoginCta: true),
                child: const Text('LEAD GEN with LoginCTA',
                    style: TextStyle(fontSize: 20))),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: FittedBox(
                alignment: Alignment.center,
                fit: BoxFit.none,
                child: btnLogoutUser(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
