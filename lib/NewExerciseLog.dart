import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'Exercise.dart';

class CreateNewExerciseLog extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    final formTitle = 'Create New Log';
    return MaterialApp(
        title: formTitle,
        home: Scaffold(
          appBar: AppBar( // paints the bar that appears at the top of every page
            title: const Text('Create New Log'),
            // This button is the one to get to the profile, it exists on every appbar, on every page
            actions: <Widget>[IconButton(onPressed: (){}, icon: const Icon(Icons.account_circle_rounded),)],
          ),
          body: NewExerciseLog(),
        )
    );
  }

}

class NewExerciseLog extends StatefulWidget{
  const NewExerciseLog({super.key});


  @override
  NewExerciseLogState createState(){
    return NewExerciseLogState();
  }
}

// Dropdown box
const List<String> exerciseTypes = <String>['Select Type','Cardio', 'Walk', 'Weightlifting', 'Interval training', 'Biking'];

class DropdownBox extends StatefulWidget{
  const DropdownBox({super.key});

  @override
  State<DropdownBox> createState() => _DropdownBoxState();
}

class _DropdownBoxState extends State<DropdownBox>{
  String dropdownVal = exerciseTypes.first; // default entry of text box


  @override
  Widget build(BuildContext context){
    //return DropdownButton<String>( // changed to dropdownbuttonformfield because dropdownbutton doesn't have a validator method
    return Container(
      padding: EdgeInsets.all(8),
      child: DropdownButtonFormField(
      value: dropdownVal,
      icon: const Icon(Icons.arrow_downward,),
      elevation: 16,
      onChanged: (String? value){
        setState(() {
          dropdownVal = value!;
        });
      },
        validator: (value){
          if ( exerciseTypes.indexOf(dropdownVal) == 0) {
            return 'field required';
          }
          else {
            return null;
          }
        },
      items: exerciseTypes.map<DropdownMenuItem<String>>((String value){
        return DropdownMenuItem<String>(value: value,child: Text(value),);
      }).toList(),
    )
    );
  }
}
// end of dropdown box segment

// paint the rest of the log
class NewExerciseLogState extends State<NewExerciseLog>{
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context){
    Widget TimeField = TextFormField(
        decoration: const InputDecoration(
          icon: const Icon(Icons.schedule),
          hintText: '',
          labelText: 'Time',
        ),
      validator: (value){
        if (value == null || value.isEmpty){
          return 'Please enter text';
        }
        return null;
      },
    );

    Widget DurationField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.timer),
        hintText: '',
        labelText: 'Duration (in minutes)',
      ),
      validator: (value){
        if (value == null || value.isEmpty){
          return 'Please enter a number';
        }
        var number = int.tryParse(value);
        if (number == null){
          return 'Please enter a number';
        }
        return null;
      },
    );

    Widget exerciseRating = Container(padding: const EdgeInsets.symmetric(vertical: 30),
      child: Center(child: RatingBar(
        initialRating: 0,
        minRating: 0,
        maxRating: 5,
        allowHalfRating: true,
        itemSize: 30.0,
        ratingWidget: RatingWidget(
            full: const Icon(Icons.star, color: Colors.amber),
            half: const Icon(Icons.star, color:Colors.amber),
            empty: const Icon(Icons.star, color: Colors.grey,)
        ),
        onRatingUpdate: (rating){
          // TODO? capture change somehow or else wait for submit to do that for us?
        },
      )
      ),
    );

    Widget Submit = Center(child: ElevatedButton(
      child: const Text('Submit'),
      onPressed: (){
        if (_formKey.currentState!.validate()){
          ScaffoldMessenger.of(context).showSnackBar(
            // TODO: send the data to the server
            const SnackBar(content: Text('Processing Data')),
          );
          // When done, reload the food home page
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return const ExerciseHome(title: 'ExerciseHome');
          }));
        }
      },
    )
    );

    return Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(8),
          children: <Widget>[
            Row(children: [Expanded(child: TimeField)]),
            Row(children: [Expanded(child: DurationField)]),
            Row(children: [Expanded(child: DropdownBox())]),
            Row(children: [Expanded(child: exerciseRating)],),
            Row(children: [Expanded(child: Submit)])
          ],
        )
    );
  }
}