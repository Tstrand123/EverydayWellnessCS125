import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:everyday_wellness_cs125/Food/new_food_log.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;



// TODO: implement ability for user to specify their nutritional needs:
//    Their calorie target for the day (defualts to 2000)
//    Their specific diets: low carb, high protein, etc
//    For ease, can just make some macros that have set percentages that get set to their profile then loaded below

Future<Map<String, double>> summationOfRecords(String user_id, DateTime today, int NumberOfDays) async{
  // takes the user_id, the date today, and the number of days to calculate based on (1 day summary, 5 day summary, etc determines how many days backwards to look)
  Map<String, double> totals = {
    "fatPercent": .5,
    "carbsPercent": .5,
    "proteinPercent": .4,
    "totalCalories": 2000.0 // sending this as a float because it simplified the map
  };

  // TODO: query database to get all nutritional logs within the last 24 hours of NOW (indexes of items stored as DateTime)
  var db = FirebaseFirestore.instance;
  await db.collection('nutritionData')
      .doc(user_id)
      .collection('meals').orderBy('time', descending: true).limit(10) // for now: assume that they have eaten less then 10 meals in the past day (feel like that 's reasonable)
      //.where('time', isGreaterThan: Timestamp.fromDate(today.subtract(const Duration(days:1))))
      //.where('time', isLessThan: Timestamp.fromDate(today)) // NOT working, can try ordering them by timestamp, limiting results to 5-10
      // and then manually preforming the comparison to see which entries we keep and which we discard
      //.where('time', isGreaterThan: Timestamp.fromDate(today.subtract(const Duration(days:1))))
      .get()
      .then((snap){
        int TotalFat = 0;
        int TotalCarb = 0;
        int TotalPro = 0;
        int TotalCals= 0;
        DateTime yesterday = today.subtract(const Duration(days: 1));
      for (var i in snap.docs) {
        //if ((i.get('time').compareTo(Timestamp.fromDate(today)) < 1) &&
          //  (i.get('time').compareTo(
            //    Timestamp.fromDate(today.subtract(const Duration(days: 1))))) > -1) {
        DateTime BetterTime = DateTime.parse(i.get('time').toDate().toString());
        if (BetterTime.isBefore(today) && BetterTime.isAfter(yesterday)){
          TotalFat += int.parse(i.get('fat'));
          TotalCarb += int.parse(i.get('carbs'));
          TotalPro += int.parse(i.get('protein'));
          TotalCals += int.parse(i.get('calories'));
        }
        else{
          break; // Since the dates are sorted, once you find one that doesn't match the criteria, you know you're done
        }
      }
        totals['fatPercent'] = (TotalFat * 9) / TotalCals;
        totals['carbsPercent'] = (TotalCarb * 4) / TotalCals;
        totals['proteinPercent'] = (TotalPro * 4) / TotalCals;
        totals['totalCalories'] = TotalCals.toDouble();
  });

  return totals; // return map
}

Future<Map<String, dynamic>> getUserNeeds(String userId) async {
  // queries db to get user's context and adjust parameters as needed

  var db = FirebaseFirestore.instance;
  Map<String, dynamic> ret = {'calories' : 2000}; // default value is 2000
  await db.collection("Users").doc(userId).get().then((doc){
    ret = <String, dynamic>
    {'calories' : doc.get('weight')*15,
      // TODO: if we want the user to specify what kind of diet they want,
      //    can fill this area with fat, carbs, etc
    };
  }

  );
  return ret;
}

// it works
var score = 50;
int getFoodScore() {
  return score;
}

Future<String> getNutritionRec(user_id) async{
  // TODO: get these values from the user's goals/preferences

  //const CalCount = 2000; // using average recommended values (static for now)
  var CalCount = 2000;
  await getUserNeeds(user_id).then((result){CalCount = result['calories'];});
  const fatUpper = .35; // recommended: 20-35% fat, down to 30-40% if weight loss is desired
  const fatLower = .2;
  const carbUpper = .65;// recommended: 45-65% carbs (down to 10-30% if weight loss desired
  const carbLower = .45;
  const proteinUpper = .35;// recomemended: 10-35% protein (up to 40-50% if weight loss)
  const proteinLower = .1;

  // get today's date
  final today = DateTime.now();//DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  // read user_id's records for the past day

  // sum all records for today
  Map<String, double> totals = await summationOfRecords(user_id, today, 1);
  // TODO: (if there's time):
  // get weekly summation
  //    for the weekly summation, only want to pay attention to the outliers (such as if their carb intake is well over the average for a week)

  var fat = totals['fatPercent'];
  var carbs = totals['carbsPercent'];
  var protein = totals['proteinPercent'];
  var calories = totals['totalCalories'];
 // var score = 50;
  List recommendations = []; // list of strings that can potentially be recommended
  // find deficiency/surplus
  //  if fat > 40%
  if (fat! > fatUpper){
    score -= 10;          // Note: while there are many -10s many are mutually exclusive. Max subtractions is -40 in total
    recommendations.add("Reduce fat intake");}
  //    add "reduce fat intake" to list of recommendations
  //  if fat < 20%
  else if (fat! < fatLower){
    score -= 10;
    recommendations.add("Increase fat intake");
  }
  if (carbs! > carbUpper){
    score -= 10;
    recommendations.add("Reduce carb intake");
  }
  else if (carbs! < carbLower){
    score -= 10;
    recommendations.add("Increase carb intake");
  }
  if (protein! > proteinUpper){
    score -= 10;
    recommendations.add("Reduce protein intake");
  }
  else if (protein! < proteinLower){
    score -= 10;
    recommendations.add("Increase protein intake");
  }
  else if(calories! > CalCount){
    score -= 10;
    recommendations.add("Consider increasing your activity");
  }
  if (recommendations.isEmpty){
    return "Right on track!";
    // QUESTION: if the user is on track nutrition wise, should we instead provide a food suggestion?
  }
  // TODO:
    // if the user is over their caloric goal AND has not exercised, recommend that they do that
    // TODO: how to determine if the exercise goal has been reached?

  //print(recommendations.length);
  var index = Random().nextInt(recommendations.length); // generate a random index from 0 to the max index
  return recommendations[index];  // return the string corresponding to that index
  return "Error generating nutrition Recommendation";
}

