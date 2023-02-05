import 'package:flutter/material.dart';

import './generic_dialog.dart';

Future<void> showPasswordResetEmailSentDialog(BuildContext context) async {
  return showGenericDialog<void>(
    context: context,
    title: 'Password reset',
    content: 'Password reset link sent, Please check your email.',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
