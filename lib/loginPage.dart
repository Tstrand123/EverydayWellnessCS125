import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Note: Heavily referenced https://www.youtube.com/watch?v=4vKiJZNPhss
//For setting up the sign in and sign up

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final emailText = TextEditingController();
  final passwordText = TextEditingController();

  @override
  void dispose() {
    emailText.dispose();
    passwordText.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: emailText,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Enter Email'),
          ),
          const SizedBox(height: 15,),
          TextField(
            controller: passwordText,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: 'Enter Password'),
          ),
          const SizedBox(height: 15,),
          ElevatedButton(onPressed: signIn,
              child: const Text('Sign In'))
        ],
      ),
    ));
  }

  Future signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailText.text.trim(),
        password: passwordText.text.trim()
    );
  }
}
