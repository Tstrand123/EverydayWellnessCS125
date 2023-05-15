import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:everyday_wellness_cs125/Sleep/new_sleep_log.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../Misc/app_functions.dart';
import '../Misc/app_classes.dart';
import 'package:health/health.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Widget that paints SleepHome page
class SleepHome extends StatefulWidget {
  // draws page for sleep home
  const SleepHome({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<SleepHome> createState() => _SleepHomeState();
}

class _SleepHomeState extends State<SleepHome> {
  double sleepRating = 0;

  //Grabs logs
  //Referenced https://firebase.flutter.dev/docs/firestore/usage/#querying
  //Referenced https://www.youtube.com/watch?v=ErP_xomHKTw&t=276s
  Stream<List<SleepLog>> readSleepLogs() => FirebaseFirestore.instance
      .collection('SleepLogs')
      .where('userID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => SleepLog.fromJson(doc.data())).toList());

  //TODO: add rating on this page, grab exercise
  void uploadNewSleepLog() async {
    //check if log already exists - match title
    //title - userID and EndTime

    //grabs data from previous night
    //Heavily referenced https://pub.dev/packages/health
    HealthFactory health =
        HealthFactory(); //Creates health factory - necessary for grabbing data
    var types = [
      HealthDataType.SLEEP_IN_BED
    ]; //types of data collected - needs Google Fit installed on app

    bool requested = await health.requestAuthorization(
        types); //requests authorization for accessing sleep data

    var now = DateTime.now(); //Grabs current time

    //Unused but do not delete
    List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
        now.subtract(const Duration(days: 1)), now, types);

    types = [HealthDataType.SLEEP_IN_BED];
    var permissions = [HealthDataAccess.READ]; // requesting read access
    await health.requestAuthorization(types,
        permissions: permissions); //requests authorization again

    var midnight = DateTime(now.year, now.month, now.day); //get midnight info
    //This will get previous day's minutes slept
    List<HealthDataPoint> asleepMinutesList =
        await health.getHealthDataFromTypes(
            midnight.subtract(const Duration(days: 1)),
            now,
            types); //gets sleep datapoint
    //final asleepMinutes = asleepMinutesList.first.value.toString(); //this is the actual value of sleep minutes
    //HealthDataPoint sleepData = asleepMinutesList.first;

    if (asleepMinutesList.isEmpty) {
      //No Sleep Data
      //TODO: return snackbar at bottom
      return;
    } else {
      //iterate, see if most recent date to matches with this day
      //Referenced https://stackoverflow.com/questions/49514807/how-to-loop-through-a-list-of-elements
      //Referenced https://stackoverflow.com/questions/69910445/i-want-to-check-condition-for-all-for-loop-iteration-and-after-that-statement-wi
      HealthDataPoint loopData;
      bool found = false;
      int index = -1;

      for (int i = 0; i < asleepMinutesList.length; i++) {
        loopData = asleepMinutesList[i];
        //Check if date matches - if so, process, else, exit and notify
        if (loopData.dateTo.month == now.month &&
            loopData.dateTo.day == now.day) {
          //found match
          found = true;
          index = i;
          break;
        }
      }

      if (found == false) {
        print('No data');
        return;
      }

      HealthDataPoint sleepData = asleepMinutesList[index];

      //referenced https://stackoverflow.com/questions/46880323/how-to-check-if-a-cloud-firestore-document-exists-when-using-realtime-updates
      //Referenced https://www.youtube.com/watch?v=ErP_xomHKTw&t=332s
      //Referenced https://stackoverflow.com/questions/57877154/flutter-dart-how-can-check-if-a-document-exists-in-firestore

      final docSleepLogs = FirebaseFirestore.instance.collection(
          'SleepLogs'); //referenced https://stackoverflow.com/questions/57877154/flutter-dart-how-can-check-if-a-document-exists-in-firestore

      String docName =
          "${FirebaseAuth.instance.currentUser!.uid}-${sleepData.dateTo}"; //check if this exists
      var docExists = await docSleepLogs.doc(docName).get();
      bool doesDocExist = docExists.exists;
      if (doesDocExist) {
        //doc exists - do not send, as it will be a duplicate
        print('exists!'); //TODO: Figure out what to do when duplicate exists
        return;
      } else {
        //doc does not exist - send to firestore
        print('Does Not Exist!');
        final newSleepLog = SleepLog(
            userID: FirebaseAuth.instance.currentUser!.uid,
            bedTime: sleepData.dateFrom,
            awakeTime: sleepData.dateTo,
            rating: sleepRating); //TODO: Get Rating, place here
        docSleepLogs.doc(docName).set(newSleepLog.toJson());
      }

      return;
    }

    //Figure out if data is null or does not exist!
    //TODO: Get one with date that is most recent, not necessarily first!
    //Check if list is empty
  }

  //builds log for list - this is what we want to display on the tile
  Widget buildLog(SleepLog log) => ListTile(
        leading: Text('${log.rating}'),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar: basic bar at top of every page
      appBar: AppBar(
        title: Text(widget.title),
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
              child: const Center(child: Text("Recommendation")),
            ))
          ])),

          Center(
            child: RatingBar(
              initialRating: 0,
              minRating: 0,
              maxRating: 0,
              allowHalfRating: true,
              itemSize: 30.0,
              ratingWidget: RatingWidget(
                full: const Icon(Icons.star, color: Colors.amber),
                half: const Icon(Icons.star_half, color: Colors.amber),
                empty: const Icon(
                  Icons.star,
                  color: Colors.grey,
                ),
              ),
              onRatingUpdate: (rating) {
                print(rating);
                setState(() {
                  sleepRating = rating;
                });
              },
            ),
          ),

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

          //Grab logs from DB
          SingleChildScrollView(
            child: StreamBuilder<List<SleepLog>>(
              stream: readSleepLogs(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return const Text('Error');
                } else if (snapshot.hasData) {
                  var allSleepLogs = snapshot.data!;

                  return ListView(
                    shrinkWrap:
                        true, //Referenced https://stackoverflow.com/questions/50252569/vertical-viewport-was-given-unbounded-height
                    children: allSleepLogs.map(buildLog).toList(),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),

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
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MoreLogs()));
                },
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

class MoreLogs extends StatefulWidget {
  const MoreLogs({Key? key}) : super(key: key);

  @override
  State<MoreLogs> createState() => _MoreLogsState();
}

class _MoreLogsState extends State<MoreLogs> {
  Stream<List<SleepLog>> readSleepLogs() => FirebaseFirestore.instance
      .collection('SleepLogs')
      .where('userID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => SleepLog.fromJson(doc.data())).toList());

  Widget buildLog(SleepLog log) => ListTile(
        leading: Text('${log.rating}'),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More Logs'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              child: StreamBuilder<List<SleepLog>>(
                stream: readSleepLogs(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return const Text('Error');
                  } else if (snapshot.hasData) {
                    var allSleepLogs = snapshot.data!;

                    return ListView(
                      shrinkWrap:
                          true, //Referenced https://stackoverflow.com/questions/50252569/vertical-viewport-was-given-unbounded-height
                      children: allSleepLogs.map(buildLog).toList(),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
