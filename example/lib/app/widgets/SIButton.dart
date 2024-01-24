import 'package:flutter/material.dart';

class SIButton extends StatelessWidget {
  final String label;
  final void Function()? onPressed;
  const SIButton({super.key, this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label.toUpperCase()),
        style: ElevatedButton.styleFrom(
            elevation: 4,
            shadowColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      ),
    );
  }
}

// Theme.of(context).elevatedButtonTheme.style?.copyWith(
//               padding: MaterialStateProperty.all(EdgeInsets.zero),
//               visualDensity: VisualDensity.compact,
//               foregroundColor: MaterialStatePropertyAll(Colors.amber),
//               overlayColor: MaterialStatePropertyAll(Colors.amber),
//               backgroundColor: MaterialStatePropertyAll(Colors.red),
//               shadowColor: MaterialStatePropertyAll(Colors.transparent),
//               elevation: MaterialStatePropertyAll(0)