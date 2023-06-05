import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everyday_wellness_cs125/Misc/app_classes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health/health.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:everyday_wellness_cs125/main.dart';

//referenced https://pub.dev/packages/health
// and https://pub.dev/packages/permission_handler

// class TestPage extends StatefulWidget {
//   const TestPage({Key? key}) : super(key: key);
//
//   @override
//   State<TestPage> createState() => _TestPageState();
// }
//
// class _TestPageState extends State<TestPage> {
//
//   Future<List<HealthDataPoint>> getSleepInBed() async {
//     //Heavily referenced https://pub.dev/packages/health
//     HealthFactory health = HealthFactory();
//
//     var types = [HealthDataType.SLEEP_IN_BED];
//
//     bool requested = await health.requestAuthorization(types);
//
//     var now = DateTime.now();
//
//     List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
//         now.subtract(const Duration(days: 1)), now, types);
//
//     types = [HealthDataType.SLEEP_IN_BED];
//     var permissions = [HealthDataAccess.READ];
//     await health.requestAuthorization(types,permissions: permissions);
//
//     var midnight = DateTime(now.year,now.month,now.day);
//     //This will get previous day's minutes slept
//     List<HealthDataPoint> asleepMinutesList = await health.getHealthDataFromTypes(midnight.subtract(const Duration(days: 3)), now, types);
//     //final asleepMinutes = asleepMinutesList.first.toString();
//
//     return asleepMinutesList;
//   }
//
//   Future<int> getSteps()  async{
//     //Heavily referenced https://pub.dev/packages/health
//     HealthFactory health = HealthFactory();
//
//     var types = [HealthDataType.STEPS];
//
//     bool requested = await health.requestAuthorization(types);
//
//     var now = DateTime.now();
//
//     List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
//         now.subtract(const Duration(days: 1)), now, types);
//
//     types = [HealthDataType.STEPS];
//     var permissions = [HealthDataAccess.READ];
//     await health.requestAuthorization(types,permissions: permissions);
//
//     var midnight = DateTime(now.year,now.month,now.day);
//     int? steps = await health.getTotalStepsInInterval(midnight, now);
//     steps ??= -1; //If steps is null, return -1
//
//     return steps;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Test'),),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               FutureBuilder(
//                 future: getSleepInBed(),
//                 builder: (BuildContext context, AsyncSnapshot<List<HealthDataPoint>> snapshot) {
//                   if (snapshot.hasError) {
//                     return Text('Found an Error: ${snapshot.error.toString()}');
//                   }else if (snapshot.hasData) { //Need to check most recent dates
//                     final tempVal = snapshot.data.toString(); //https://flutterforyou.com/how-to-call-a-variable-inside-string-in-flutter/
//                     return Text(tempVal);
//                   }else{
//                     return const CircularProgressIndicator();
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload all meals'),),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: ElevatedButton(
                    onPressed: testFunc,
                    child: const Text('Upload data')),
              )
            ],
          ),
        ),
      ),
    );
  }

  void uploadData() async{
    final test = await rootBundle.loadString('lib/ML/MLData/dummyDataForApp.csv');
    //final temp = File('lib/ML/MLData/dummyDataForApp.csv').openRead();

   List<List<dynamic>> test2 = CsvToListConverter().convert(test);
   //print(test2);

   for (int i = 1; i < test2.length; i++){
     //print(test2[i]);
     final tempMeal = MealData(
         calories: test2[i][2],
         carbs: test2[i][3],
         fat: test2[i][5],
         main_flavors: test2[i][7],
         meal_type: test2[i][6],
         name: test2[i][1],
         protein: test2[i][4],
         tags: test2[i][8]);
     
     final mealUpload = FirebaseFirestore.instance.collection('MealData').doc('${i - 1}');
     mealUpload.set(tempMeal.toJson());
     navigatorKey.currentState!.popUntil((route) => route.isFirst);
   }

  }

  void uploadUsers() async {
    final userData = await rootBundle.loadString('lib/ML/MLData/userCSV.csv');
    List<List<dynamic>> data2 = CsvToListConverter().convert(userData);

    for (int i = 1; i < data2.length; i++){
      final tempUser = AppUser(
          userID: data2[i][0].toString(),
          firstName: data2[i][1].toString(),
          lastName: data2[i][2].toString(),
          heightFeet: int.parse(data2[i][3].toString()),
          heightInches: int.parse(data2[i][4].toString()),
          weight: int.parse(data2[i][5].toString()),
          initTotalInches: 12 * int.parse(data2[i][3].toString()) + int.parse(data2[i][4].toString()),
          initWeight: int.parse(data2[i][5].toString()),
          biologicalSex: 'P',
          birthDate: '2000-01-01',
          ratings: []);

      final userUpload = FirebaseFirestore.instance.collection('Users').doc('${data2[i][0]}');
      userUpload.set(tempUser.toJson());

    }
  }

  void uploadMealRatings() async {
    showDialog(
        context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ));

    //referenced https://stackoverflow.com/questions/52130316/how-to-get-data-from-firebase-in-flutter
    final userData = await rootBundle.loadString('lib/ML/MLData/mealRatings.csv');
    List<List<dynamic>> data2 = CsvToListConverter().convert(userData);
    for (int i = 1; i < data2.length; i++){
      final mealRate = MealRating(meal_id: data2[i][1].toString(),
          rating: double.parse(data2[i][2].toString()));

      final ratingUpload = FirebaseFirestore.instance.collection('Users').doc(data2[i][0].toString());
      DocumentSnapshot userInfo = await ratingUpload.get();
      //print(userInfo.data());
      Map<String,dynamic> userData = userInfo.data() as Map<String,dynamic>;
      //print(userData['ratings']);
      var newList = userData['ratings'];
      newList.add(mealRate.toJson());
      print(userData['ratings']);
      ratingUpload.update({
        'ratings': newList,
      });

      // if(userData['ratings'] != null) {
      //   //contains rating
      //   List<dynamic> listOratings = userData['ratings'];
      //   listOratings.add(mealRate);
      //   ratingUpload.update({
      //     'ratings': listOratings,
      //   });
      //
      //
      //   //print(listOratings);
      //
      // }else{
      //   //no ratings yet
      //   List<dynamic> listOratings = [];
      //   listOratings.add(mealRate);
      //   ratingUpload.update({
      //     'ratings': listOratings,
      //   });
      // }
      //add to rating array and reset

    }


    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  void testFunc() async {
    final test = FirebaseFirestore.instance.collection('User_ratings').doc('x5c7hhgakDO5n1nMkycMHFgQXLN2').collection('ratings');
    QuerySnapshot dataFrom = await test.get();
    Map<String,dynamic> userData = dataFrom.docs.first.data() as Map<String,dynamic>;
    print(userData);

    // final test = await FirebaseFirestore.instance.collection('User_ratings').get();
    // List<QueryDocumentSnapshot> test2 = test.docs;
    // print(test2);
  }
}
