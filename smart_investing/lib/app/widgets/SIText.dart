import 'package:flutter/material.dart';

enum _SITextTypes {
  r,
  l,
  xl;

  TextStyle? _textStyle(BuildContext context) {
    switch (this) {
      case _SITextTypes.r:
        return Theme.of(context).textTheme.labelLarge;
      case _SITextTypes.l:
        return Theme.of(context).textTheme.headlineSmall;
      case _SITextTypes.xl:
        return Theme.of(context).textTheme.headlineLarge;
    }
  }
}

class SIText extends StatelessWidget {
  final String text;
  final _SITextTypes _type;
  const SIText({super.key, required this.text}) : _type = _SITextTypes.r;

  const SIText.large({super.key, required this.text}) : _type = _SITextTypes.l;
  const SIText.xlarge({super.key, required this.text})
      : _type = _SITextTypes.xl;

  @override
  Widget build(BuildContext context) {
    final style = _type._textStyle(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: style?.fontSize ?? 10 / 2),
      child: Text(text, style: style),
    );
  }
}
