import 'package:flutter/material.dart';

import '../constants/routes.dart';
import '../services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Column(children: [
        const Text("We've sent you an email verification link, "
            "please verify your email"),
        const Text("if you haven't received the verification email yet, "
            "press the button below:"),
        TextButton(
          onPressed: () async {
            await AuthService.firebase().sendEmailVerification();
          },
          child: const Text('Send email verification'),
        ),
        TextButton(
          onPressed: () async {
            await AuthService.firebase().logOut();
            Navigator.of(context)
                .pushNamedAndRemoveUntil(registerRoute, (route) => false);
          },
          child: const Text('Go back'),
        )
      ]),
    );
  }
}
