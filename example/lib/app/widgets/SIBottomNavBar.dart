import 'package:flutter/material.dart';

class SIBottomNavBarController with ChangeNotifier {
  int currentIndex = 0;
  void Function(int)? jumpTo;
}

class SIBottomNavBar extends StatefulWidget {
  final int initialIndex;
  final List<({IconData iconData, String label})> siBottomNavBarItems;
  final void Function(int)? onTap;
  final SIBottomNavBarController? controller;
  const SIBottomNavBar(
      {super.key,
      required this.siBottomNavBarItems,
      this.initialIndex = 0,
      this.onTap,
      this.controller});

  @override
  State<SIBottomNavBar> createState() => _SIBottomNavBarState();
}

class _SIBottomNavBarState extends State<SIBottomNavBar> {
  late int _currentIndex;
  late List<BottomNavigationBarItem> _navBarItems;

  setIndex(int index) => setState(() {
        _currentIndex = index;
        widget.controller?.currentIndex = _currentIndex;
      });

  @override
  void initState() {
    _currentIndex = widget.initialIndex;
    widget.controller?.jumpTo = setIndex;
    widget.controller?.currentIndex = _currentIndex;
    _navBarItems = widget.siBottomNavBarItems
        .map((e) => BottomNavigationBarItem(
            icon: Icon(e.iconData, color: Colors.blueGrey[100]),
            activeIcon: Icon(e.iconData, color: Colors.blue),
            label: e.label))
        .toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("Build SI Bottom Nav Bar!");
    return BottomNavigationBar(
        elevation: 0,
        currentIndex: _currentIndex,
        onTap: (value) {
          setIndex(value);
          widget.onTap?.call(value);
        },
        items: _navBarItems);
    // return StreamBuilder<int>(
    //   stream: currentIndex.stream,
    //   builder: (context, snapshot) {
    //     final data = snapshot.data;
    //     return;
    //   },
    // );
  }
}
