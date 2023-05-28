import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//import 'package:firebase_database/firebase_database.dart';

import 'food.dart';

class CreateNewFoodLog extends StatelessWidget {
  const CreateNewFoodLog({super.key});
  // TODO: create a button to load preset values (meals stored in the database with which we can use to generate recommendations)
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
          body: const NewFoodLog(),
        ));
  }
}
Map<int, dynamic> testMap = {0: {'name': "test1", 'calories': 300, 'fat': 20, 'carbs': 45, 'protein': 12},
  1: {'name': "test2", 'calories': 301, 'fat': 21, 'carbs': 46, 'protein': 13},
  2: {'name': "test3", 'calories': 302, 'fat': 22, 'carbs': 47, 'protein': 14}};

class PresetState extends StatefulWidget {
  const PresetState({super.key});

  @override
  PresetsDialog createState() {
    return PresetsDialog();
  }
}

class PresetsDialog extends State<PresetState>{
  final _dialogKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context){
    return SimpleDialog(
      children: <Widget>[
        // get data from database, store as a map
        //final QuerySnapshot<Map<int, dynamic>> MealMap = await FirebaseFirestore.instance.collection("meals").get();
        // loop through entries of map
        for (int i = 0; i < testMap.length; i++ )
          ElevatedButton( // create a button for each map entry
              onPressed: (){
                // return the meal_id
                Navigator.pop(context, i); // return the id of the meal
              },
              child: Row(children: [Text("${testMap[i]['name']}")])
          )
        // }
        // TODO: get meal values from database and load names into list
      ],);
  }
}

class NewFoodLog extends StatefulWidget {
  const NewFoodLog({super.key});

  @override
  NewFoodLogState createState() {
    return NewFoodLogState();
  }
}

class NewFoodLogState extends State<NewFoodLog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController dateInput = TextEditingController(); // controllers, for altering the values of widgets
  TextEditingController timeInput = TextEditingController();
  TextEditingController nameCont = TextEditingController();
  TextEditingController calControl = TextEditingController();
  TextEditingController fatControl = TextEditingController();
  TextEditingController proteinControl = TextEditingController();
  TextEditingController carbControl = TextEditingController();

  @override
  Widget build(BuildContext context) {
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

    /*Widget TimeField = TextFormField(       // removed, replaced with date/time pickers
        decoration: const InputDecoration(
          icon: const Icon(Icons.schedule),
          hintText: 'When did you eat?',
          labelText: 'Time',
        ),
      validator: (value){
        if (value == null || value.isEmpty){
          return 'Please enter text';
        }
        return null;
      },
    );*/

    Widget timePickerField = Container(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: TextField(
            controller: timeInput,
            decoration: const InputDecoration(
              icon: Icon(Icons.schedule),
              hintText: '',
              labelText: 'Time',
            ),
            readOnly: true,
            onTap: () async {
              TimeOfDay? pickedTime = await showTimePicker(
                  context: context, initialTime: TimeOfDay.now());
              if (pickedTime != null) {
                String formattedTime =
                    '${pickedTime.hour.toString()} : ${pickedTime.minute.toString()}';
                setState(() {
                  timeInput.text = formattedTime;
                });
              } else {}
            },
          ),
        ));

    Widget presetButton = ElevatedButton(
      style: const ButtonStyle(
        alignment: Alignment.center,
      ),
        onPressed: () async{
        // when pressed, display a dialog
          int result = await showDialog(context: context,
              builder: (BuildContext context) => const PresetState());

          // get the meal id of the dialog from the future element
          if (result >= 0 && result <= testMap.length) {
            nameCont.text = testMap[result]['name'];
            calControl.text = testMap[result]['calories'].toString();
            fatControl.text = testMap[result]['fat'].toString();
            proteinControl.text = testMap[result]['protein'].toString();
            carbControl.text = testMap[result]['carbs'].toString();
          }
        // change the values of each of the below elements to the values of the meal

      // ALT: automatically submit without letting the user modify anything, but ask them to rate it.

        },
        child: const Text("Select from presets"));


    Widget nameField = TextFormField(
      controller: nameCont,
      decoration: const InputDecoration(
        icon: Icon(Icons.fastfood),
        hintText: 'What did you eat?',
        labelText: 'Name',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter text';
        }
        return null;
      },

    );

    Widget caloriesField = TextFormField(
      controller: calControl,
      decoration: const InputDecoration(
        icon: Icon(Icons.scale),
        hintText: 'How many total calories?',
        labelText: 'Calories',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a number';
        }
        var number = int.tryParse(value);
        if (number == null) {
          return 'Please enter a number';
        }
        return null;
      },
    );

    Widget fatField = TextFormField(
      controller: fatControl,
      decoration: const InputDecoration(
        icon: Icon(Icons.scale),
        hintText: 'How many total grams of fat?',
        labelText: 'Fat',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a number';
        }
        var number = int.tryParse(value);
        if (number == null) {
          return 'Please enter a number';
        }
        return null;
      },
    );

    Widget proteinField = TextFormField(
      controller: proteinControl,
      decoration: const InputDecoration(
        icon: Icon(Icons.scale),
        hintText: 'How many grams of protein?',
        labelText: 'Protein',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a number';
        }
        var number = int.tryParse(value);
        if (number == null) {
          return 'Please enter a number';
        }
        return null;
      },
    );

    Widget carbsField = TextFormField(
      controller: carbControl,
      decoration: const InputDecoration(
        icon: Icon(Icons.scale),
        hintText: 'How many total grams of Carbohydrates?',
        labelText: 'Carbohydrates',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a number';
        }
        var number = int.tryParse(value);
        if (number == null) {
          return 'Please enter a number';
        }
        return null;
      },
    );

    Widget foodRating = Container(
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
            return const FoodHome(title: 'FoodHome');
          }));
        }
      },
    ));

    // TODO: include validation
    return Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            Row(
              children: [Expanded(child: datePickerField)],
            ),
            Row(children: [Expanded(child: timePickerField)]),
            Row(children: [Expanded(child: presetButton)],),
            Row(children: [Expanded(child: nameField)]),
            Row(children: [Expanded(child: caloriesField)]),
            Row(children: [Expanded(child: fatField)]),
            Row(children: [Expanded(child: proteinField)]),
            Row(children: [Expanded(child: carbsField)]),
            Row(
              children: [Expanded(child: foodRating)],
            ),
            Row(children: [Expanded(child: submit)])
          ],
        ));
  }
}
