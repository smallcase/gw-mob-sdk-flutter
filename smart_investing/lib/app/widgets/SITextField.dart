import 'package:flutter/material.dart';

class SITextField extends StatefulWidget {
  final String? hint;
  final String? text;
  final void Function(String)? onChanged;
  const SITextField({super.key, this.hint, this.text, this.onChanged});

  @override
  State<SITextField> createState() => _SITextFieldState();
}

class _SITextFieldState extends State<SITextField> {
  late TextEditingController controller;

  @override
  void initState() {
    final text = widget.text;
    final value = text == null ? null : TextEditingValue(text: text);
    controller = TextEditingController.fromValue(value);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SITextField oldWidget) {
    if (oldWidget.text != widget.text) {
      final text = widget.text;
      if (text is String) controller.text = text;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3.0),
      clipBehavior: Clip.hardEdge,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12))),
      child: TextField(
        controller: controller,
        onChanged: widget.onChanged,
        enableInteractiveSelection: true,
        // cursorHeight: Theme.of(context).textTheme.titleSmall?.fontSize,
        decoration: InputDecoration(labelText: "${widget.hint}"),
      ),
    );
  }
}
