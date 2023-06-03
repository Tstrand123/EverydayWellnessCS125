import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final Future<QuerySnapshot<Map<String, dynamic>>> snapshot =FirebaseFirestore.instance.collection("MealData").get();
  //final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context){
        // get data from database, store as a map
      return SimpleDialog(children: [
        //return
          FutureBuilder(
          future: snapshot,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snap){
              //snap = db.collection("MealData").get();
              List<Widget> children = [];
              if (snap.hasData){
                QuerySnapshot<Map<String, dynamic>> dataFromDB = snap.data!;
                 //children = <Widget>[
                  //for (int i = 0; i < MealMap.length; i++ ){
                for (var docSnapshot in dataFromDB.docs) {
                    children.add(ElevatedButton( // create a button for each map entry
                        onPressed: (){
                          // return the meal_id
                          // return the map entry of the selected ite:m; don't want to pass around the entire map
                          //Navigator.pop(context, MapEntry(i, MealMap[i]));
                          //print(docSnapshot.data);
                          // TODO: check if the user has already rated this meal and get the rating to display?
                          final mapEntries = <String, String>{"meal_id": docSnapshot.id, "name": "${docSnapshot.data()['name']}",
                            "protein": "${docSnapshot.data()['protein']}", "calories": "${docSnapshot.data()['calories']}",
                            "fat": "${docSnapshot.data()['fat']}","carbs": "${docSnapshot.data()['carbs']}"};
                          Map<String, String> m = Map.fromEntries(mapEntries.entries);
                          Navigator.pop(
                              //context, MapEntry(docSnapshot.id, docSnapshot.data()));
                              context,m);//docSnapshot.data());
                        },
                        //child: Row(children: [Text("${MealMap[i]['name']}")])
                        child: Row(children: [Expanded(child: Text("${docSnapshot.data()['name']}"))])
                    ));}
                //];
              }
              else {
                children = [const Text("Error")];
              }
             // return SimpleDialog(
                 // children: children);
              return Container(
                  height: 400,
                  child: ListView(children: children,));
            })
    ],);
        // BELOW HERE IS COPY OF WHAT WORKS WITH MAP<INT, DYNAMIC>
        // loop through entries of map

        // }
        // TODO: get meal values from database and load names into list

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
    DateTime MealTime = DateTime.now(); // holds the time and date of a meal, used to index the subcollection of a users meal and find meals that happened "today"; defaults to now
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
                // update the date info, time info stays the same
                 MealTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, MealTime.hour, MealTime.minute);
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
                  // update the hour and minute to the selected time; date info stays the same
                  MealTime = DateTime(MealTime.year, MealTime.month, MealTime.day, pickedTime.hour, pickedTime.minute);
                });
              } else {}
            },
          ),
        ));


    int meal_id = -1; // stores the value of the meal; if not a preset, then this is -1
    Widget presetButton = ElevatedButton(
      style: const ButtonStyle(
        alignment: Alignment.center,
      ),
        onPressed: () async{
        // when pressed, display a dialog
          Map<String, String> result = await showDialog(context: context,
              builder: (BuildContext context) => const PresetState());
          print(result);
          //for (var res in result.entries) {
            try {
              meal_id = int.parse(result['meal_id']!);
            }
            on FormatException {
              meal_id = -1;
            }
            // get the meal id of the dialog from the future element
            //if (res.key >= 0 && res.key <= testMap.length) {
            //if (meal_id >= 0){
              nameCont.text = result['name']!;
              calControl.text = result['calories']!;//.toString();
              fatControl.text = result['fat']!;//.toString();
              proteinControl.text = result['protein']!;//.toString();
              carbControl.text = result['carbs']!;//.toString();
            //}
          //}
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
  double thisRate = 0.0;
    Widget foodRating = Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Center(
          child: RatingBar(
        initialRating: thisRate,//0, // For already rated meal, can change this to be thisRate, then add code in onRatingUpdate to *update* the entry in the db, not add a new one
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
          // TODO? if the user selects a preset that htey've already rated, should the rating here update what they gave it last time?
          //    if they change the rating, would have to update the meal
          //      alternatively, do nothing different and hope it doesn't break anything?
          thisRate = rating;
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
          // upload data to firebase
          final userId = FirebaseAuth.instance.currentUser!.uid;
          var db = FirebaseFirestore.instance;
          var preset = false;
          if (meal_id != -1) { // Only allow ratings if the meal was a preset, to prevent user created meals from contaiminating the algo
            //preset = true; // if the meal was a preset,
            final RatingEntry = <String, String>{
              // TODO: need to collect everything, including rating and also meal values
              //"preset": preset.toString(), // not needed, all meals will be presets
              "meal_id": "$meal_id",
              "rating": "$thisRate"
            };
            /*db
                .collection(
                "user_ratings") // TODO: should be the name of the collection with user ratings
                .doc(userId) // TODO: might change the index
                .collection("meals").doc("$meal_id")
                .set(RatingEntry) // TODO: should this just be
                .onError((e, _) => print("error writing document: $e"));*/
            //TODO: upload user ID as a field to user_ratings documents
            db.collection("User_ratings").doc(userId).collection('ratings').doc("$meal_id").set(RatingEntry);
          }
          // TODO: create database for meal values (records the date, calories, fat, protien, and carbs, indexed by user_id)
          //      when determining the recommendations, take all entries from THIS user, on THIS day, and sum the values
          //      subtract from the recommended values to find deficit/surplus
          //      if the user is on track, then that causes a positive score to their health rating, otherwise, a negative one (primarily regarding carbs and fat)
          /*final ValuesEntry=<String, String>{
            //"user_id": "$userId", // userID is the document to insert this under, but I think we should include it in the record too because there will be many duplicates
            "time": dateInput.text,
            "Data"

            };*/
            final DataEntry = <String, String>{
                "calories": calControl.text,
                "fat": fatControl.text,
                "carbs": carbControl.text,
                "protein": proteinControl.text,
                "name": nameCont.text
            };

          // store the data in a subcollection. user_values indexed by user_id, each userId is tied to a subcollection "meals" which is indexed by datetime
          db.collection("nutritionData") // main collection
          .doc(userId)  // index of main collection
              .collection("meals") // subcollection of userId
              .doc(MealTime.toString()) // index of subcollection
              .set(DataEntry) // the meal data
              .onError((e, _)=>print("Error writing document: $e"));
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
