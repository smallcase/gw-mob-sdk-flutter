
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin_example/app/models/NewsDataDTO.dart';


class SmallcaseNews extends StatelessWidget {

  List<NewsDataDTO> smallcaseNews;

  SmallcaseNews({Key? key, required this.smallcaseNews}) : super(key: key);

  Widget _listViewItemBuilder(BuildContext context, int index){
    var smallcase = this.smallcaseNews[index];
    return ListTile(
      contentPadding: EdgeInsets.all(10.0),
      // leading: _itemThumbnail(smallcase),
      title: _itemTitle(smallcase)
    );
  }

  Widget _itemTitle(NewsDataDTO newsDataDTO){
    return Text(
      newsDataDTO.headline ?? ""
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('News')),
      body: ListView.builder(
          itemCount: this.smallcaseNews.length,
          itemBuilder: _listViewItemBuilder
      ),
    );

  }



}