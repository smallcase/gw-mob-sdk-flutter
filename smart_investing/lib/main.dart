import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:scgateway_flutter_plugin/scgateway_flutter_plugin.dart';
import 'package:scgateway_flutter_plugin/scgateway_events.dart';
import 'package:scloans/sc_loan.dart';
import 'package:scloans/sc_loan_events.dart';

import 'app/SIGatewayPage.dart';
import 'app/SILoansPage.dart';
import 'app/global/SmartInvestingAppRepository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Brightness _brightness;
  StreamSubscription<String>? _gatewayEventsSub;
  StreamSubscription<String>? _loansEventsSub;

  @override
  void initState() {
    var dispatcher = SchedulerBinding.instance.platformDispatcher;
    _brightness = dispatcher.platformBrightness;
    // This callback is called every time the brightness changes.
    dispatcher.onPlatformBrightnessChanged = () {
      setState(() {
        _brightness = dispatcher.platformBrightness;
      });
    };

    ScgatewayEvents.startListening();
    _gatewayEventsSub = ScgatewayEvents.eventStream.listen( 
      (jsonString) {
        // Parse the event if needed
        final event = ScgatewayEvents.parseEvent(jsonString);
        if (event != null) {
          print('[Gateway Event] $event');
        } else {
          print('[Gateway Event] Raw: $jsonString');
        }
      },
      onError: (e) {
        print('[Gateway Event][Error] $e');
      },
    );

    ScLoanEvents.startListening();
     _loansEventsSub = ScLoanEvents.eventStream.listen(
      (jsonString) {
        // Parse the event if needed
        final event = ScLoanEvents.parseEvent(jsonString);
        if (event != null) {
          print('[Loans Event] $event');
        } else {
          print('[Loans Event] Raw: $jsonString');
        }
      },
      onError: (e) {
        print('[Loans Event][Error] $e');
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    ScgatewayEvents.stopListening();
    ScLoanEvents.stopListening();

    _gatewayEventsSub?.cancel();
    _loansEventsSub?.cancel();

    ScgatewayEvents.dispose();
    ScLoanEvents.dispose();
    repository.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Smartinvesting Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: _brightness,
        ),
      ),
      routerConfig: GoRouter(
        initialLocation: repository.appState.value,
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => SIThemeWrapper(child: SIGatewayPage()),
          ),
          GoRoute(
            path: '/las',
            builder: (context, state) => SIThemeWrapper(child: SILoansPage()),
          ),
        ],
      ),
    );
  }
}

class SIThemeWrapper extends StatelessWidget {
  final Widget child;
  const SIThemeWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          floatingLabelStyle: theme.textTheme.titleSmall?.copyWith(
            color: theme.textTheme.titleSmall?.color?.withOpacity(.4),
          ),
          floatingLabelAlignment: FloatingLabelAlignment.start,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          border: InputBorder.none,
        ),
        textTheme: theme.textTheme.copyWith(
          headlineSmall: theme.textTheme.headlineSmall?.copyWith(
            color: theme.textTheme.headlineSmall?.color?.withOpacity(.7),
            fontWeight: FontWeight.bold,
            fontSize: (theme.textTheme.headlineSmall?.fontSize ?? 24) * .8,
          ),
          headlineLarge: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: child,
    );
  }
}
