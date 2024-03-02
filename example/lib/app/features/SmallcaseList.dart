
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin_example/Styles.dart';
import 'package:scgateway_flutter_plugin_example/app/features/subscreens/SmallcaseDetails.dart';

class SmallcasesList extends StatelessWidget {

  List<dynamic>? items;

  // receive data from the FirstScreen as a parameter
  SmallcasesList({Key? key,  this.items}) : super(key: key);

  Widget _listViewItemBuilder(BuildContext context, int index){
    var smallcase = this.items![index];
    return ListTile(
      contentPadding: EdgeInsets.all(10.0),
      leading: _itemThumbnail(smallcase["scid"]),
      title: _itemTitle(smallcase["info"]["name"]),
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

  Widget _itemThumbnail(String? scid){
    return Container(
      constraints: BoxConstraints.tightFor(width: 100.0),
      child: Image.network("https://assets.smallcase.com/images/smallcases/200/${scid}.png", fit: BoxFit.fitWidth),
    );
  }

  Widget _itemTitle(String? name){
    return Text(
        name ?? "",
        style: Styles.textDefault,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Smallcases')),
      body: ListView.builder(
          itemCount: this.items?.length,
          itemBuilder: _listViewItemBuilder
      ),
    );
  }
}