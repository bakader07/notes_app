import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
    return Column(
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          enableSuggestions: false,
          autocorrect: false,
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
        TextButton(
          onPressed: () async {
            final email = _emailController.text;
            final password = _passwordController.text;

            try {
              final userCredential =
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: email,
                password: password,
              );
              print(userCredential);
            } on FirebaseAuthException catch (e) {
              if (e.code == 'user-not-found') {
                print('User not found');
              } else if (e.code == 'wrong-password') {
                print('Wrong password');
              } else {
                print(e.code);
              }
            }
          },
          child: const Text('Login'),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('Not registered yet? Register'),
        )
      ],
    );
  }
}
