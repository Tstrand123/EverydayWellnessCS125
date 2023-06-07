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
// - Show all logs in the log list.

// Global variable of months.
List<String> months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];

// Get lifestyle score for exercise.
Future<int> getExerciseScore() async {
  num neededMinutes = 30;

  int result = await FirebaseFirestore.instance
      .collection('ExerciseLogs')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection(
          '${DateTime.now().year}-${DateTime.now().day}-${DateTime.now().month}')
      .get()
      .then((document) {
    for (var log in document.docs) {
      // If the log shows > than neededMinutes, then return .
      neededMinutes -= log['minutes'];
      if (log['hours'] != 0 || neededMinutes <= -1) {
        neededMinutes = 0;
        return Future.value(50);
      }
    }
    if (neededMinutes < 10) {
      return Future.value(45);
    } else if (neededMinutes < 15) {
      return Future.value(25);
    } else if (neededMinutes < 20) {
      return Future.value(15);
    } else if (neededMinutes < 25) {
      return Future.value(5);
    } else {
      return Future.value(0);
    }
  });
  return result;
}

// Calculate recommendation for exercise.
List getExerciseRec() {
  Widget streamText = StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('ExerciseLogs')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection(
              '${DateTime.now().year}-${DateTime.now().day}-${DateTime.now().month}')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot) {
        // Base exercise time for all users.
        num neededMinutes = 30;
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          for (var log in snapshot.data!.docs) {
            // If the log shows > than neededMinutes, then set the correct widgets.
            neededMinutes -= log['minutes'];
            if (log['hours'] != 0 || neededMinutes <= -1) {
              neededMinutes = 0;
              break;
            }
          }
          // If there is still time needed to exercise, return that time.
          if (neededMinutes > 0) {
            return Text("Remaining exercise time: $neededMinutes min");
            // Otherwise, return the completion message.
          } else {
            return const Text("All finished exercising for today!");
          }
          // Return their needed time to exercise.
        } else {
          return Text("Remaining exercise time: $neededMinutes min");
        }
      });

  // Get the color of the dot for the main page.
  Widget streamColor = StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('ExerciseLogs')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection(
              '${DateTime.now().year}-${DateTime.now().day}-${DateTime.now().month}')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot) {
        // Base exercise time for all users.
        num neededMinutes = 30;
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          for (var log in snapshot.data!.docs) {
            // If the log shows > than neededMinutes, then set the correct widgets.
            neededMinutes -= log['minutes'];
            if (log['hours'] != 0 || neededMinutes <= -1) {
              neededMinutes = 0;
              return const Icon(Icons.circle,
                  color: Color.fromARGB(255, 36, 131, 17));
            }
          }
        }
        return const Icon(Icons.circle,
            color: Color.fromARGB(255, 155, 154, 154));
      });
  return [streamText, streamColor];
}

