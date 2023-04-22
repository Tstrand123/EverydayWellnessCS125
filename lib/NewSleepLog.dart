import 'package:flutter/material.dart';

class CreateNewSleepLog extends StatelessWidget{
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
          body: NewSleepLog(),
        )
    );
  }

}

class NewSleepLog extends StatefulWidget{
  const NewSleepLog({super.key});


  @override
  NewSleepLogState createState(){
    return NewSleepLogState();
  }
}

class NewSleepLogState extends State<NewSleepLog>{
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context){
    Widget BedTimeField = TextFormField(
        decoration: const InputDecoration(
          icon: const Icon(Icons.schedule),
          hintText: 'When did you sleep?',
          labelText: 'Bed Time',
        )
    );

    // TODO: implement a date picker
    Widget DateField = TextFormField(
        decoration: const InputDecoration(
          icon: const Icon(Icons.calendar_month),
          hintText: 'What day?',
          labelText: 'Day',
        )
    );

    Widget WakeTimeField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.schedule),
        hintText: 'What did you wake up?',
        labelText: 'Wake-up Time',
      ),
    );

    // TODO: implement rating system (there is a pckage for it, can just use that?)

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
            Row(children: [Expanded(child: BedTimeField)]),
            Row(children: [Expanded(child: DateField)]),
            Row(children: [Expanded(child: WakeTimeField)]),
            Row(children: [Expanded(child: Submit)])
            // TODO: add rating widget
          ],
        )
    );
  }
}