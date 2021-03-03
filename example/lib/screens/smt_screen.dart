import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin_example/models/SmallcasesDTO.dart';
import 'package:scgateway_flutter_plugin_example/screens/SmallcasesList.dart';

import '../Styles.dart';
import '../gateway.dart';

class SmtScreen extends StatefulWidget {

  SmtScreen({Key key}) : super(key: key);

  @override
  _SmtScreenState createState() => _SmtScreenState();
}

class _SmtScreenState extends State<SmtScreen> {

  @override
  void initState() {
    super.initState();
    Gateway.getAllSmallcases().then((value) => _populateSmallCases(value));
  }

  List<SmallcasesDTO> items = [];

  void _showSmallcases(BuildContext context) async {

    // Gateway.getAllSmallcases().then((value) => _populateSmallCases(value));

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SmallcasesList(items: items),
        ));

  }

  Future<void> _populateSmallCases(String jsonString) async {

    final Map<String, dynamic> responseData = jsonDecode(jsonString);

    print("ResponseData = $responseData");

    var list = responseData['data']['smallcases'] as List;
    // var list = responseData['smallcases'] as List;
    // print("List runtime type = $list.runtimeType");


    List<SmallcasesDTO> smallcases = list.map((i) =>
      SmallcasesDTO.fromJson(i)
    ).toList();

    setState(() {
      items = smallcases;
    });

    print("items: $items");

  }


  //----------------------------------  WIDGETS -------------------------------------- //

  Widget smallcases(BuildContext context) {
    return SizedBox(width: 300, height: 35, child: RaisedButton(
      onPressed: () => _showSmallcases(context),
      child: const Text('SMALLCASES', style: TextStyle(fontSize: 20)),
    ));
  }

  Widget userInvestments() {
    return SizedBox(width: 300, height: 35, child: RaisedButton(
      onPressed: () => _showSmallcases(context),
      child: const Text('USER INVESTMENTS', style: TextStyle(fontSize: 20)),
    ));
  }

  Widget exitedSmallcases() {
    return SizedBox(width: 300, height: 35, child: RaisedButton(
      onPressed: () => _showSmallcases(context),
      child: const Text('EXITED SMALLCASES', style: TextStyle(fontSize: 20)),
    ));
  }

  // Widget _listViewItemBuilder(BuildContext context, int index){
  //   var smallcase = this.items[index];
  //   return ListTile(
  //     contentPadding: EdgeInsets.all(10.0),
  //     leading: _itemThumbnail(smallcase),
  //     title: _itemTitle(smallcase),
  //   );
  // }
  //
  // Widget _itemThumbnail(SmallcasesDTO smallcasesDTO){
  //   return Container(
  //     constraints: BoxConstraints.tightFor(width: 100.0),
  //     child: Image.network("https://assets.smallcase.com/images/smallcases/200/${smallcasesDTO.scid}.png", fit: BoxFit.fitWidth),
  //   );
  // }
  //
  // Widget _itemTitle(SmallcasesDTO smallcasesDTO){
  //   return Text(smallcasesDTO.info.name, style: Styles.textDefault);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SMT'),
      ),
      body: SafeArea(

        child: ListView(

          padding: EdgeInsets.only(top: 10, left: 15, right: 10),

          children: <Widget>[
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: smallcases(context),
            ),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: userInvestments(),
            ),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.none,
              child: exitedSmallcases(),
            )
          ],
        ),
      ),
    );
  }
}
