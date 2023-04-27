import 'dart:ui';

import 'package:everyday_wellness_cs125/AppClasses.dart';
import 'package:email_validator/email_validator.dart';
import 'package:everyday_wellness_cs125/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Note: Heavily referenced https://www.youtube.com/watch?v=4vKiJZNPhss
//For setting up the sign in and sign up

//Referenced https://dev.to/wangonya/how-you-turn-a-string-into-a-number-or-vice-versa-with-dart-392h

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
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final heightFeetController = TextEditingController();
  final heightInchesController = TextEditingController();
  final weightController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    heightFeetController.dispose();
    heightInchesController.dispose();
    weightController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: emailController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (email) => email != null
                && !EmailValidator.validate(email)
                ? 'Enter a valid email'
                : null,
              ),
              SizedBox(height: 15,),
              TextFormField(
                controller: passwordController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) => value != null && value.length < 4
                ? 'Enter at least 4 characters'
                : null,
              ),
              SizedBox(height: 25,),
              TextFormField(
                controller: firstNameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) => value != null && value.isEmpty
                ? 'Enter a valid name'
                : null,
              ),
              SizedBox(height: 25,),
              TextFormField(
                controller: lastNameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) => value != null && value.isEmpty
                    ? 'Enter a valid name'
                    : null,
              ),
              SizedBox(height: 25,),
              TextFormField(
                keyboardType: TextInputType.number, //https://stackoverflow.com/questions/49577781/how-to-create-number-input-field-in-flutter
                controller: heightFeetController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: 'Height in Feet'),
                validator: (value) => value != null && value.isEmpty
                    ? 'Enter a valid height' //TODO: Rework height and weight validation
                    : null,
              ),
              SizedBox(height: 25,),
              TextFormField(
                keyboardType: TextInputType.number, //https://stackoverflow.com/questions/49577781/how-to-create-number-input-field-in-flutter
                controller: heightInchesController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: 'Height in Inches'),
                validator: (value) => value != null && value.isEmpty
                    ? 'Enter a valid name'
                    : null,
              ),
              SizedBox(height: 25,),
              TextFormField(
                keyboardType: TextInputType.number, //https://stackoverflow.com/questions/49577781/how-to-create-number-input-field-in-flutter
                controller: weightController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(labelText: 'Weight in Pounds'),
                validator: (value) => value != null && value.isEmpty
                    ? 'Enter a valid name'
                    : null,
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
      ),
    );
  }

  Future signUp() async{
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    showDialog(context: context,
        builder: (context) => Center(child: CircularProgressIndicator(),));

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());

      final userID = FirebaseAuth.instance.currentUser!.uid;
      final userUpload = appUser(userID: userID,
          firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        heightFeet: int.parse(heightFeetController.text.trim()),
        heightInches: int.parse(heightInchesController.text.trim()),
        weight: int.parse(weightController.text.trim()),
      );

      final docLocation = FirebaseFirestore.instance.collection('Users').doc(userID);
      docLocation.set(userUpload.toJson());

    } on FirebaseAuthException catch (e) {
      print(e);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

}

