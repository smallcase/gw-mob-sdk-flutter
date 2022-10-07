import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';

extension BuildContextExt on BuildContext {
  Future<void> showScDialog(String message) {
    return showDialog<void>(
      context: this,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Gateway'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(message)],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                onPressed: () {
                  FlutterClipboard.copy(message);
                },
                child: Text('Copy'))
          ],
        );
      },
    );
  }
}