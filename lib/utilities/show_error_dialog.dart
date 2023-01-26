import 'package:flutter/material.dart';

Future showErrorDialog(BuildContext context, String text) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('An error occured'),
      content: Text(text),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK')),
      ],
    ),
  );
}
