import 'package:flutter/material.dart';

import './generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) async {
  return await showGenericDialog<bool>(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to delete this item?',
    optionsBuilder: () => {
      'Cancel': false,
      'Delete': true,
    },
  ).then((value) => value ?? false);
}
