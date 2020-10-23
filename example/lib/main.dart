import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:scgateway_flutter_plugin_example/screens/connect_screen.dart';
import 'package:scgateway_flutter_plugin_example/screens/holdings_screen.dart';
import 'package:scgateway_flutter_plugin_example/screens/leadgen_screen.dart';
import 'package:scgateway_flutter_plugin_example/screens/smt_screen.dart';
import 'package:scgateway_flutter_plugin_example/screens/sst_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smartinvesting Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    PageController _pageController = PageController();

    List<Widget> _screens = [ConnectScreen(), SstScreen(), SmtScreen(), HoldingsScreen(), LeadGenScreen()];

    void _onPageChanged(int index) {
      setState(() => _currentIndex = index);
    }

    void _onItemTapped(int selectedIndex) {
      _pageController.jumpToPage(selectedIndex);
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _screens,
        onPageChanged: _onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: _currentIndex,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.onSurface,
        unselectedItemColor: colorScheme.onSurface.withOpacity(.60),
        selectedLabelStyle: textTheme.caption,
        unselectedLabelStyle: textTheme.caption,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            label: 'Connect',
            icon: Icon(Icons.favorite),
          ),
          BottomNavigationBarItem(
            label: 'SST',
            icon: Icon(Icons.music_note),
          ),
          BottomNavigationBarItem(
            label: 'SMT',
            icon: Icon(Icons.library_books),
          ),
          BottomNavigationBarItem(
            label: 'Holdings',
            icon: Icon(Icons.location_on),
          ),
          BottomNavigationBarItem(
            label: 'Lead Gen',
            icon: Icon(Icons.library_books),
          ),
        ],
      ),
    );
  }
}
