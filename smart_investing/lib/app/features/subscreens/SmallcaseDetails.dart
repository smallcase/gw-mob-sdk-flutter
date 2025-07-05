import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:clipboard/clipboard.dart';

import '../../global/SmartInvestingAppRepository.dart';
import 'SmallcaseNews.dart';

class SmallcaseDetails extends StatelessWidget {
  dynamic smallcase;

  SmallcaseDetails({Key? key, this.smallcase}) : super(key: key);

  Future<void> _buySmallcase(BuildContext context) async {
    var orderConfig = {"type": "BUY", "scid": smallcase["scid"]};

    _placeSmtOrder(ScgatewayIntent.TRANSACTION, orderConfig, context);
  }

  Future<void> _placeSmtOrder(
      String intent, Object orderConfig, BuildContext context) async {
    repository
        .triggerTransaction(intent, orderConfig, false, context)
        .then((value) => repository.showAlertDialog(value, context));
  }

  Future<void> _getSmallcaseNews(BuildContext context) async {
    ScgatewayFlutterPlugin.getSmallcaseNews(smallcase["scid"] ?? "")
        .then((value) => _populateSmallcaseNews(value ?? "", context));
  }

  void _populateSmallcaseNews(String jsonString, BuildContext context) {
    final Map<String, dynamic> responseData = jsonDecode(jsonString);

    var newsList = responseData['data']['news'] as List;
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SmallcaseNews(smallcaseNews: newsList),
        ));
  }

  Future<void> _showAlertDialog(String message, BuildContext context) async {
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

  Widget smallcaseInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          constraints: BoxConstraints.tightFor(width: 60.0),
          child: Image.network(
              "https://assets.smallcase.com/images/smallcases/200/${smallcase["scid"]}.png",
              fit: BoxFit.fitWidth),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(this.smallcase["info"]["name"] ?? ""),
            Text(
              this.smallcase["info"]["shortDescription"] ?? "",
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            )
          ],
        )),
      ],
    );
  }

  Widget news(BuildContext context) {
    return SizedBox(
        width: 300,
        height: 35,
        child: ElevatedButton(
          onPressed: () => _getSmallcaseNews(context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('NEWS', style: TextStyle(fontSize: 20)),
        ));
  }

  Widget historical() {
    return SizedBox(
        width: 300,
        height: 35,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
              foregroundColor: Colors.green,
              padding: EdgeInsets.only(top: 10, left: 15, right: 10)),
          child: const Text('HISTORICAL', style: TextStyle(fontSize: 20)),
        ));
  }

  Widget purchase(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Column(
          children: [
            Text("Min Amount"),
            const SizedBox(height: 10),
            Text((this.smallcase["stats"]["minInvestAmount"] ?? "").toString())
          ],
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(foregroundColor: Colors.green),
          onPressed: () => _buySmallcase(context),
          child: const Text('BUY', style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(smallcase["info"]["name"] ?? "")),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(top: 10, left: 15, right: 10),
          children: <Widget>[
            smallcaseInfo(),
            SizedBox(height: MediaQuery.of(context).size.height / 3),
            Align(
              alignment: Alignment.bottomCenter,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  news(context),
                  const SizedBox(height: 30),
                  historical(),
                  const SizedBox(height: 30),
                  purchase(context)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
