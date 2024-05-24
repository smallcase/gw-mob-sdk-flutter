import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin_example/app/features/subscreens/InvestmentDetails.dart';

class InvestmentsList extends StatelessWidget {
  final List<dynamic>? investments;

  InvestmentsList({Key? key, @required this.investments}) : super(key: key);

  Widget _listViewItemBuilder(BuildContext context, int index) {
    var investmentItem = investments == null ? null : this.investments![index];
    var investment = investmentItem == null ? null : investmentItem["investment"];

    // Debugging print to check the structure of the investment object
    print("Investment at index $index: $investment");

    return investment == null
        ? Text('No investments')
        : ListTile(
            contentPadding: EdgeInsets.all(10.0),
            leading: _itemThumbnail(investment["scid"] ?? 'default_scid'),
            title: _itemTitle(investment["name"] ?? 'Unnamed Investment'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          InvestmentDetails(investmentsDataDTO: investment)));
            },
          );
  }

  Widget _itemThumbnail(String scid) {
    return Container(
      constraints: BoxConstraints.tightFor(width: 100.0),
      child: Image.network(
          "https://assets.smallcase.com/images/smallcases/200/${scid}.png",
          fit: BoxFit.fitWidth,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.error); // Show an error icon if the image fails to load
          },
      ),
    );
  }

  Widget _itemTitle(String name) {
    return Text(name);
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
