import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scgateway_flutter_plugin_example/app/global/SmartInvestingAppRepository.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIBottomNavBar.dart';
import 'package:scgateway_flutter_plugin_example/app/widgets/SIText.dart';

import 'features/AccOpeningScreen.dart';
import 'features/ConnectScreen.dart';
import 'features/HoldingsScreen.dart';
import 'features/SmtScreen.dart';
import 'features/SstScreen.dart';
import 'widgets/SIButton.dart';

final Map<Widget, ({IconData iconData, int index, String label})> screensMap = {
  ConnectScreen(): (
    index: 0,
    label: "Connect",
    iconData: Icons.contactless_outlined
  ),
  SstScreen(): (index: 1, label: "SST", iconData: Icons.monetization_on),
  SmtScreen(): (index: 2, label: "SMT", iconData: Icons.auto_graph_rounded),
  HoldingsScreen(): (index: 3, label: "Holdings", iconData: Icons.home_filled),
  AccOpeningScreen(): (
    index: 4,
    label: "Lead Gen",
    iconData: Icons.open_in_new_rounded
  ),
};

SmartInvestingAppRepository repository = SmartInvestingAppRepository.singleton();

class SIGatewayPage extends StatefulWidget {
  const SIGatewayPage({Key? key}) : super(key: key);

  @override
  State<SIGatewayPage> createState() => _SIGatewayPageState();
}

class _SIGatewayPageState extends State<SIGatewayPage> {
  late BehaviorSubject<int> currentIndex;
  late PageController pageController;
  late SIBottomNavBarController bottomNavBarController;
  final screens = screensMap.keys.toList();

  @override
  void initState() {
    currentIndex = BehaviorSubject.seeded(0);
    pageController = PageController(keepPage: true);
    bottomNavBarController = SIBottomNavBarController();
    currentIndex.listen((value) {
      if (bottomNavBarController.currentIndex != currentIndex.value)
        bottomNavBarController.jumpTo?.call(value);
      // The page hasn't rendered yet.
      if (!pageController.position.hasContentDimensions) return;
      // The page is being changed. No need to animate to page in that case.
      if (value == pageController.page?.round()) return;
      pageController.animateToPage(value,
          duration: Duration(milliseconds: 300), curve: Curves.linear);
    });
    super.initState();
  }

  @override
  void dispose() {
    currentIndex.close();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          SIButton(
            label: "Loans",
            onPressed: () => {
              repository.appState.add("/las"),
              context.go(repository.appState.value)
            },
          )
        ],
        title: StreamBuilder<int>(
            stream: currentIndex.stream,
            builder: (context, snapshot) {
              final data = snapshot.data;
              if (data == null) return SizedBox();
              return SIText.xlarge(
                  text: screensMap[screens[data]]?.label.toUpperCase() ?? "");
            }),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                  controller: pageController,
                  onPageChanged: (value) {
                    currentIndex.value = value;
                  },
                  children: screens),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SIBottomNavBar(
          controller: bottomNavBarController,
          onTap: (p0) => currentIndex.value = p0,
          siBottomNavBarItems: screensMap.values
              .map((e) => (iconData: e.iconData, label: e.label))
              .toList()),
    );
  }
}
