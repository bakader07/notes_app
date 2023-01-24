import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Column(
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
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                print(userCredential);
              } on FirebaseAuthException catch (e) {
                if (e.code == 'weak-password') {
                  print('Weak password');
                } else if (e.code == 'invalid-email') {
                  print('Invalid email');
                } else if (e.code == 'email-already-in-use') {
                  print('Email already in use');
                } else {
                  print(e.code);
                }
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login/', (route) => false);
            },
            child: const Text('Already registered yet? Login'),
          )
        ],
      ),
    );
  }
}

// Scaffold(
//       appBar: AppBar(
//         title: const Text('Register'),
//       ),
//       body: FutureBuilder(
//         future: Firebase.initializeApp(
//             options: DefaultFirebaseOptions.currentPlatform),
//         builder: ((context, snapshot) {
//           switch (snapshot.connectionState) {
//             case ConnectionState.done:
              
//             default:
//               return const Text('Loading...');
//           }
//         }),
//       ),
//     );