import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'loginPage.dart';
import 'Food.dart';
import 'Sleep.dart';
import 'Exercise.dart';

//Note: Heavily referenced https://www.youtube.com/watch?v=4vKiJZNPhss
//For setting up the sign in and sign up

//referenced https://www.youtube.com/watch?v=pixIpW3V-5s for errors

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyAppLogin extends StatelessWidget {
  const MyAppLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomePage(title: 'Title');
          } else {
            return LoginWidget();
          }
        },
      ),
    );
  }
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}):super(key:key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Home',
      home: MyAppLogin(),
    );
  }}

class HomePage extends StatefulWidget{
  const HomePage({Key? key, required this.title}) : super(key:key);
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    Widget foodSection = Expanded(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 10, color: Colors.amber),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            color: Colors.amber,
          ),
          padding: const EdgeInsets.all(50),
          child: TextButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return const FoodHome(title: 'FoodHome');
              }
              )
              );
            }, // on pressed
            child: Text("Food"),
          ),
        )
    );
    Widget exerciseSection = Expanded(
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 10, color: Colors.lightGreenAccent),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              color: Colors.lightGreenAccent,
            ),
            padding: const EdgeInsets.all(50),
            child:
            TextButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return const ExerciseHome(title: 'ExerciseHome');
                }
                )
                );
              }, // on pressed
              child: Text("Exercise"),
            ),

        ));
    Widget sleepSection = Expanded(
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 10, color: Colors.lightBlue),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              color: Colors.lightBlue,
            ),
            padding: const EdgeInsets.all(50),
            child: TextButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return const SleepHome(title: 'SleepHome');
                }
                )
                );
              }, // on pressed
              child: Text("Sleep"),
            ),
        ));
    return Scaffold(//MaterialApp(
      // title: 'Everyday Wellness',
      // home: Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: <Widget>[IconButton(onPressed: (){}, icon: const Icon(Icons.account_circle_rounded),)],
      ),

      //body: const Center(
      //  child: Text('Hello World'),
      //),
      body: SafeArea(
        child: SingleChildScrollView(
          
          child: Column(
              children: [
                Row(children:[foodSection]),
                Row(children: [exerciseSection]),
                Row(children: [sleepSection]),
                ElevatedButton(onPressed: () => FirebaseAuth.instance.signOut(),
                    child: const Text('Sign out'))
                //Expanded (child: ButtonBar(children: [foodSection]))
              ]
          ),
        ),
      ),

    );
    //);
  }
}

