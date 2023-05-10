import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'main.dart';
import 'app_classes.dart';

// Creates a profile page to display information about the user.
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    Widget displayUsername = FutureBuilder<AppUser?>(
        future: readUser(),
        builder: (BuildContext context, AsyncSnapshot<AppUser?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error Occured'),
            );
          }
          if (snapshot.hasData) {
            return Text(
              'Username: ${snapshot.data!.firstName}',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
            );
          } else {
            return const Text('Nothing to Display');
          }
        });

    return Scaffold(
      // AppBar: basic bar at top of every page.
      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Flexible(child: displayUsername)]),
            ElevatedButton(
                onPressed: () => {
                      FirebaseAuth.instance.signOut().then((value) => {
                            //Referenced https://stackoverflow.com/questions/62036432/signout-does-not-work-after-i-navigate-to-a-screen-but-it-works-when-i-do-not
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MyAppLogin()))
                          })
                    },
                child: const Text('Sign out')),
          ]),
        ),
      ),
    );
  }
}
