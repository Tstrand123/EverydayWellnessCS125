import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:custom_timer/custom_timer.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

// Referenced https://morioh.com/p/e69fead3f719

// Remaining tasks:
// - Determine the thresholds for walking running, and biking.
// - If the exercise lasts longer than 5 minutes, store it in firebase with:
//        - Time started,
//        - How long exercise lasted,
//        - Type of exercise (walking, etc.).
// - Have everything run in the background.
// - Allow the user to turn on/off automatic data collection.
// - Update the manual logs to go to firbase.
// - Show all logs in the log list.
// - Based on the data, make recommendations (based on what we dicussed).
//        - Check to see if they reached 30 minutes of activity.

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  SensorPageState createState() => SensorPageState();
}

class SensorPageState extends State<SensorPage>
    with SingleTickerProviderStateMixin {
  // Store the values of the sensors:
  //List<double>? _accelerometerValues;
  List<double>? _userAccelerometerValues;
  //List<double>? _gyroscopeValues;
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

  // Paints the UI for the page.
  @override
  Widget build(BuildContext context) {
    // Prepare sensors.
    /*
    final accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
    */
    final userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // paints the bar that appears at the top of every page
        title: const Text('Test Sensors'),
        // This button is the one to get to the profile, it exists on every appbar, on every page
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.account_circle_rounded),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          /*
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Accelerometer: $accelerometer'),
              ],
            ),
          ),
          */
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('UserAccelerometer: $userAccelerometer'),
              ],
            ),
          ),
          /*
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Gyroscope: $gyroscope'),
              ],
            ),
          ),
          */
          CustomTimer(
              controller: controller,
              builder: (state, time) {
                // Build the widget you want!🎉
                return Text(
                    "${time.hours}:${time.minutes}:${time.seconds}.${time.milliseconds}",
                    style: const TextStyle(fontSize: 24.0));
              }),
          ButtonBar(
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
                  child: const Text('Pause Timer'))
            ],
          )
        ],
      ),
    );
  }

  // Like the __init__ of the page.
  @override
  void initState() {
    super.initState();
    /*
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          setState(() {
            _accelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(
      gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          setState(() {
            _gyroscopeValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    */
    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          setState(() {
            _userAccelerometerValues = <double>[event.x, event.y, event.z];
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
            } else {
              // Don't let the timer continue.
              lockTimer = true;

              // Save the contents of the timer.
              controller.pause();
              String hours = controller.remaining.value.hours;
              String minutes = controller.remaining.value.minutes;
              String seconds = controller.remaining.value.seconds;
              //print('hours: $hours');
              //print('minutes: $minutes');
              //print('seconds: $seconds');
              lockTimer = false;
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
