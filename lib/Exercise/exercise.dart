import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:custom_timer/custom_timer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everyday_wellness_cs125/Misc/app_classes.dart';
import 'package:everyday_wellness_cs125/Misc/profile_page.dart';
import 'package:everyday_wellness_cs125/Exercise/manual_exercise_log.dart';

// Referenced https://morioh.com/p/e69fead3f719

// TODO: Remaining tasks:
// - Show all logs in the log list.
// - Based on the data, make recommendations (based on what we dicussed).
//        - Check to see if they reached 30 minutes of activity.
//        - Update that based on if they went over their calorie count.

// Completed:
// - Allow the user to turn on/off automatic data collection.
// - Determine the thresholds for walking running, and biking.
// - If the exercise lasts longer than 3 minutes, store it in firebase with:
//        - Time started,
//        - How long exercise lasted,
//        - Type of exercise (walking, etc.).
// - Update the manual logs to go to firbase.

class ExerciseHome extends StatefulWidget {
  const ExerciseHome({super.key});

  @override
  ExerciseHomeState createState() => ExerciseHomeState();
}

class ExerciseHomeState extends State<ExerciseHome>
    with SingleTickerProviderStateMixin {
  // Set up selections for on/off regarding auto data collection.
  bool toggleAutoDataCollection = true;

  // Store the values of the accelerometer.
  List<double>? _userAccelerometerValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  // Get the user's id.
  final userID = FirebaseAuth.instance.currentUser!.uid;

  // Create a custom timer controller:
  late CustomTimerController controller = CustomTimerController(
      vsync: this,
      begin: const Duration(),
      end: const Duration(hours: 24),
      initialState: CustomTimerState.finished,
      interval: CustomTimerInterval.milliseconds);

  // Create value to lock the timer (for when we need to process it).
  bool lockTimer = false;

  // Save the start of the exercise (should be null if no exercise has started).
  bool gotExcersieStart = false;
  DateTime exerciseStart = DateTime.now();
  double averageX = 0;
  double averageY = 0;
  double averageZ = 0;
  int totalCounts = 0;

  // Allow the user to turn on and off automatic data collection.
  void toggleSwitch(bool value) {
    if (toggleAutoDataCollection == false) {
      setState(() {
        toggleAutoDataCollection = true;
      });
    } else {
      setState(() {
        toggleAutoDataCollection = false;
      });
    }
  }

  // Save data (time, exercise type, etc.) to firebase.
  void saveToFirebase() {
    // Calculate the average speed.
    double totalAverage = 0.0;
    if (totalCounts != 0) {
      averageX /= totalCounts;
      averageY /= totalCounts;
      averageZ /= totalCounts;
      totalAverage = (averageX + averageY + averageZ) / 3;
    }

    // Determine if walking, running, or biking.
    String exerciseType;
    if (totalAverage >= 10) {
      exerciseType = "bike";
    } else if (totalAverage >= 5) {
      exerciseType = "run";
    } else {
      exerciseType = "walk";
    }

    // Prepare the data for firebase.
    final dataUpload = ExerciseLog(
        hours: int.parse(controller.remaining.value.hours),
        minutes: int.parse(controller.remaining.value.minutes),
        seconds: int.parse(controller.remaining.value.seconds),
        startTime: '${exerciseStart.hour}:${exerciseStart.minute}',
        type: exerciseType);

    // Upload data to firebase.
    String day =
        '${exerciseStart.year}-${exerciseStart.day}-${exerciseStart.month}';
    final docLocation = FirebaseFirestore.instance
        .collection('ExerciseLogs')
        .doc(userID)
        .collection(day)
        .doc('${exerciseStart.hour}:${exerciseStart.minute}');
    docLocation.set(dataUpload.toJson());
  }

  @override
  // Build the exercise page.
  Widget build(BuildContext context) {
    // Lets the user controll if automatic data is collected.
    Widget toggleDataCollection =
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("Automatic Data Collection:"),
      Switch(value: toggleAutoDataCollection, onChanged: toggleSwitch),
    ]);

    // Will display information about the recommendation.
    Widget recommendationBox = Expanded(
        child: DecoratedBox(
      decoration: BoxDecoration(
          color: Colors.white60,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: Colors.black12, width: 2)),
      child: const Center(
          // TODO: replace with actual information
          child: Text("Recommendation")),
    ));

    // Lets the user make a new exercise log.
    Widget newLog = Expanded(
        child: DecoratedBox(
            decoration: BoxDecoration(
                color: Colors.white60,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                border: Border.all(color: Colors.black12, width: 2)),
            child: Center(
              child: TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const CreateNewExerciseLog();
                    }));
                  },
                  child: const Text("New Log")),
            )));

    // Will display the logs for the current day.
    /*
    Widget logList = Expanded(
        child: ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        for (int index = 1; index < 6; index++)
          ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
                foregroundColor: MaterialStatePropertyAll<Color>(Colors.black),
              ),
              onPressed: () {
                // TODO: fill in
                //  leads to a more verbose log that lists all elements of the log as well as the options to edit/delete the entry
              },
              child: Row(children: [
                Expanded(
                    child: Text(
                  "Date/Time: $index",
                  textAlign: TextAlign.center,
                )), // TODO: replace constant text with text retrieved from DB
                Expanded(
                    child: Text(
                  "type: $index",
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
    ));
    */

    // Referenced: https://www.youtube.com/watch?v=qlxhqXnyUPw
    String day =
        '${DateTime.now().year}-${DateTime.now().day}-${DateTime.now().month}';
    Widget updatedLogList = StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('ExerciseLogs')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection(day)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot) {
          try {
            return Expanded(
                child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: snapshot.data!.docs.map((document) {
                      return ElevatedButton(
                          style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll<Color>(Colors.white),
                            foregroundColor:
                                MaterialStatePropertyAll<Color>(Colors.black),
                          ),
                          onPressed: () {
                            // TODO: fill in
                          },
                          child: Row(children: [
                            Expanded(
                                child: Text(
                              "${document.get('startTime')}",
                              textAlign: TextAlign.center,
                            )),
                            Expanded(
                                child: Text(
                              "type: ${document.get('type')}",
                              textAlign: TextAlign.center,
                            ))
                          ]));
                    }).toList()));
          } catch (e) {
            print("No logs");
            return const Expanded(
              child: Text(
                "No logs for today.",
                textAlign: TextAlign.center,
              ),
            );
          }
        });

    Widget moreLogs = ListTile(
        title: TextButton(
      onPressed: () {},
      child: const Text('More Logs...'),
    ));

    // Widgets used for debugging.
    /*
    final userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        .toList();
    
    StatefulWidget timer = CustomTimer(
        controller: controller,
        builder: (state, time) {
          return Text(
              "${time.hours}:${time.minutes}:${time.seconds}.${time.milliseconds}",
              style: const TextStyle(fontSize: 24.0));
        });

    Widget testButtons = ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            onPressed: () => controller.start(),
            child: const Text('Start Timer')),
        ElevatedButton(
            onPressed: () => controller.reset(),
            child: const Text('Reset Timer')),
        ElevatedButton(
            onPressed: () => controller.pause(),
            child: const Text('Pause Timer')),
        ElevatedButton(
            onPressed: () => saveToFirebase(), child: const Text('Save'))
      ],
    );

    Widget accelerometer = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('UserAccelerometer: $userAccelerometer'),
        ],
      ),
    );
    */

    return Scaffold(
      // Set up an appbar.
      appBar: AppBar(
        title: const Text("Exercise Home"),
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

      body: Center(
          child: Column(
        children: [
          //testButtons,
          toggleDataCollection,
          //timer,
          //accelerometer,
          recommendationBox,
          newLog,
          updatedLogList,
          // moreLogs,
        ],
      )),
    );
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          setState(() {
            // Update the accelerometer values.
            _userAccelerometerValues = <double>[event.x, event.y, event.z];
            if (toggleAutoDataCollection == true) {
              try {
                // If movement is detected, then start the timer.
                if ((lockTimer == false) &&
                    (event.x.abs().round() >= 1 ||
                        event.y.abs().round() >= 1 ||
                        event.z.abs().round() >= 1)) {
                  // Save the time of when the timer started (if there wasn't already a time).
                  if (gotExcersieStart == false) {
                    exerciseStart = DateTime.now();
                    gotExcersieStart = true;

                    // Start the timer.
                    controller.start();
                  }

                  // Calculate average movement (every few seconds).
                  if (int.parse(controller.remaining.value.seconds) % 3 == 0) {
                    averageX += event.x.abs().round();
                    averageY += event.y.abs().round();
                    averageZ += event.z.abs().round();
                    totalCounts += 1;
                  }

                  // When movement comes to a stop, then save the data.
                } else {
                  if (gotExcersieStart == true) {
                    // Don't let the timer continue.
                    lockTimer = true;

                    // If the user "moved" for longer than 3 minutes, then store to firebase.
                    if (int.parse(controller.remaining.value.minutes) > 3) {
                      // Store information in firebase.
                      controller.pause();
                      saveToFirebase();

                      // Reset everything.
                      gotExcersieStart = false;
                      averageX = 0;
                      averageY = 0;
                      averageZ = 0;
                      totalCounts = 0;
                      lockTimer = false;
                    }
                  }
                }
              } catch (e) {/* Just move on. */}
              // Reset timer if automatic data collection is off.
            } else {
              controller.reset();
            }
          });
        },
      ),
    );
  }

  // Destructor of the page.
  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    controller.dispose();
  }
}
