
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class SmallcaseNews extends StatelessWidget {

  List<dynamic>? smallcaseNews;

  SmallcaseNews({Key? key,  this.smallcaseNews}) : super(key: key);

  Widget _listViewItemBuilder(BuildContext context, int index){
    var smallcase = this.smallcaseNews![index];
    return ListTile(
      contentPadding: EdgeInsets.all(10.0),
      title: _itemTitle(smallcase["headline"])
    );
  }

  Widget _itemTitle(String? newsData){
    return Text(
      newsData ?? ""
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('News')),
      body: ListView.builder(
          itemCount: this.smallcaseNews?.length,
          itemBuilder: _listViewItemBuilder
      ),
    );

  }



}