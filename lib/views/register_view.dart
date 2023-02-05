import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/services/auth/bloc/auth_events.dart';

import '../constants/routes.dart';
import '../services/auth/auth_service.dart';
import '../services/auth/auth_exceptions.dart';
import '../services/auth/bloc/auth_state.dart';
import '../services/auth/bloc/auth_bloc.dart';
import '../utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, 'Weak password!');
          } else if (state.exception is EmailInUseAuthException) {
            await showErrorDialog(context, 'Email already in use!');
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, 'Invalid email!');
          } else if (state.exception is AuthException) {
            await showErrorDialog(context, 'Failed to register!');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Register')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please enter your email to receive the password reset link',
              ),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enableSuggestions: false,
                autocorrect: false,
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: 'Please enter your email address'),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                decoration: const InputDecoration(
                  hintText: 'Please enter your password',
                ),
              ),
              Center(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () async {
                        final email = _emailController.text;
                        final password = _passwordController.text;
                        context.read<AuthBloc>().add(
                              AuthEventRegister(
                                email: email,
                                password: password,
                              ),
                            );
                      },
                      child: const Text('Register'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              const AuthEventLogout(),
                            );
                      },
                      child: const Text('Already registered yet? Login'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
