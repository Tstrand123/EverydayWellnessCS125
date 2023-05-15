import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

// Referenced https://morioh.com/p/e69fead3f719

// Goals for this page:
//  (Background process) When there is a change in the accelerometer,
//    start a timer to determine how long the phone is moving. If the time is
//    significant (longer than 5 minutes), then be ready to store that as exercise.
//    Keep an average of the speed of the accelerometer to determine what kind of activity
//    is being done (walking, running, biking).

// When storing data, be sure to include the date. Whenever the user opens the app,
//  combine all the exercise data into one log and recommend what needs to be done next.

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  SensorPageState createState() => SensorPageState();
}

class SensorPageState extends State<SensorPage> {
  List<double>? _accelerometerValues;
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  @override
  Widget build(BuildContext context) {
    final accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Accelerometer: $accelerometer'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('UserAccelerometer: $userAccelerometer'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Gyroscope: $gyroscope'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
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
    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          setState(() {
            _userAccelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
  }
}
