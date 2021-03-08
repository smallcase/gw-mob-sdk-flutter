
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin_example/models/InvestmentsDataDTO.dart';
import 'package:scgateway_flutter_plugin_example/screens/InvestmentDetails.dart';

import '../Styles.dart';

class InvestmentsList extends StatelessWidget {

  List<InvestmentsDataDTO> investments;

  InvestmentsList({Key key, @required this.investments}) : super(key: key);

  Widget _listViewItemBuilder(BuildContext context, int index){
    var smallcase = this.investments[index];

    return ListTile(
      contentPadding: EdgeInsets.all(10.0),
      leading: _itemThumbnail(smallcase),
      title: _itemTitle(smallcase),
      onTap: () {
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => InvestmentDetails(investmentsDataDTO: smallcase))
        );
      },
    );
  }

  Widget _itemThumbnail(InvestmentsDataDTO investmentsDataDTO){
    return Container(
      constraints: BoxConstraints.tightFor(width: 100.0),
      child: Image.network("https://assets.smallcase.com/images/smallcases/200/${investmentsDataDTO.investmentItem.scid}.png", fit: BoxFit.fitWidth),
    );
  }

  Widget _itemTitle(InvestmentsDataDTO investmentsDataDTO){
    return Text(
      investmentsDataDTO.investmentItem.name,
      style: Styles.textDefault,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Smallcases')),
      body: ListView.builder(
          itemCount: this.investments.length,
          itemBuilder: _listViewItemBuilder
      ),
    );
  }

}