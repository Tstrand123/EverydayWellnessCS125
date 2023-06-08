import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CreateNewSleepLog extends StatelessWidget {
  const CreateNewSleepLog({Key? key}) : super(key: key);

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
          title: const Text('Create New Log'),
          // This button is the one to get to the profile, it exists on every appbar, on every page
          actions: <Widget>[
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.account_circle_rounded),
            )
          ],
        ),
        body: const NewSleepLog(),
      ),
    );
  }
}

class NewSleepLog extends StatefulWidget {
  const NewSleepLog({Key? key}) : super(key: key);

  @override
  NewSleepLogState createState() => NewSleepLogState();
}

class NewSleepLogState extends State<NewSleepLog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController dateInput = TextEditingController();
  TextEditingController dateInput2 = TextEditingController();
  TextEditingController sleepTimeInput = TextEditingController();
  TextEditingController wakeTimeInput = TextEditingController();
  int sleepRatingValue = 0;

  @override
  Widget build(BuildContext context) {
    Widget datePickerField = Container(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: TextField(
          controller: dateInput,
          decoration: const InputDecoration(
            icon: Icon(Icons.calendar_month),
            labelText: "Enter Date",
          ),
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              String formattedDate = DateFormat('M/d/y').format(pickedDate);
              setState(() {
                dateInput.text = formattedDate;
              });
            }
          },
        ),
      ),
    );

    Widget sleepPicker = Container(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: TextField(
          controller: sleepTimeInput,
          decoration: const InputDecoration(
            icon: Icon(Icons.schedule),
            hintText: '',
            labelText: 'Bed Time',
          ),
          readOnly: true,
          onTap: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (pickedTime != null) {
              String formattedTime =
                  '${pickedTime.hour.toString()}:${pickedTime.minute.toString().padLeft(2, '0')}';
              setState(() {
                sleepTimeInput.text = formattedTime;
              });
            }
          },
        ),
      ),
    );

    Widget datePickerField2 = Container(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: TextField(
          controller: dateInput2,
          decoration: const InputDecoration(
            icon: Icon(Icons.calendar_month),
            labelText: "Enter Date",
          ),
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              String formattedDate = DateFormat('M/d/y').format(pickedDate);
              setState(() {
                dateInput2.text = formattedDate;
              });
            }
          },
        ),
      ),
    );

    Widget wakeUpPicker = Container(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: TextField(
          controller: wakeTimeInput,
          decoration: const InputDecoration(
            icon: Icon(Icons.schedule),
            hintText: '',
            labelText: 'Wake up time',
          ),
          readOnly: true,
          onTap: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (pickedTime != null) {
              String formattedTime =
                  '${pickedTime.hour.toString()}:${pickedTime.minute.toString().padLeft(2, '0')}';
              setState(() {
                wakeTimeInput.text = formattedTime;
              });
            }
          },
        ),
      ),
    );

    Widget sleepRating = Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: RatingBar(
          initialRating: 0,
          minRating: 0,
          maxRating: 5,
          allowHalfRating: true,
          itemSize: 30.0,
          ratingWidget: RatingWidget(
            full: const Icon(Icons.star, color: Colors.amber),
            half: const Icon(Icons.star, color: Colors.amber),
            empty: const Icon(
              Icons.star,
              color: Colors.grey,
            ),
          ),
          onRatingUpdate: (rating) {
            setState(() {
              sleepRatingValue = rating.toInt();
            });
          },
        ),
      ),
    );

    Widget submit = Center(
      child: ElevatedButton(
        child: const Text('Submit'),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Processing Data')),
            );

            saveSleepLogData().then((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved successfully! You can click out of this page.')),
              );
            }).catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to save data')),
              );
              print('Error saving data: $error');
            });
          }
        },
      ),
    );


    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          Row(children: [Expanded(child: datePickerField)]),
          Row(children: [Expanded(child: sleepPicker)]),
          Row(children: [Expanded(child: datePickerField2)]),
          Row(children: [Expanded(child: wakeUpPicker)]),
          Row(
            children: [Expanded(child: sleepRating)],
          ),
          Row(children: [Expanded(child: submit)])
        ],
      ),
    );
  }

  Future<void> saveSleepLogData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user!.uid;

    final CollectionReference logsCollection =
        FirebaseFirestore.instance.collection('SleepLogs');

    final DateTime now = DateTime.now().toUtc();
    final String documentName = '$userId-${DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(now)}';
    final String dI = dateInput.text;
    final String bTI = sleepTimeInput.text;
    final String dI2 = dateInput2.text;
    final String wTI = wakeTimeInput.text;

    final Map<String, dynamic> logData = {
      'awakeTime': Timestamp.fromDate(DateFormat('M/d/y HH:mm').parse('$dI2 $wTI')),
      'bedTime': Timestamp.fromDate(DateFormat('M/d/y HH:mm').parse('$dI $bTI')),
      'rating': sleepRatingValue,
      'userID': userId,
    };

    await logsCollection.doc(documentName).set(logData);
  }
}
