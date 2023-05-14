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
import 'sensor_data_collection.dart';

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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error Occured'),
            );
          } else if (snapshot.hasData) {
            return Text(
              'Welcome back ${snapshot.data!.firstName}!',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
            );
          } else {
            return const Text('Nothing to Display');
          }
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
      footer: const Padding(
        padding: EdgeInsets.only(top: 20, bottom: 10),
            child:Text(
              "Lifestyle Score",
              style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
        ),
      ),
      circularStrokeCap: CircularStrokeCap.round,

      // TODO: Make it so that the color changes based on the average of the scores.
      progressColor: const Color.fromARGB(255, 36, 131, 17),
    );

    // Create the food recomendation widget: // replaced code with newer, better code. Left this here just in case we want to roll back
    /*Widget foodSection = Expanded(
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
    ));*/

    // paints the food button
    StatefulWidget foodSection = OutlinedButton(
      style: OutlinedButton.styleFrom(
          backgroundColor: Colors.amber.shade100,
          fixedSize: const Size.fromHeight(150),
          foregroundColor: Colors.black),
      onPressed: () {
        // link to the Food Home, where the user will view their food reccs, enter new logs, and view previous ones
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const FoodHome(title: 'Food Home');
        }));
      }, // on pressed
      child: Column(children: <Widget>[
        DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(width: 2, color: Colors.grey)),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 20, 20, 2),
              child: Row(
                children: const [
                  Expanded(
                      flex: 2,
                      child: Text(
                        "Food",
                        textAlign: TextAlign.left,
                      )),
                  // below is an indicator to show weather the daily goal has been met
                  Expanded(
                      flex: 1,
                      child: Icon(Icons.circle,
                          color: Colors
                              .grey)) // TODO: implement the ability to change this color
                ],
              ),
            )),
        Container(
          padding: const EdgeInsets.all(40),
          child: const Expanded(
              child: Text(
            "Recommendation",
            textAlign: TextAlign.center,
          )) // TODO: replace text with recommendation obtained from backend
          ,
        )
      ]),
    );

    // paints link to the Exercise home
    StatefulWidget exerciseSection = OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.lightGreenAccent.shade100,
        fixedSize: const Size.fromHeight(150),
        foregroundColor: Colors.black,
      ),
      onPressed: () {
        // link to the Food Home, where the user will view their food reccs, enter new logs, and view previous ones
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const ExerciseHome(title: 'Exercise Home');
        }));
      }, // on pressed
      child: Column(children: <Widget>[
        DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(width: 2, color: Colors.grey)),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 20, 20, 2),
              child: Row(
                children: const [
                  Expanded(
                      flex: 2,
                      child: Text(
                        "Exercise",
                        textAlign: TextAlign.left,
                      )),
                  // below is an indicator to show weather the daily goal has been met
                  Expanded(
                      flex: 1,
                      child: Icon(Icons.circle,
                          color: Colors
                              .grey)) // TODO: implement the ability to change this color
                ],
              ),
            )),
        Container(
          padding: const EdgeInsets.all(40),
          child: const Expanded(
              child: Text(
            "Recommendation",
            textAlign: TextAlign.center,
          )) // TODO: replace text with recommendation obtained from backend
          ,
        )
      ]),
    );

    // Paints the sleep section
    StatefulWidget sleepSection = OutlinedButton(
      style: OutlinedButton.styleFrom(
          backgroundColor: Colors.lightBlueAccent.shade100,
          fixedSize: const Size.fromHeight(150),
          foregroundColor: Colors.black),
      onPressed: () {
        // link to the Food Home, where the user will view their food reccs, enter new logs, and view previous ones
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const SleepHome(title: 'Sleep Home');
        }));
      }, // on pressed
      child: Column(children: <Widget>[
        DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(width: 2, color: Colors.grey)),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 20, 20, 2),
              child: Row(
                children: const [
                  Expanded(
                      flex: 2,
                      child: Text(
                        "Sleep",
                        textAlign: TextAlign.left,
                      )),
                  // below is an indicator to show weather the daily goal has been met
                  Expanded(
                      flex: 1,
                      child: Icon(Icons.circle,
                          color: Colors
                              .grey)) // TODO: implement the ability to change this color
                ],
              ),
            )),
        Container(
          padding: const EdgeInsets.all(40),
          child: const Expanded(
              child: Text(
            "Recommendation",
            textAlign: TextAlign.center,
          )) // TODO: replace text with recommendation obtained from backend
          ,
        )
      ]),
    );

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
        //child: SingleChildScrollView(
        //child: Column(children: [
        child: ListView(children: [
          // changed to listview so my modifications will work
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(
                child: Container(
                    padding: const EdgeInsets.all(10), child: welcomeText))
          ]),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(padding: const EdgeInsets.all(20), child: lifestyleScore)
          ]),
          Expanded(
              child:
                  foodSection), // changed from row -> expanded types. Buttons are too complicated, had to reduce that complexity to make them work (too many nested columns and rows)
          Expanded(child: exerciseSection),
          Expanded(child: sleepSection),
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
          // Button to go the sensor test page.
          ElevatedButton(
              onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SensorPage()),
                  ),
              child: const Text('Go to sensor test')),
        ]),
      ),
      // ),
    );
    //);
  }
}
