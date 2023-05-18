import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:custom_timer/custom_timer.dart';
import 'package:everyday_wellness_cs125/Misc/profile_page.dart';
import 'package:everyday_wellness_cs125/Exercise/new_exercise_log.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

// Referenced https://morioh.com/p/e69fead3f719

// TODO: Remaining tasks:
// - Determine the thresholds for walking running, and biking.
// - If the exercise lasts longer than 5 minutes, store it in firebase with:
//        - Time started,
//        - How long exercise lasted,
//        - Type of exercise (walking, etc.).
// - Have everything run in the background.
// - Update the manual logs to go to firbase.
// - Show all logs in the log list.
// - Based on the data, make recommendations (based on what we dicussed).
//        - Check to see if they reached 30 minutes of activity.

// Completed:
// - Allow the user to turn on/off automatic data collection.

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

  @override
  Widget build(BuildContext context) {
    final userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        .toList();

    return Scaffold(
      // AppBar: basic bar at top of every page
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

      // Body starts here
      body: Center(
          child: Column(
        children: [
          // Allow user to turn on or off automatic data collection.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Automatic Data Collection:"),
              Switch(value: toggleAutoDataCollection, onChanged: toggleSwitch),
            ],
          ),

          CustomTimer(
              controller: controller,
              builder: (state, time) {
                return Text(
                    "${time.hours}:${time.minutes}:${time.seconds}.${time.milliseconds}",
                    style: const TextStyle(fontSize: 24.0));
              }),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('UserAccelerometer: $userAccelerometer'),
              ],
            ),
          ),

          // Recommendation box: displays the current recommendation to the user
          Expanded(
              child: DecoratedBox(
            decoration: BoxDecoration(
                color: Colors.white60,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                border: Border.all(color: Colors.black12, width: 2)),
            child: const Center(
                // TODO: replace with actual information
                child: Text("Recommendation")),
          )),

          // NewLog widget: allows the user to manually create a new Sleep Log
          Expanded(
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
                  ))),

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
          ))
          //Expanded(child: )
        ],
      ) //Text('hi'),
          ),
    );
  }

  // Like the __init__ of the page.
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
                    ((event.x.round() >= 1 || event.x.round() <= -1) ||
                        (event.y.round() >= 1 || event.y.round() <= -1) ||
                        (event.z.round() >= 1 || event.z.round() <= -1))) {
                  // Save the time of when the timer started (if there wasn't already a time).
                  if (gotExcersieStart == false) {
                    exerciseStart = DateTime.now();
                    gotExcersieStart = true;
                  }
                  // Start the timer.
                  controller.start();
                  // When movement comes to a stop, then save the data.
                } else {
                  // Don't let the timer continue.
                  lockTimer = true;

                  // Save the contents of the timer.
                  controller.pause();
                  var hours = int.parse(controller.remaining.value.hours);
                  var minutes = int.parse(controller.remaining.value.minutes);
                  var seconds = int.parse(controller.remaining.value.seconds);

                  if (seconds > 0) {
                    print(seconds);
                  }
                  lockTimer = false;
                }
              } catch (e) {
                print(e);
              }
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
