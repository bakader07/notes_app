import 'package:flutter/material.dart';

import './generic_dialog.dart';
import '../../extensions/buildcontext/loc.dart';

Future<bool> showLogoutDialog(BuildContext context) async {
  return await showGenericDialog<bool>(
    context: context,
    title: context.loc.logout,
    content: context.loc.logout_dialog_prompt,
    optionsBuilder: () => {
      context.loc.cancel: false,
      context.loc.yes: true,
    },
  ).then((value) => value ?? false);
}
