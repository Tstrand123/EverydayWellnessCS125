import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:everyday_wellness_cs125/Sleep/new_sleep_log.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../Misc/app_functions.dart';
import '../Misc/app_classes.dart';
import 'package:health/health.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Widget that paints SleepHome page
class SleepHome extends StatefulWidget {
  // draws page for sleep home
  const SleepHome({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<SleepHome> createState() => _SleepHomeState();
}

class _SleepHomeState extends State<SleepHome> {
  int sleepRating = 0;
  String bedtimeGoalText = '';
  String durationGoalText = '';

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
        if (loopData.dateTo.month == now.month &&
            loopData.dateTo.day == now.day) {
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
        leading: Text('${log.rating}, ${log.awakeTime}'),
      );

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                  }
                  else{
                  DocumentReference sleepGoalsDocRef =
                      FirebaseFirestore.instance.collection('sleep_goals').doc(user.uid);

                  sleepGoalsDocRef.get().then((DocumentSnapshot snapshot) {
                    if (snapshot.exists) {
                      String bedtime = snapshot.get('bedtime') ?? 'Not Set';
                      String duration = snapshot.get('duration') ?? 'Not Set';

                      setState(() {
                        bedtimeGoalText = bedtime;
                        durationGoalText = duration;
                      });
                    } else {
                      setState(() {
                        bedtimeGoalText = 'Not Set';
                        durationGoalText = 'Not Set';
                      });
                    }
                  }).catchError((error) {
                    Text('Error: $error');
                  });}
    return Scaffold(
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
          Expanded(
            child: SizedBox(
              height: 40,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white60,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  border: Border.all(color: Colors.black12, width: 2),
                ),
                child: Center(
                  child: Text("Bedtime at $bedtimeGoalText and wake up at $durationGoalText"),
                ),
              ),
            ),
          ),

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
                  sleepRating = rating.toInt();
                });
              },
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5.0), // Adjust the vertical padding as needed
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white60,
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        border: Border.all(color: Colors.black12, width: 2),
                      ),
                      child: Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UpdateSleepGoals()),
                            );
                          },
                          child: const Text("New Sleep Goal"),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // NewLog widget: allows the user to manually create a new Sleep Log

          Container(
            padding: const EdgeInsets.symmetric(vertical: 5.0), // Adjust the vertical padding as needed
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white60,
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        border: Border.all(color: Colors.black12, width: 2),
                      ),
                      child: Center(
                      child: TextButton(
                          onPressed: uploadNewSleepLog,
                          child: const Text("New Log (Auto)")),
                    )
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 5.0), // Adjust the vertical padding as needed
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white60,
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        border: Border.all(color: Colors.black12, width: 2),
                      ),
                      child: Center(
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const CreateNewSleepLog();
                            }));
                          },
                          child: const Text("New Log (Manual)")),
                    )
                    ),
                  ),
                ),
              ],
            ),
          ),

          ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                ),
                
                onPressed: () {
                },

                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Bedtime Goal: $bedtimeGoalText',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Duration Goal: $durationGoalText',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
          ),
          //Grab logs from DB
          StreamBuilder<List<SleepLog>>(
              stream: readSleepLogs(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error');
                } else if (snapshot.hasData) {
                  var allSleepLogs = snapshot.data!;

                  return Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(4),
                      children: <Widget>[
                        for (int index = 0; index < (allSleepLogs.length < 5 ? allSleepLogs.length : 5); index++)
                          ElevatedButton(
                            style: const ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
                              foregroundColor: MaterialStatePropertyAll<Color>(Colors.black),
                            ),
                            onPressed: () {
                              // TODO: fill in
                              // leads to a more verbose log that lists all elements of the log as well as the options to edit/delete the entry
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Date/Time: ${DateFormat('M/d - h:mm a').format(allSleepLogs[index].bedTime.add(const Duration(hours: -7)))}",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "Duration: ${allSleepLogs[index].awakeTime.difference(allSleepLogs[index].bedTime).toString().split(':').take(2).join(':')}",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ListTile(
                          title: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MoreLogs(),
                                ),
                              );
                            },
                            child: const Text('More Logs...'),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
        ],
      )
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

class UpdateSleepGoals extends StatelessWidget {
  final TextEditingController _bedtimeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Goals'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _bedtimeController,
              decoration: const InputDecoration(
                labelText: 'Enter your desired bedtime',
              ),
            ),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Enter your desired sleep duration (in hours)',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String bedtimeText = _bedtimeController.text;
                String durationText = _durationController.text;

                User? user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  return;
                }
                String uid = user.uid;

                DocumentReference sleepGoalsCollection = FirebaseFirestore.instance.collection('sleep_goals').doc(uid);
                Map<String, dynamic> sleepData = {
                  'bedtime': bedtimeText,
                  'duration': durationText,
                };
                
                sleepGoalsCollection.set(sleepData).then((value) {
                  const Text('Data saved successfully');
                  Navigator.pop(context);
                }).catchError((error) {
                  Text('Error: $error');
                });
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}