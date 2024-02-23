import 'package:flutter/cupertino.dart';
import 'package:scgateway_flutter_plugin_example/app/global/SIConfigs.dart';

import '../global/SmartInvestingAppRepository.dart';

class SIEnvironmentController extends StatelessWidget {
  final SmartInvestingAppRepository repository;
  const SIEnvironmentController({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: repository.environment.stream,
      builder: (context, snapshot) {
        final data = snapshot.data;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: CupertinoSlidingSegmentedControl(
            padding: const EdgeInsets.all(8),
            groupValue: data?.index ?? 0,
            children: SIEnvironment.values
                .asMap()
                .map((key, value) => MapEntry(key, Text(value.label))),
            onValueChanged: (value) {
              if (value == null) return;
              repository.environment.value =
                  SIEnvironment.values.elementAt(value);
            },
          ),
        );
      },
    );
  }
}
