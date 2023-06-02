import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:everyday_wellness_cs125/Food/new_food_log.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

// TODO: save keras model as tflite, add to 'assets' folder
// load 'asset' and call methods to generate recommendation

Map<String, double> summationOfRecords(String user_id, DateTime today, int NumberOfDays){
  // takes the user_id, the date today, and the number of days to calculate based on (1 day summary, 5 day summary, etc determines how many days backwards to look)
  Map<String, double> totals = {
    "fatPercent": .5,
    "carbsPercent": .5,
    "proteinPercent": .4,
    "totalCalories": 2000.0 // sending this as a float because it simplified the map
  };

  // query database

  // sum all values

  // calculate percentage of different macronutrients
  //    fatPercent = (totalFat * 9)/totalCals (calories from fat / total calories)
  // add to the map

  return totals; // return
}

String getNutritionRec(user_id){
  const CalCount = 2000; // using average recommended values (static for now)
  const fatPercent = .2; // recommended: 20-35% fat, down to 30-40% if weight loss is desired
  const carbPercent = .50; // recommended: 45-65% carbs (down to 10-30% if weight loss desired
  const proteinPercent = .3; // recomemended: 10-35% protein (up to 40-50% if weight loss)
  const fatUpper = .35; // represents the upper limit of recommended fat intake, varies based on user pref
  const fatLower = .2;
  const carbUpper = .65;
  const carbLower = .45;
  const proteinUpper = .35;
  const proteinLower = .1;

  // get today's date
  final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  // read user_id's records for the past day

  // sum all records for today
  Map<String, double> totals = summationOfRecords(user_id, today, 1);
  //    find deficieny/surplus with expected calories -- this shouldn't be calculatable until the end of the day
  //    calculate percentage of daily intake (so far) is carbs/protein/fat
  //
  // get weekly summation
  //    for the weekly summation, only want to pay attention to the outliers (such as if their carb intake is well over the average for a week)
  var fat = totals['fatPercent'];
  var carbs = totals['carbsPercent'];
  var protein = totals['proteinPercent'];
  var calories = totals['totalCalories'];

  List recommendations = [];
  // find deficiency/surplus
  //  if fat > 40%
  if (fat! > fatUpper){
    recommendations.add("Reduce fat intake");}
  //    add "reduce fat intake" to list of recommendations
  //  if fat < 20%
  else if (fat! < fatLower){
    recommendations.add("Increase fat intake");
  }
  if (carbs! > carbUpper){
    recommendations.add("Reduce carb intake");
  }
  else if (carbs! < carbLower){
    recommendations.add("Increase carb intake");
  }
  if (protein! > proteinUpper){
    recommendations.add("Reduce protein intake");
  }
  else if (protein! < proteinLower){
    recommendations.add("Increase protein intake");
  }
  if (recommendations.isEmpty){
    return "Right on track!";
    // QUESTION: if the user is on track nutrition wise, should we instead provide a food suggestion?
  }
  // TODO: how to determine if the exercise goal has been reached

  var index = Random().nextInt(recommendations.length - 1); // generate a random index from 0 to the max index
  return recommendations[index];  // return the string corresponding to that index
  return "Error generating nutrition Recommendation";
}

Future<String> getMealRec(String user_id) async {
  // call ML using user_id as the param
  // NOTE: this is my attempt to replicate what is happening in GenerateRecommendation(user_id) function
  final interpreter =  await tfl.Interpreter.fromAsset('model.tflite');
  // TODO: figure out how the arrays and dataframes are going to work, since tensorflow graphs don't seem to play nicely with those
  // load and process input(s)
  // get all users and ratings
  final List<List<double>> ratings = [];
  final Set<double> meals_tried = {};
  final List<double> meal_ids = [];
  double encodedUserId = 0;
  FirebaseFirestore.instance.collection("Users").get().asStream().forEach(
      (event) {
        for (var e in event.docs) {
          double i = 0; // reassignes the user_id to a more easily enumerated value (some userIDs are strings and others are ints)
          for (var rate in e.data()['ratings']) {
            ratings.add([i, double.tryParse(rate['meal_id'])!, rate['rating']]);
            meal_ids.add(double.tryParse(rate['meal_id'])!);
            if (e.data()['user_id'] == user_id){
              meals_tried.add(double.tryParse(rate['meal_id'])!); // make set of all meals this user has tried
              encodedUserId = i;
            }
          }
          i += 1; // add 1
        }
      }
  );

  // find opposite of that list (all meal_ids not in above list)
  List<double> not_tried = [];
  for (var meal in meal_ids){
    if (!meals_tried.contains(meal)){
      not_tried.add(meal);
    }
  }
  // form horizontal stack (where its [user_id, meal_id_not_tried], [user_id, meal_id_not_tried], etc)
  List<List<double>> horizontalStack = [];
  for (var meal in not_tried){
    horizontalStack.add([encodedUserId, meal]);
  }
  // use horizontal stack as input; output is just flat output (1-D list)
  List<double> output = []; // just a 1D list
  interpreter.run(horizontalStack, output);

  //    would be ratings and meals, as well as the user_id
  //  run interpreter, get result (recommendation)
  // close interpreter
  interpreter.close();

  return "Error getting Meal recommendation";
}

