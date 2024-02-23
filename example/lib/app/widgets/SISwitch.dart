import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'SIText.dart';

class SISwitch extends StatelessWidget {
  final String label;
  final bool isEnabled;
  final void Function(bool value)? onChanged;
  const SISwitch({super.key, required this.label, required this.isEnabled, required this.onChanged,});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SIText(text: label),
        Switch.adaptive(
          value: isEnabled,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