// Create an Exercise home page.
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
  late CustomTimerController timerController = CustomTimerController(
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

  // Time needed to exercise
  num neededMinutes = 30;
  bool calculatedMin = false;

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
        hours: int.parse(timerController.remaining.value.hours),
        minutes: int.parse(timerController.remaining.value.minutes),
        seconds: int.parse(timerController.remaining.value.seconds),
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

  // Convert from military time to standard time.
  String convertTime(String time) {
    final splitTime = time.split(':');
    if (int.parse(splitTime[0]) < 12) {
      if (int.parse(splitTime[1]) < 9) {
        return "${splitTime[0]}:0${splitTime[1]} am";
      }
      return "${splitTime[0]}:${splitTime[1]} am";
    } else {
      if (int.parse(splitTime[1]) < 9) {
        return "${int.parse(splitTime[0]) - 12}:0${splitTime[1]} pm";
      }
      return "${int.parse(splitTime[0]) - 12}:${splitTime[1]} pm";
    }
  }

  String convertExercise(int hour, int minutes) {
    if (hour == 0) {
      return "$minutes min";
    }
    return "$hour h, $minutes min";
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
          child: Center(
            child: getExerciseRec()[0],
          )),
    );

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

    // Display the current day.
    Widget currentDay = Container(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 4),
      child: Text(
        'Logs for ${months[DateTime.now().month - 1]} ${DateTime.now().day}, ${DateTime.now().year}:',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
        textAlign: TextAlign.center,
      ),
    );

    // Will display the logs for the current day.
    // Referenced: https://www.youtube.com/watch?v=qlxhqXnyUPw
    Widget logList = StreamBuilder(
        // Get data from firebase (in the form of snapshots)/
        stream: FirebaseFirestore.instance
            .collection('ExerciseLogs')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection(
                '${DateTime.now().year}-${DateTime.now().day}-${DateTime.now().month}')
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot) {
          // Check if the snapshot has any data.
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            // Return a box that will contain the ListView widget.
            return SizedBox(
                height: 300,
                child: ListView(
                    padding: const EdgeInsets.all(8),
                    // Return an elevated button for each document in the snapshot.
                    children: snapshot.data!.docs.map((document) {
                      return ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                const MaterialStatePropertyAll<Color>(
                                    Colors.white),
                            foregroundColor:
                                const MaterialStatePropertyAll<Color>(
                                    Colors.black),
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                const EdgeInsets.all(10)),
                          ),
                          onPressed: () {},
                          // Write information into the display of the button.
                          child: Row(children: [
                            Expanded(
                                child: Text(
                              convertTime("${document.get('startTime')}"),
                              textAlign: TextAlign.center,
                            )),
                            Expanded(
                                child: Text(
                              convertExercise(document.get('hours'),
                                  document.get('minutes')),
                              textAlign: TextAlign.center,
                            )),
                            Expanded(
                                child: Text(
                              "Type: ${document.get('type')}",
                              textAlign: TextAlign.center,
                            ))
                          ]));
                    }).toList()));
            // If there is no data, return a simple container telling the user that fact.
          } else {
            return Container(
              height: 300,
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 4),
              child: const Text(
                "No exercise logged yet.",
                textAlign: TextAlign.center,
              ),
            );
          }
        });

    // Widgets used for debugging.
    /*
    final userAccelerometer = _userAccelerometerValues
        /?.map((double v) => v.toStringAsFixed(1))
        .toList();

    StatefulWidget timer = CustomTimer(
        controller: timerController,
        builder: (state, time) {
          return Text(
              "${time.hours}:${time.minutes}:${time.seconds}.${time.milliseconds}",
              style: const TextStyle(fontSize: 24.0));
        });

    Widget testButtons = ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            onPressed: () => timerController.start(),
            child: const Text('Start Timer')),
        ElevatedButton(
            onPressed: () => timerController.reset(),
            child: const Text('Reset Timer')),
        ElevatedButton(
            onPressed: () => timerController.pause(),
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
          currentDay,
          logList,
        ],
      )),
    );
  }

  @override
  void initState() {
    super.initState();
    // Automatic data collection.
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
                    timerController.start();
                  }

                  // Calculate average movement (every few seconds).
                  if (int.parse(timerController.remaining.value.seconds) % 3 ==
                      0) {
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
                    if (int.parse(timerController.remaining.value.minutes) >
                        3) {
                      // Store information in firebase.
                      timerController.pause();
                      saveToFirebase();
                    }
                    // Reset everything.
                    timerController.reset();
                    gotExcersieStart = false;
                    averageX = 0;
                    averageY = 0;
                    averageZ = 0;
                    totalCounts = 0;
                    lockTimer = false;
                  }
                }
              } catch (e) {/* Just move on. */}
            } else {
              // Reset timer if automatic data collection is off.
              timerController.reset();
            }
          });
        },
      ),
    );
  }

  // Destructor of the page.
  @override
  void dispose() {
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    if (gotExcersieStart) {
      timerController.dispose();
    }

    super.dispose();
  }
}
