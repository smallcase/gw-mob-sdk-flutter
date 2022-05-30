import 'package:flutter/material.dart';
import 'package:scgateway_flutter_plugin_example/models/Holding.dart';
import 'package:scgateway_flutter_plugin_example/models/Securities.dart';
import 'package:scgateway_flutter_plugin_example/models/SmallcaseHoldingDTO.dart';
import 'package:scgateway_flutter_plugin_example/models/UserHoldingsResponse.dart';

import '../Styles.dart';

abstract class SecuritiesI {
  String get ticker;
  dynamic get averagePrice;
  int get shares;
}

class UserHoldingsScreen extends StatelessWidget {
  final UserHoldingsResponse holdings;

  const UserHoldingsScreen({Key key, @required this.holdings})
      : super(key: key);

  Widget _stockListViewItemBuilder(BuildContext context, int index) {
    final isV2 = holdings.data.isV2;
    final securityV2 = holdings.data?.dataV2?.securities?.elementAt(index);
    final security =
        holdings.data?.data?.securities?.holdings?.elementAt(index);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: isV2
          ? SecurityItemV2(security: securityV2)
          : HoldingSection(title: '#${index + 1}', holding: security),
    );
  }

  Widget _itemThumbnail(String imageUrl) {
    return Container(
      constraints: BoxConstraints.tightFor(width: 100.0),
      child: Image.network(imageUrl, fit: BoxFit.fitWidth),
    );
  }

  Widget _itemTitle(SecuritiesI holding) {
    return Row(
      children: <Widget>[
        Text(
          holding.ticker,
          style: Styles.textDefault,
        ),
      ],
    );
  }

  Widget _smallcaseListViewItemBuilder(BuildContext context, int index) {
    var security =
        this.holdings.data?.data?.smallcases?.public?.elementAt(index) ??
            this.holdings.data.dataV2.smallcases.public[index];

    return ListTile(
      contentPadding: EdgeInsets.all(10.0),
      leading: _itemThumbnail(security.imageUrl),
      title: _smallcaseItemTitle(security),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Current Value: ' + security.stats.currentValue.toString()),
          Text('Total Returns: ' + security.stats.totalReturns.toString())
        ],
      ),
      onTap: () {},
    );
  }

  Widget _smallcaseItemTitle(SmallcaseHoldingDTO smallcase) {
    return Text(
      smallcase.name,
      style: Styles.textDefault,
    );
  }

  Widget _privateSmallcaseListViewBuilder(BuildContext context, int index) {
    var privateSmallcase = this.holdings.data?.data?.smallcases?.private ??
        this.holdings.data.dataV2.smallcases.privateV2.investments;

    return ListTile(
      contentPadding: EdgeInsets.all(10.0),
      leading: _itemThumbnail(privateSmallcase[index].imageUrl),
      title: privateSmallcase[index].name == null
          ? Text('')
          : Text(privateSmallcase[index].name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Current Value: ' +
              privateSmallcase[index].stats.currentValue.toString()),
          Text('Total Returns: ' +
              privateSmallcase[index].stats.totalReturns.toString())
        ],
      ),
      onTap: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('User Holdings'),
          actions: [
            if (holdings.data.hasMfData)
              Builder(builder: (context) {
                return ElevatedButton(
                    onPressed: () {
                      final mf = holdings.data?.data?.mutualFunds ??
                          holdings.data?.dataV2?.mutualFunds;
                      if (mf != null)
                        Scaffold.of(context)
                            .showBottomSheet((context) => Column(
                                  children: [
                                    Text('Mutual Funds'),
                                    Expanded(
                                        child: ListView.builder(
                                      itemCount: mf.holdings?.length ?? 0,
                                      itemBuilder: (context, index) =>
                                          MFHoldingItem(
                                              holding:
                                                  mf.holdings.elementAt(index)),
                                    ))
                                  ],
                                ));
                    },
                    child: Text('Show MF Data'));
              })
          ],
        ),
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
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount:
                      this.holdings.data.data?.securities?.holdings?.length ??
                          this.holdings.data.dataV2.securities.length,
                  itemBuilder: _stockListViewItemBuilder),
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
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount:
                      this.holdings.data.data?.smallcases?.public?.length ??
                          this.holdings.data.dataV2.smallcases.public.length,
                  itemBuilder: _smallcaseListViewItemBuilder),
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
            Expanded(
                child: ListView.builder(
              shrinkWrap: true,
              itemCount: this.holdings.data.data?.smallcases?.private?.length ??
                  this
                      .holdings
                      .data
                      .dataV2
                      .smallcases
                      .privateV2
                      .investments
                      .length,
              itemBuilder: _privateSmallcaseListViewBuilder,
            ))
          ],
        ));
  }
}

class SecurityItemV2 extends StatelessWidget {
  final SecurityV2 security;
  const SecurityItemV2({Key key, this.security}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bsePosition = security.positions.bse;
    final nsePosition = security.positions.nse;
    return Container(
      decoration: BoxDecoration(
          color: Colors.blue[700].withOpacity(.3),
          border: Border.all(color: Colors.blue[900])),
      child: Column(
        children: [
          TableRow(name: 'Name', value: security.name),
          TableRow(name: 'BSE Ticker', value: security.bseTicker),
          TableRow(name: 'NSE Ticker', value: security.nseTicker),
          TableRow(
              name: 'Smallcase Qty.',
              value: security.smallcaseQuantity.toString()),
          TableRow(
              name: 'Transactable Qty.',
              value: security.transactableQuantity.toString()),
          TableRow(name: 'IsIn', value: security.isin),
          HoldingSection(title: 'Holdings', holding: security.holdings),
          HoldingSection(title: 'BSE Position', holding: bsePosition),
          HoldingSection(title: 'NSE Position', holding: nsePosition),
        ],
      ),
    );
  }
}

class HoldingSection extends StatelessWidget {
  final String title;
  final Holding holding;
  const HoldingSection({Key key, this.title, this.holding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableSection(
      title: title,
      rows: {
        'Name': holding.name.toString(),
        'Avg. Price': holding.averagePrice.toString(),
        'Ticker': holding.ticker.toString(),
        'Shares': holding.shares.toString(),
      },
    );
  }
}

class TableRow extends StatelessWidget {
  final String name;
  final String value;
  const TableRow({Key key, this.name, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 120,
        ),
        Flexible(
          child: Text(
            value ?? '',
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class TableSection extends StatelessWidget {
  final String title;
  final Map<String, String> rows;
  const TableSection({Key key, this.title, this.rows}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[900])),
      child: Column(
        children: [
          Text(title),
          ...rows.entries
              .map((e) => TableRow(name: e.key, value: e.value))
              .toList()
        ],
      ),
    );
  }
}

class MFHoldingItem extends StatelessWidget {
  final MFHolding holding;
  const MFHoldingItem({Key key, this.holding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[900])),
      child: Column(
        children: [
          TableRow(name: 'Folio', value: holding.folio),
          TableRow(name: 'Fund', value: holding.fund),
          TableRow(name: 'Trading Symbol', value: holding.tradingsymbol),
          TableRow(name: 'PNL', value: holding.pnl.toString()),
          TableRow(name: 'Quantity', value: holding.quantity.toString()),
          TableRow(name: 'IsIn', value: holding.isin.toString()),
          TableRow(
              name: 'Average Price', value: holding.averagePrice.toString()),
          TableRow(
              name: 'Last Price Date', value: holding.lastPriceDate.toString()),
          TableRow(name: 'Last Price', value: holding.lastPrice.toString()),
          TableRow(name: 'XIRR', value: holding.xirr.toString()),
        ],
      ),
    );
  }
}