String getRecommendation(){
  // TODO: function that calls other functions to generate a recommendation for this user
  //    returns the string to be displayed;

  // QUestion: this is a pretty intensive function call to make, do we really want it doing it
  //    every single time the user reloads the page? Maybe we should put a cooldown on it?
  //    so if less then a minute has passed irl, it won't generate a new recommendation unless prompted to?

  // get user ID
  final user_id = FirebaseAuth.instance.currentUser!.uid;

  // determine randomly what kind of a recommendation we will make (meal or nutrition)
  var coinFlip = Random().nextBool();
  //  if nutrition
  if (coinFlip) {
    //    obtain a summary of this user's eating habits (daily, or weekly no more then that)
    return getNutritionRec(user_id); // call function, return result (is also a string)
    //    create recommendation accordingly
  }
  //  if meal
  else {
    //    run ML and generate a recommendation
    String result = "";
    getMealRec(user_id).then((re){result = re;}); // getMealRec returns a Future String so have to extract it somehow, may not work
    return result;
  }
  // return the recommendation

  return "Error getting recommendation"; // in the event of an error, return
}

// Widget that paints SleepHome page
class FoodHome extends StatelessWidget {
  // draws page for sleep home
  const FoodHome({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar: basic bar at top of every page
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.account_circle_rounded),
          )
        ],
      ),

      // Body starts here
      body: Center(
          child: Column(
        children: [
          // Recommendation box: displays the current recommendation to the user
          Expanded(
              child: Row(children: [
            Expanded(
                child: DecoratedBox(
              decoration: BoxDecoration(
                  color: Colors.white60,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  border: Border.all(color: Colors.black12, width: 2)),
              child: Center(child: Text(getRecommendation())),//"Recommendation")),
            ))
          ])),

          // NewLog widget: allows the user to manually create a new Sleep Log
          Expanded(
              child: Row(children: [
            Expanded(
                child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: Colors.white60,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        border: Border.all(color: Colors.black12, width: 2)),
                    child: Center(
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const CreateNewFoodLog();
                            }));
                          },
                          child: const Text("New Log")),
                    )))
          ])),

          // Log List: displays summary information on the last 5 logs
          Expanded(
              child: ListView(
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              for (int index = 1;
                  index <= 5;
                  index++) // replaced const with loop that generates a pressable button leading to a specific log
                ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(Colors.white),
                      foregroundColor:
                          MaterialStatePropertyAll<Color>(Colors.black),
                    ),
                    onPressed: () {
                      // TODO: fill in
                      //  leads to a more verbose log that lists all elements of the log as well as the options to edit/delete the entry
                    },
                    child: Row(children: [
                      // NOTE: these cannot be const, because they will have hold values obtained from the DB
                      Expanded(
                          child: Text(
                        "Date/Time: $index",
                        textAlign: TextAlign.center,
                      )), // TODO: replace constant text with text retrieved from DB
                      Expanded(
                          child: Text(
                        "name: $index",
                        textAlign: TextAlign.center,
                      ))
                    ])),

              // MoreLogs button: links to widget listing all previous logs
              // TODO: create link to MoreLogs Widget
              ListTile(
                  title: TextButton(
                onPressed: () {},
                child: const Text('More Logs...'),
              ))
            ],
          ))
          //Expanded(child: )
        ],
      )),
    );
  }
}
