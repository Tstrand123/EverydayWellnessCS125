import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'food.dart';
import 'sleep.dart';
import 'exercise.dart';
import 'test_pages.dart';
import 'profile_page.dart';
import 'app_classes.dart';

//Note: Heavily referenced https://www.youtube.com/watch?v=4vKiJZNPhss
//For setting up the sign in and sign up

//referenced https://www.youtube.com/watch?v=pixIpW3V-5s for errors

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

Future<AppUser?> readUser() async {
  // Get data related to the user.
  final docUser = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser!.uid);
  final snapshot = await docUser.get();
  return AppUser.fromJson(snapshot.data()!);
}

class MyAppLogin extends StatelessWidget {
  const MyAppLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            return const HomePage(title: 'Title');
          } else {
            return const AuthPage();
          }
        },
      ),
    );
  }
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Home',
      home: const MyAppLogin(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // Create welcome text:
    Widget welcomeText = FutureBuilder<AppUser?>(
        future: readUser(),
        builder: (BuildContext context, AsyncSnapshot<AppUser?> snapshot) {
          return Flexible(
              child: Text(
            'Welcome back ${snapshot.data!.firstName}!',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
          ));
        });

    // Create the lifestyle score circular display:
    Widget lifestyleScore = CircularPercentIndicator(
      radius: 120.0,
      lineWidth: 13.0,
      animation: true,
      // TODO: Calculate correct percentage.
      percent: 0.9,
      reverse: true,
      center: const Text(
        // TODO: Display the current average of the scores.
        "135",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      ),
      footer: const Text(
        "Lifestyle Score",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
      ),
      circularStrokeCap: CircularStrokeCap.round,

      // TODO: Make it so that the color changes based on the average of the scores.
      progressColor: const Color.fromARGB(255, 36, 131, 17),
    );

    // Create the food recomendation widget:
    Widget foodSection = Expanded(
        child: Container(
      decoration: BoxDecoration(
        border: Border.all(width: 10, color: Colors.amber),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: Colors.amber,
      ),
      padding: const EdgeInsets.all(50),
      child: TextButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const FoodHome(title: 'Food Home');
          }));
        }, // on pressed
        child: const Text("Food"),
      ),
    ));

    // Create the exercise recomendation widget:
    Widget exerciseSection = Expanded(
        child: Container(
      decoration: BoxDecoration(
        border: Border.all(width: 10, color: Colors.lightGreenAccent),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: Colors.lightGreenAccent,
      ),
      padding: const EdgeInsets.all(50),
      child: TextButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const ExerciseHome(title: 'Exercise Home');
          }));
        }, // on pressed
        child: const Text("Exercise"),
      ),
    ));

    // Create the sleep recomendation widget:
    Widget sleepSection = Expanded(
        child: Container(
      decoration: BoxDecoration(
        border: Border.all(width: 10, color: Colors.lightBlue),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: Colors.lightBlue,
      ),
      padding: const EdgeInsets.all(50),
      child: TextButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const SleepHome(title: 'Sleep Home');
          }));
        }, // on pressed
        child: const Text("Sleep"),
      ),
    ));

    return Scaffold(
      //MaterialApp(
      // title: 'Everyday Wellness',
      // home: Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const ProfilePage(title: 'Profile Page');
              }));
            },
            icon: const Icon(Icons.account_circle_rounded),
          )
        ],
      ),

      //body: const Center(
      //  child: Text('Hello World'),
      //),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Flexible(child: welcomeText)]),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [lifestyleScore]),
            Row(children: [foodSection]),
            Row(children: [exerciseSection]),
            Row(children: [sleepSection]),
            ElevatedButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text('Sign out')),
            //Expanded (child: ButtonBar(children: [foodSection]))
            ElevatedButton(
                onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TestPage()),
                    ),
                child: const Text('Go to test pages')),
          ]),
        ),
      ),
    );
    //);
  }
}
