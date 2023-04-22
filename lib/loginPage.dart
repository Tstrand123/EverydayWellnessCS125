import 'dart:ui';

import 'package:everyday_wellness_cs125/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Note: Heavily referenced https://www.youtube.com/watch?v=4vKiJZNPhss
//For setting up the sign in and sign up

class LoginWidget extends StatefulWidget {
  final VoidCallback onClickedSignUp;
  const LoginWidget({Key? key, required this.onClickedSignUp}) : super(key: key);



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
              child: const Text('Sign In')),
          const SizedBox(height: 15,),
          RichText(text: TextSpan(
            text: 'Dont have an account?   ',
            style: TextStyle(color: Colors.black),
            children: [
              TextSpan(
                recognizer: TapGestureRecognizer()
                    ..onTap = widget.onClickedSignUp,
                text: 'Sign Up',
                style: TextStyle(color: Colors.black,
                decoration: TextDecoration.underline),
              ),
            ]
            )
          ),
        ],
      ),
    ));
  }

  Future signIn() async {
    showDialog(context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator(),));

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailText.text.trim(),
          password: passwordText.text.trim()
      );
    } on FirebaseAuthException catch (e) {
      print(e);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}



class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) => isLogin ? LoginWidget(onClickedSignUp: toggle,)
      : SignUpWidget(onClickedSignIn: toggle);

  void toggle() => setState(() => isLogin = !isLogin);
}


class SignUpWidget extends StatefulWidget {
  final Function() onClickedSignIn;

  const SignUpWidget({Key? key,
  required this.onClickedSignIn}) : super(key: key);

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 15,),
            TextField(
              controller: passwordController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(onPressed: signUp, child: Text('Sign Up')),
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                text: 'Already have an account?   ',
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                        ..onTap = widget.onClickedSignIn,
                    text: 'Log In',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.black,
                    )
                  ),
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future signUp() async{
    showDialog(context: context,
        builder: (context) => Center(child: CircularProgressIndicator(),));

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      print(e);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

}

