import 'package:flutter/material.dart';

import './generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Sharing Error',
    content: 'Can not share empty note!',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
