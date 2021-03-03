
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin_example/models/SmallcasesDTO.dart';
import 'package:scgateway_flutter_plugin_example/screens/SmallcaseDetails.dart';
import '../Styles.dart';

class SmallcasesList extends StatelessWidget {

  List<SmallcasesDTO> items;

  // receive data from the FirstScreen as a parameter
  SmallcasesList({Key key, @required this.items}) : super(key: key);

  Widget _listViewItemBuilder(BuildContext context, int index){
    var smallcase = this.items[index];
    return ListTile(
      contentPadding: EdgeInsets.all(10.0),
      leading: _itemThumbnail(smallcase),
      title: _itemTitle(smallcase),
      onTap: () {
        Navigator.push(
            context,
          MaterialPageRoute(
            builder: (context) => SmallcaseDetails(smallcase : smallcase),
          ),
        );
      },
    );
  }

  Widget _itemThumbnail(SmallcasesDTO smallcasesDTO){
    return Container(
      constraints: BoxConstraints.tightFor(width: 100.0),
      child: Image.network("https://assets.smallcase.com/images/smallcases/200/${smallcasesDTO.scid}.png", fit: BoxFit.fitWidth),
    );
  }

  Widget _itemTitle(SmallcasesDTO smallcasesDTO){
    return Text(
        smallcasesDTO.info.name,
        style: Styles.textDefault,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Smallcases')),
      body: ListView.builder(
          itemCount: this.items.length,
          itemBuilder: _listViewItemBuilder
      ),
    );
  }
}