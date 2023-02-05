import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/auth/bloc/auth_events.dart';
import '../services/auth/bloc/auth_bloc.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("We've sent you an email verification link, "
                "please verify your email"),
            const Text("if you haven't received the verification email yet, "
                "press the button below:"),
            Center(
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            const AuthEventSendEmailVerification(),
                          );
                    },
                    child: const Text('Send email verification'),
                  ),
                  TextButton(
                    onPressed: () async {
                      context.read<AuthBloc>().add(
                            const AuthEventLogout(),
                          );
                    },
                    child: const Text('Go back'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