Future<String> getMealRec(String user_id) async {
  // call ML using user_id as the param
  // NOTE: this is my attempt to replicate what is happening in GenerateRecommendation(user_id) function
  // load and process input(s)
  // get all users and ratings
  final List<List<double>> ratings = [];
  final Set<int> meals_tried = {};
  final List<double> meal_ids = [];
  int encodedUserId = 0;
  //print(await FirebaseFirestore.instance.collection("User_ratings").get());
  await FirebaseFirestore.instance.collection("User_ratings").doc(user_id).collection('ratings').get().then(//.asStream().forEach(
      (event) {
        //print("event: ${event.docs}");
        //print("$event");
        for (var e in event.docs) {
          int i = 0; // reassignes the user_id to a more easily enumerated value (some userIDs are strings and others are ints)
          //for (var rate in e.data()['ratings']) {
          print ("the document: $e");
          //for (var rate in e.collection('ratings'))//['ratings'].docs()){
            //ratings.add([i, double.tryParse(rate['meal_id'])!, rate['rating']]);
            //print(rate);
          try {
            /*ratings.add([
              i,
              double.parse(e['meal_id']),
              double.parse(e['rating'])
            ]);*/
            meals_tried.add(int.parse(e['meal_id']));
          }
          on FormatException {
            return "Error";
          }
            //ratings.add([i, double.tryParse(rate)!, rate.data()[rate]]);
            //meal_ids.add(double.tryParse(rate['meal_id'])!);
            //if (e.data()['user_id'] == user_id){
            //  meals_tried.add(double.tryParse(rate['meal_id'])!); // make set of all meals this user has tried
            //  encodedUserId = i;
            //}
         // }
          i += 1; // add 1
        }
      }
  );

  if(meals_tried.isEmpty){
    return "Consider trying one of our dietitian approved meals!";
  }

  // find opposite of that list (all meal_ids not in above list)
  List<int> not_tried = [];
  for (int i = 0 ; i < 50; i+=1){ // If you are wondering why all of this is in doubles, its because rating is a double and they all have to be the same type because list
  //for (var meal in meal_ids){
    if (!meals_tried.contains(i)){
      not_tried.add(i);
    }
  }
  final interpreter =  await tfl.Interpreter.fromAsset('lib/assets/model.tflite');

  // form horizontal stack (where its [user_id, meal_id_not_tried], [user_id, meal_id_not_tried], etc)
  List<List<int>> horizontalStack = [];//[List.filled(not_tried.length, encodedUserId), not_tried];

  for (var meal in not_tried){
    horizontalStack.add([1, meal]);
  }
  print(horizontalStack);
  // use horizontal stack as input; output is just flat output (1-D list)
  List<dynamic> output = List.filled(50,0).reshape([50,1]);
  interpreter.run(horizontalStack, output);

  //    would be ratings and meals, as well as the user_id
  //  run interpreter, get result (recommendation)
  // close interpreter
  interpreter.close();

  return "Error getting Meal recommendation";
}

Widget getRecommendation(){
  // TODO: function that calls other functions to generate a recommendation for this user
  //    returns the string to be displayed;

  // QUestion: this is a pretty intensive function call to make, do we really want it doing it
  //    every single time the user reloads the page? Maybe we should put a cooldown on it?
  //    so if less then a minute has passed irl, it won't generate a new recommendation unless prompted to?

  // get user ID
  final user_id = FirebaseAuth.instance.currentUser!.uid;

  // determine randomly what kind of a recommendation we will make (meal or nutrition)
  var coinFlip = true;//Random().nextBool();
  //  if nutrition
  if (coinFlip) {
    //    obtain a summary of this user's eating habits (daily, or weekly no more then that)
    //return getNutritionRec(user_id); // call function, return result (is also a string)
    //    create recommendation accordingly
    return FutureBuilder(
        future: getNutritionRec(user_id),
        builder: (BuildContext context, AsyncSnapshot<String> output) {
         return Text("${output.data}", textAlign: TextAlign.center,);
        }
    );
  }
  //  if meal
  //else {
    //    run ML and generate a recommendation
    String result = "";
    getMealRec(user_id).then((re){result = re;}); // getMealRec returns a Future String so have to extract it somehow, may not work
    //return result;
  //}
  // return the recommendation

  //return "Error getting recommendation"; // in the event of an error, return
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
              child: Center(child: getRecommendation()),//"Recommendation")),
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
