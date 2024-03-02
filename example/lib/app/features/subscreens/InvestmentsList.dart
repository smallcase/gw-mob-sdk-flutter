import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin_example/app/features/subscreens/InvestmentDetails.dart';


class InvestmentsList extends StatelessWidget {
  List<dynamic>? investments;

  InvestmentsList({Key? key, @required this.investments}) : super(key: key);

  Widget _listViewItemBuilder(BuildContext context, int index) {
    var smallcase = investments == null ? null : this.investments![index];

    return smallcase == null
        ? Text('No investments')
        : ListTile(
            contentPadding: EdgeInsets.all(10.0),
            leading: _itemThumbnail(smallcase["investmentItem"]["scid"]),
            title: _itemTitle(smallcase["investmentItem"]["name"]),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          InvestmentDetails(investmentsDataDTO: smallcase)));
            },
          );
  }

  Widget _itemThumbnail(String scid) {
    return Container(
      constraints: BoxConstraints.tightFor(width: 100.0),
      child: Image.network(
          "https://assets.smallcase.com/images/smallcases/200/${scid}.png",
          fit: BoxFit.fitWidth),
    );
  }

  Widget _itemTitle(String name) {
    return Text(
      name
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Smallcases')),
      body: ListView.builder(
          itemCount: this.investments?.length ?? 0,
          itemBuilder: _listViewItemBuilder),
    );
  }
}
