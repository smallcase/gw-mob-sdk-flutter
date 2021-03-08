
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin_example/models/ExitedSmallcaseDTO.dart';

import '../Styles.dart';

class ExitedSmallcasesList extends StatelessWidget{

  List<ExitedSmallcaseDTO> exitedSmallcases;

  ExitedSmallcasesList({Key key, @required this.exitedSmallcases}) : super(key: key);

  Widget _listViewItemBuilder(BuildContext context, int index){
    var smallcase = this.exitedSmallcases[index];
    return ListTile(
      contentPadding: EdgeInsets.all(10.0),
      leading: _itemThumbnail(smallcase),
      title: _itemTitle(smallcase),
      // onTap: () {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => SmallcaseDetails(smallcase : smallcase),
      //     ),
      //   );
      // },
    );
  }

  Widget _itemThumbnail(ExitedSmallcaseDTO exitedSmallcaseDTO){
    return Container(
      constraints: BoxConstraints.tightFor(width: 100.0),
      child: Image.network("https://assets.smallcase.com/images/smallcases/200/${exitedSmallcaseDTO.scid}.png", fit: BoxFit.fitWidth),
    );
  }

  Widget _itemTitle(ExitedSmallcaseDTO exitedSmallcaseDTO){
    return Text(
      exitedSmallcaseDTO.name,
      style: Styles.textDefault,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Exited Smallcases')),
      body: ListView.builder(
        itemCount: this.exitedSmallcases.length,
          itemBuilder: _listViewItemBuilder
      ),
    );
  }



}