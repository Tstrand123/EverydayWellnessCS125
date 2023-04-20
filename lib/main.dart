import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}):super(key:key);
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      home: const HomePage(title: 'HomePage'),
    );
  }}

class HomePage extends StatelessWidget{
  const HomePage({Key? key, required this.title}) : super(key:key);
  final String title;
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
            child: (
                const Text('Exercise', textAlign: TextAlign.center,))
        ));
    Widget sleepSection = Expanded(
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 10, color: Colors.blueAccent),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              color: Colors.blueAccent,
            ),
            padding: const EdgeInsets.all(50),
            child: (
                const Text('Sleep', textAlign: TextAlign.center,))
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
      body: Column(
          children: [
            Expanded (child: Row(children:[foodSection])),
            Expanded (child: Row(children: [exerciseSection])),
            Expanded (child: Row(children: [sleepSection])),
            //Expanded (child: ButtonBar(children: [foodSection]))
          ]
      ),

    );
    //);
  }
}

class FoodHome extends StatelessWidget{
  const FoodHome({Key? key, required this.title}): super(key: key);
  final String title;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[IconButton(onPressed: (){}, icon: const Icon(Icons.account_circle_rounded),)],
      ),
      body: const Center(
        child: Text('hi'),
      ),
    );
  }
}