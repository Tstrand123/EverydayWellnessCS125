import 'package:flutter/material.dart';

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

  // TODO: center text for Dropdown Box
  // TODO: figure out a way to align the downward arrow to the far right (think it'll look nicer anchored over there)
  @override
  Widget build(BuildContext context){
    return DropdownButton<String>(
      value: dropdownVal,
      icon: const Icon(Icons.arrow_downward,),
      elevation: 16,
      underline: Container(
        height: 2,
        color: Colors.blueAccent,
      ),
      onChanged: (String? value){
        setState(() {
          dropdownVal = value!;
        });
      },
      items: exerciseTypes.map<DropdownMenuItem<String>>((String value){
        return DropdownMenuItem<String>(value: value,child: Text(value),);
      }).toList(),
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
        )
    );

    Widget DurationField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.timer),
        hintText: '',
        labelText: 'Duration',
      ),
    );

    Widget Submit = Center(child: ElevatedButton(
      child: const Text('Submit'),
      onPressed: null,
    )
    );

    // TODO: include validation
    return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Row(children: [Expanded(child: TimeField)]),
            Row(children: [Expanded(child: DurationField)]),
            Row(children: [Expanded(child: DropdownBox())]),
            Row(children: [Expanded(child: Submit)])
          ],
        )
    );
  }
}