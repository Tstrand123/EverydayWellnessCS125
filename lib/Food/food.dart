import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:everyday_wellness_cs125/Food/new_food_log.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:everyday_wellness_cs125/main.dart';

import 'package:everyday_wellness_cs125/Misc/app_classes.dart';


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
        int count = 0;
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
          count ++;
        }
        else{
          break; // Since the dates are sorted, once you find one that doesn't match the criteria, you know you're done
        }
      }
        totals['fatPercent'] = (TotalFat * 9) / TotalCals;
        totals['carbsPercent'] = (TotalCarb * 4) / TotalCals;
        totals['proteinPercent'] = (TotalPro * 4) / TotalCals;
        totals['totalCalories'] = TotalCals.toDouble();

        if (count >= 2) { // require that count must be >= 2 because this makes no sense otherwise
          totals['averageFat'] = TotalFat / count;
          totals['averageCarbs'] = TotalCarb/ count;
          totals['averageProtein'] = TotalPro/count;
          totals['averageCals'] = TotalCals/count;

        }
    // test if these averages continue if they'll be over or under anything
    // Note: snacks will squew this, would there be any way to factor them out of the count? (not out of the totals, still contribute to average)
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

String? findMeal(int type, double target){
  // type = 0, 1, 2, 3; 0 = low protein, 1 = low carb 2 = low fat 3 = cals
  // target = how many to look for
  // defCals = how many calories are left to hit target (+- 5%?)
  // query db and sort by the column specified
  Map<int, String> operations = {
    0: 'protein',
    1: 'carbs',
    2: 'fat',
    3: 'calories'
  };
  // if you calculate a 'target' this will be easier. Calc the target then find any meals that have around that many grams
  // how do determine how many servings? use cals? Determine cal deficite and then just try to get close to that?
  String mealName = '';
  var db = FirebaseFirestore.instance;
  List<String> mealList = [];
  // add all the names to a list
  db.collection('MealData').where("${operations[type]}", isGreaterThanOrEqualTo: target).get().then((document){
    for (var doc in document.docs) {
      mealList.add(doc['name']);
    }
  });
  if (mealList.isEmpty){
    return null; // return a null string if there was nothing there
  }
  int index = Random().nextInt(mealList.length);

  return mealList[index]; // find a random meal that fits the criteria to return
}

// it works
var score = 50;
int getFoodScore() {
  return score;
}

Future<String> getNutritionRec(user_id) async{
  // TODO: get these values from the user's goals/preferences
  AppUser? userInfo = await readUser();
  print(userInfo!.proteinProfile); //succesfully reads everything

  //const CalCount = 2000; // using average recommended values (static for now)
  var CalCount = 2000;
  await getUserNeeds(user_id).then((result){CalCount = result['calories'];});

  var fatUpper = .35; // recommended: 20-35% fat, down to 30-40% if weight loss is desired
  var fatLower = .2;
  var carbUpper = .65;// recommended: 45-65% carbs (down to 10-30% if weight loss desired
  var carbLower = .45;
  var proteinUpper = .35;// recomemended: 10-35% protein (up to 40-50% if weight loss)
  var proteinLower = .1;

  if(userInfo!.proteinProfile == 'loss') {
    proteinUpper = .5;// recomemended: 10-35% protein (up to 40-50% if weight loss)
    proteinLower = .4;
  }
  if(userInfo!.carbProfile == 'loss') {
    carbUpper = .3;// recommended: 45-65% carbs (down to 10-30% if weight loss desired
    carbLower = .1;
  }
  if(userInfo!.fatProfile == 'loss') {
    fatUpper = .4; // recommended: 20-35% fat, down to 30-40% if weight loss is desired
    fatLower = .3;
  }

  print(proteinUpper);
  print(carbUpper);
  print(fatUpper);

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
  if(calories! > CalCount + (CalCount! * 0.05)){ // multiply by 0.05 to give a 5% leeway
    score -= 10;
    recommendations.add("Consider increasing your activity");
  }
  if (recommendations.isEmpty){
    return "Right on track!";
    // QUESTION: if the user is on track nutrition wise, should we instead provide a food suggestion?
  }

  if (totals.containsKey('averageFat')){
    // check if the averages are there, if one is then they all are
    if (protein + (totals['averageProtein']!.toInt() * 4 / calories) > proteinUpper){
      // The upper limits are harder to calculate, maybe leave?

      // select meal with more fat/carbs?
      // sort meals based on protein in ascending order (under the idea that if there's a low amount
      //    of protein then the percentage will be lower as well
      //int maxProtein =
      //recommendations.add(findMeal(0, maxProtein));
    }
    else if (protein + (totals['averageProtein']!.toInt() * 4 / calories) < proteinLower){
      // select meal with more fat/carbs?
      // sort meals based on protein in ascending order (under the idea that if there's a low amount
      //    of protein then the percentage will be lower as well
      double minProtein = (CalCount * proteinLower) / 4; // the number of grams of protein the user needs in their day
      minProtein -= totals['averageProtein']! * 2; // calculate how many they need to fit that goal
      String? meal = findMeal(0, minProtein);
      if (meal != null) { // if there was a meal that was found, add it; otherwise, do nothing
        recommendations.add(
            "For a balanced diet, increase your protein consumption. Here's a suggestion: $meal");
      }
    }
    if ((carbs + (totals['averageCarbs']!.toInt() * 4) / calories) > carbUpper){
      // select meal with more fat/protein?

    }
    else if((carbs + (totals['averageCarbs']!.toInt() * 4) / calories) < carbLower){
      double minCarb = (CalCount * carbLower) / 4; // the number of grams the user needs in their day
      minCarb -= totals['averageCarbs']! * 2; // calculate how many they need to fit that goal
      String? meal = findMeal(0, minCarb);
      if (meal != null) {
        recommendations.add(
            "For a balanced diet, increase your carbohydrate consumption. Here's a suggestion: $meal");
      }
    }
    if ((fat + (totals['averageFat']!.toInt() * 9) / calories) > fatUpper){
      // select meal with more protein/carbs?
    }
    else if((fat + (totals['averageFat']!.toInt() * 9) / calories) < fatLower){
      double minFat = (CalCount * fatLower) / 9; // the number of grams the user needs in their day
      minFat -= totals['averageCarbs']! * 2; // calculate how many they need to fit that goal
      String? meal = findMeal(0, minFat);
      if (meal != null) {
        recommendations.add(
            "For a balanced diet, increase your fat consumption. Here's a suggestion: $meal");
      }
    }
    if (calories < CalCount) {
      if ((calories + totals['averageCals']!.toInt()) <
          (CalCount + (CalCount * 0.05).toInt())) {
        // predict what their end-of-day calorie consumption will look like
        String? meal = findMeal(3, CalCount - calories);
        if (meal != null) {
          recommendations.add(
              "To help you meet your calorie target, consider trying this meal: $meal");
        }
      }
    }
  }

  //print(recommendations.length);
  var index = Random().nextInt(recommendations.length); // generate a random index from 0 to the max index
  return recommendations[index];  // return the string corresponding to that index
  //return "Error generating nutrition Recommendation";
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
          /*Expanded(
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
          ))*/
          //Expanded(child: )
        ],
      )),
    );
  }
}
