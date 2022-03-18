
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin_example/models/Holding.dart';
import 'package:scgateway_flutter_plugin_example/models/SmallcaseHoldingDTO.dart';
import 'package:scgateway_flutter_plugin_example/models/UserHoldingsResponse.dart';

import '../Styles.dart';

class UserHoldingsScreen extends StatelessWidget {

  UserHoldingsResponse holdings;

  UserHoldingsScreen({Key key, @required this.holdings}) : super(key: key);

  Widget _stockListViewItemBuilder(BuildContext context, int index){
    var security = this.holdings.data.data.securities.holdings[index];

    return ListTile(
      contentPadding: EdgeInsets.all(10.0),
      // leading: _itemThumbnail(smallcase),
      title: _itemTitle(security),
      subtitle: Column(
        children: <Widget>[
          Text(
            'Avg Price: ' + security.averagePrice.toString(),
            style: Styles.textDefault,
          ),
          Text(
            'Shares: ' + security.shares.toString(),
            style: Styles.textDefault,
          ),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _itemThumbnail(String imageUrl){
    return Container(
      constraints: BoxConstraints.tightFor(width: 100.0),
      child: Image.network(imageUrl, fit: BoxFit.fitWidth),
    );
  }

  Widget _itemTitle(Holding holding) {

    return Row(
      children: <Widget>[
        Text(
          holding.ticker,
          style: Styles.textDefault,
        ),
      ],
    );
  }

  Widget _smallcaseListViewItemBuilder(BuildContext context, int index){
    var security = this.holdings.data.data.smallcases.public[index];

    return ListTile(
      contentPadding: EdgeInsets.all(10.0),
      leading: _itemThumbnail(security.imageUrl),
      title: _smallcaseItemTitle(security),
      subtitle: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text('Current Value: ' + security.stats.currentValue.toString()),
          Text('Total Returns: ' + security.stats.totalReturns.toString())
        ],
    ),
      onTap: () {},
    );
  }

  Widget _smallcaseItemTitle(SmallcaseHoldingDTO smallcase){
    return Text(
      smallcase.name,
      style: Styles.textDefault,
    );
  }

  Widget _privateSmallcaseListViewBuilder(BuildContext context, int index) {

    var privateSmallcase = this.holdings.data.data.smallcases.private;

    return ListTile(
      contentPadding: EdgeInsets.all(10.0),
      leading: _itemThumbnail(privateSmallcase[index].imageUrl),
      title: privateSmallcase[index].name == null ? Text('') : Text(privateSmallcase[index].name),
      subtitle: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text('Current Value: ' + privateSmallcase[index].stats.currentValue.toString()),
          Text('Total Returns: ' + privateSmallcase[index].stats.totalReturns.toString())
        ],
      ),
      onTap: () {},
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Holdings')),
      body: Column(
        children: <Widget>[
          const Divider(
            height: 20,
            thickness: 5,
            indent: 20,
            endIndent: 20,
          ),
          Container(
            padding: const EdgeInsets.only(left: 20),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'Single Stocks',
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(child: ListView.builder(
              shrinkWrap: true,
              itemCount: this.holdings.data.data.securities.holdings.length,
              itemBuilder: _stockListViewItemBuilder
            ),
          ),
          const Divider(
            height: 20,
            thickness: 5,
            indent: 20,
            endIndent: 20,
          ),
          Container(
            padding: const EdgeInsets.only(left: 20),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'Smallcases',
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(child: ListView.builder(
              shrinkWrap: true,
              itemCount: this.holdings.data.data.smallcases.public.length,
              itemBuilder: _smallcaseListViewItemBuilder
          ),
          ),
          const Divider(
            height: 20,
            thickness: 5,
            indent: 20,
            endIndent: 20,
          ),
          Container(
            padding: const EdgeInsets.only(left: 20),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'Private Smallcases',
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(child: ListView.builder(
            shrinkWrap: true,
            itemCount: this.holdings.data.data.smallcases.private.length,
            itemBuilder: _privateSmallcaseListViewBuilder,
          ))
        ],
      )
    );
  }

}