import 'package:flutter/material.dart';

import './generic_dialog.dart';
import '../../extensions/buildcontext/loc.dart';

Future<bool> showDeleteDialog(BuildContext context) async {
  return await showGenericDialog<bool>(
    context: context,
    title: context.loc.delete,
    content: context.loc.delete_note_prompt,
    optionsBuilder: () => {
      context.loc.cancel: false,
      context.loc.yes: true,
    },
  ).then((value) => value ?? false);
}
