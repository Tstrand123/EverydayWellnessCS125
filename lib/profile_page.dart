import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'main.dart';

// Creates a profile page to display information about the user.
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    Widget displayUsername = const Text(
      'Username: [insert_user_name]',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
    );

    return Scaffold(
      // AppBar: basic bar at top of every page.
      appBar: AppBar(
        title: Text(title),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [displayUsername]),
            ElevatedButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text('Sign out')),
          ]),
        ),
      ),
      /*
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error Occured'),
            );
          } else if (snapshot.hasData) {
            return const HomePage(title: 'Title', userID: '[insert_user_id]');
          } else {
            return const AuthPage();
          }
        },
        */
    );
  }
}