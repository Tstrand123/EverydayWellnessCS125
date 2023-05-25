// This is just a redesign of the new_exercise_log.dart.
// This file will allow users to create manual logs of their exercise data.

import 'exercise.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everyday_wellness_cs125/Misc/app_classes.dart';
import 'package:everyday_wellness_cs125/Misc/profile_page.dart';

// Exercise type options for dropdown box.
const List<String> exerciseTypes = <String>[
  'Select Type',
  'Running',
  'Walking',
  'Weightlifting',
  'Interval training',
  'Biking'
];

class CreateNewExerciseLog extends StatelessWidget {
  const CreateNewExerciseLog({super.key});

  @override
  Widget build(BuildContext context) {
    const formTitle = 'Create New Log';
    return MaterialApp(
        title: formTitle,
        home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            // paints the bar that appears at the top of every page
            title: const Text('Create Exercise Log'),
            // This button is the one to get to the profile, it exists on every appbar, on every page
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
          body: const NewExerciseLog(),
        ));
  }
}

class NewExerciseLog extends StatefulWidget {
  const NewExerciseLog({super.key});

  @override
  NewExerciseLogState createState() {
    return NewExerciseLogState();
  }
}

// paint the rest of the log
class NewExerciseLogState extends State<NewExerciseLog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController timeInput = TextEditingController();
  TextEditingController durationInput = TextEditingController();

  String dropdownVal = exerciseTypes.first;

  void saveToFirebase() {
    // Seperate the mihutes into hours and minutes.
    int duration = int.parse(durationInput.text);
    int hour = duration ~/ 60;
    int minutes = duration % 60;

    final userID = FirebaseAuth.instance.currentUser!.uid;
    final dataUpload = ExerciseLog(
        hours: hour,
        minutes: minutes,
        seconds: 0,
        startTime: timeInput.text,
        type: dropdownVal);

    // Upload data to firebase.
    DateTime currentDay = DateTime.now();
    String day = '${currentDay.year}-${currentDay.day}-${currentDay.month}';
    final docLocation = FirebaseFirestore.instance
        .collection('ExerciseLogs')
        .doc(userID)
        .collection(day)
        .doc(timeInput.text);
    docLocation.set(dataUpload.toJson());
  }

  @override
  Widget build(BuildContext context) {
    Widget timePickerField = Container(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: TextFormField(
            controller: timeInput,
            decoration: const InputDecoration(
              icon: Icon(Icons.schedule),
              hintText: '',
              labelText: 'What time did you start exercising?',
            ),
            readOnly: true,
            onTap: () async {
              TimeOfDay? pickedTime = await showTimePicker(
                  context: context, initialTime: TimeOfDay.now());
              if (pickedTime != null) {
                String formattedTime =
                    '${pickedTime.hour.toString()}:${pickedTime.minute.toString()}';
                setState(() {
                  timeInput.text = formattedTime;
                });
              } else {}
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please pick a time.';
              }
              return null;
            },
          ),
        ));

    Widget durationField = Container(
        padding: const EdgeInsets.all(8),
        child: TextFormField(
          controller: durationInput,
          decoration: const InputDecoration(
            icon: Icon(Icons.timer),
            hintText: '',
            labelText: 'How long did you exercise (in minutes)?',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a number.';
            }
            var number = int.tryParse(value);
            if (number == null) {
              return 'Please enter a number.';
            }
            return null;
          },
        ));

    Widget dropdown = Container(
        padding: const EdgeInsets.all(8),
        child: DropdownButtonFormField(
          value: dropdownVal,
          icon: const Icon(
            Icons.arrow_downward,
          ),
          elevation: 16,
          onChanged: (String? value) {
            setState(() {
              dropdownVal = value!;
            });
          },
          validator: (value) {
            if (exerciseTypes.indexOf(dropdownVal) == 0) {
              return 'Field required';
            } else {
              return null;
            }
          },
          items: exerciseTypes.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ));

    Widget submit = Center(
        child: ElevatedButton(
      child: const Text('Submit'),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          // Save manual log to firebase.
          saveToFirebase();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saving exercise log.')),
          );
          // When done, reload the exercise home page
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const ExerciseHome();
          }));
        }
      },
    ));

    return Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            Row(children: [Expanded(child: timePickerField)]),
            Row(children: [Expanded(child: durationField)]),
            Row(children: [Expanded(child: dropdown)]),
            Row(children: [Expanded(child: submit)])
          ],
        ));
  }
}
