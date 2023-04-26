import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'Sleep.dart';

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
        ),
      validator: (value){
        if (value == null || value.isEmpty){
          return 'Please enter text';
        }
        return null;
      },
    );

    // TODO: implement a date picker
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
    );

    Widget sleepRating = Container(padding: const EdgeInsets.symmetric(vertical: 30),
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
            return const SleepHome(title: 'SleepHome');
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
            Row(children: [Expanded(child: BedTimeField)]),
            Row(children: [Expanded(child: DateField)]),
            Row(children: [Expanded(child: WakeTimeField)]),
            Row(children: [Expanded(child: sleepRating)],),
            Row(children: [Expanded(child: Submit)])

          ],
        )
    );
  }
}