
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:scgateway_flutter_plugin_example/models/NewsDataDTO.dart';
import 'package:scgateway_flutter_plugin_example/models/SmallcasesDTO.dart';
import 'package:scgateway_flutter_plugin_example/gateway.dart';
import 'package:scgateway_flutter_plugin_example/screens/smallcase_news.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
import '../Styles.dart';

class SmallcaseDetails extends StatelessWidget {

  SmallcasesDTO smallcase;

  SmallcaseDetails({Key key, @required this.smallcase}) : super(key: key);

  Future<void> _buySmallcase(BuildContext context) async {

    var orderConfig = {"type": "BUY", "scid" : smallcase.scid};

    _placeSmtOrder(ScgatewayIntent.TRANSACTION, orderConfig, context);

  }

  Future<void> _placeSmtOrder(String intent, Object orderConfig, BuildContext context) async {

    Gateway.getTransactionId(intent, orderConfig).then((value) => _showAlertDialog(value, context));
  }

  Future<void> _getSmallcaseNews(BuildContext context) async {

    Gateway.getSmallcaseNews(smallcase.scid).then((value) => _populateSmallcaseNews(value, context));
  }

  void _populateSmallcaseNews(String jsonString, BuildContext context) {

    final Map<String, dynamic> responseData = jsonDecode(jsonString);

    print("News Response Data: $responseData");

    var newsList = responseData['data']['news'] as List;

    List<NewsDataDTO> news = newsList.map((e) =>
      NewsDataDTO.fromJson(e)
    ).toList();

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SmallcaseNews(smallcaseNews: news),
        ));
  }

  Future<void> _showAlertDialog(String message, BuildContext context) async {

    // ClipboardManager.copyToClipBoard(message);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Gateway'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message)
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(onPressed: () {
              ClipboardManager.copyToClipBoard(message);
            }, child: Text('Copy')
            )
          ],
        );
      },
    );
  }

  Widget smallcaseInfo() {
    return
      Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          constraints: BoxConstraints.tightFor(width: 60.0),
          child: Image.network("https://assets.smallcase.com/images/smallcases/200/${smallcase.scid}.png", fit: BoxFit.fitWidth),
        ),
        const SizedBox(width : 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(this.smallcase.info.name),
            Text(
              this.smallcase.info.shortDescription,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            )
          ],
        )
        ),
      ],
    );
  }

  Widget news(BuildContext context) {
    return SizedBox(width: 300, height: 35, child: RaisedButton(
      onPressed: () => _getSmallcaseNews(context),
      color: Colors.green,
      child: const Text('NEWS', style: TextStyle(fontSize: 20)),
    )
    );
  }

  Widget historical() {
    return SizedBox(width: 300, height: 35, child: RaisedButton(
      padding: EdgeInsets.only(top: 10, left: 15, right: 10),
      onPressed: () {},
      color: Colors.green,
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
            Text(this.smallcase.stats.minInvestAmount.toString())
          ],
        ),
        RaisedButton(
          color: Colors.green,
          onPressed: () => _buySmallcase(context),
          child: const Text('BUY', style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(smallcase.info.name)),
      body: SafeArea(

        child: ListView(

          padding: EdgeInsets.only(top: 10, left: 15, right: 10),

          children: <Widget>[
            smallcaseInfo(),

            SizedBox(height: MediaQuery.of(context).size.height/ 3),

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