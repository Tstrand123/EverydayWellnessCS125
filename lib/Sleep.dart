import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:everyday_wellness_cs125/new_sleep_log.dart';
import 'app_functions.dart';
import 'app_classes.dart';
import 'package:health/health.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Widget that paints SleepHome page
class SleepHome extends StatelessWidget {
  // draws page for sleep home
  const SleepHome({Key? key, required this.title}) : super(key: key);
  final String title;

  void uploadNewSleepLog() async{
    print('called');
    //check if log already exists - match title
    //title - userID and EndTime

    //grabs data from previous night
    //Heavily referenced https://pub.dev/packages/health
    HealthFactory health = HealthFactory(); //Creates health factory - necessary for grabbing data
    var types = [HealthDataType.SLEEP_IN_BED]; //types of data collected - needs Google Fit installed on app

    bool requested = await health.requestAuthorization(types); //requests authorization for accessing sleep data

    var now = DateTime.now(); //Grabs current time

    //Unused but do not delete
    List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
        now.subtract(const Duration(days: 1)), now, types);

    types = [HealthDataType.SLEEP_IN_BED];
    var permissions = [HealthDataAccess.READ]; // requesting read access
    await health.requestAuthorization(types,permissions: permissions); //requests authorization again

    var midnight = DateTime(now.year,now.month,now.day); //get midnight info
    //This will get previous day's minutes slept
    List<HealthDataPoint> asleepMinutesList = await health.getHealthDataFromTypes(midnight.subtract(const Duration(days: 2)), now, types); //gets sleep datapoint
    final asleepMinutes = asleepMinutesList.first.value.toString(); //this is the actual value of sleep minutes
    HealthDataPoint sleepData = asleepMinutesList.first;
    //TODO: Figure out if data is null or does not exist!

    //referenced https://stackoverflow.com/questions/46880323/how-to-check-if-a-cloud-firestore-document-exists-when-using-realtime-updates
    //Referenced https://www.youtube.com/watch?v=ErP_xomHKTw&t=332s
    //Referenced https://stackoverflow.com/questions/57877154/flutter-dart-how-can-check-if-a-document-exists-in-firestore

    final docSleepLogs = FirebaseFirestore.instance.collection('SleepLogs'); //referenced https://stackoverflow.com/questions/57877154/flutter-dart-how-can-check-if-a-document-exists-in-firestore

    String docName = "${FirebaseAuth.instance.currentUser!.uid}-${sleepData.dateTo}"; //check if this exists
    var docExists = await docSleepLogs.doc(docName).get();
    bool doesDocExist = docExists.exists;
    if (doesDocExist) {
      //doc exists - do not send, as it will be a duplicate
      print('exists!'); //TODO: Figure out what to do when duplicate exists
    }else {
      //doc does not exist - send to firestore
      print('Does Not Exist!');
      final newSleepLog = SleepLog(userID: FirebaseAuth.instance.currentUser!.uid,
          bedTime: sleepData.dateFrom, awakeTime: sleepData.dateTo, rating: 5); //TODO: Get Rating, place here
      docSleepLogs.doc(docName).set(newSleepLog.toJson());
    }
  }

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
              child: const Center(child: Text("Recomendation")),
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
                    // TODO: create link to NewLog widget
                    child: Center(
                      child: TextButton(
                        onPressed: uploadNewSleepLog,
                          // onPressed: () { //Collects data from device and uploads it - calls method
                          //   Navigator.push(context,
                          //       MaterialPageRoute(builder: (context) {
                          //     return const CreateNewSleepLog();
                          //   }));
                          // },
                          child: const Text("New Log")),
                    )))
          ])),

          // Log List: displays summary information on the last 5 logs
          Expanded(
              child: ListView(
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              for (int index = 1; index < 6; index++)
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
                        "duration: $index",
                        textAlign: TextAlign.center,
                      )) // TODO: replace $index with reference to data entry from DB
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
      ) //Text('hi'),
          ),
    );
  }
}
