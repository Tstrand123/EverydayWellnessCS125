import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import 'sleep.dart';

class CreateNewSleepLog extends StatelessWidget {
  const CreateNewSleepLog({super.key});

  @override
  Widget build(BuildContext context) {
    const formTitle = 'Create New Log';
    return MaterialApp(
        title: formTitle,
        home: Scaffold(
          appBar: AppBar(
            leading: IconButton(icon: const Icon(Icons.arrow_back),
              onPressed: (){Navigator.pop(context);},),
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
        ));
  }
}

class NewSleepLog extends StatefulWidget {
  const NewSleepLog({super.key});

  @override
  NewSleepLogState createState() {
    return NewSleepLogState();
  }
}

class NewSleepLogState extends State<NewSleepLog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController dateInput = TextEditingController();
  TextEditingController sleepTimeInput = TextEditingController();
  TextEditingController wakeTimeInput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    /*Widget BedTimeField = TextFormField( // Removed, replaced with date/time pickers
        decoration: const InputDecoration(
          icon: const Icon(Icons.schedule),
          hintText: 'When did you sleep?',
          labelText: 'Bed Time',
        ),
      validator: (value){
        if (value == null || value.isEmpty){
          return 'Please enter text';
        }
        return null;
      },
    );

    Widget DateField = TextFormField(
        decoration: const InputDecoration(
          icon: const Icon(Icons.calendar_month),
          hintText: 'What day?',
          labelText: 'Day',
        ),
      validator: (value){
        if (value == null || value.isEmpty){
          return 'Please enter text';
        }
        return null;
      },
    );

    Widget WakeTimeField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.schedule),
        hintText: 'What did you wake up?',
        labelText: 'Wake-up Time',
      ),
      validator: (value){
        if (value == null || value.isEmpty){
          return 'Please enter text';
        }
        return null;
      },
    );*/

    Widget datePickerField = Container(
        padding: const EdgeInsets.all(8),
        child: Center(
            child: TextField(
          controller: dateInput,
          decoration: const InputDecoration(
              icon: Icon(Icons.calendar_month), labelText: "Enter Date"),
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100));
            if (pickedDate != null) {
              String formattedDate = DateFormat('M/d/y').format(pickedDate);
              setState(() {
                dateInput.text = formattedDate;
              });
            } else {}
          },
        )));

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
                  context: context, initialTime: TimeOfDay.now());
              if (pickedTime != null) {
                String formattedTime =
                    '${pickedTime.hour.toString()} : ${pickedTime.minute.toString()}';
                setState(() {
                  sleepTimeInput.text = formattedTime;
                });
              } else {}
            },
          ),
        ));

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
                  context: context, initialTime: TimeOfDay.now());
              if (pickedTime != null) {
                String formattedTime =
                    '${pickedTime.hour.toString()} : ${pickedTime.minute.toString()}';
                setState(() {
                  wakeTimeInput.text = formattedTime;
                });
              } else {}
            },
          ),
        ));

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
            )),
        onRatingUpdate: (rating) {
          // TODO? capture change somehow or else wait for submit to do that for us?
        },
      )),
    );

    Widget submit = Center(
        child: ElevatedButton(
      child: const Text('Submit'),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          ScaffoldMessenger.of(context).showSnackBar(
            // TODO: send the data to the server
            const SnackBar(content: Text('Processing Data')),
          );
          // When done, reload the food home page
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const SleepHome(title: 'SleepHome');
          }));
        }
      },
    ));

    return Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            Row(children: [Expanded(child: datePickerField)]),
            Row(children: [Expanded(child: sleepPicker)]),
            Row(children: [Expanded(child: wakeUpPicker)]),
            Row(
              children: [Expanded(child: sleepRating)],
            ),
            Row(children: [Expanded(child: submit)])
          ],
        ));
  }
}
