import 'package:flutter/material.dart';

class CreateNewFoodLog extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    final formTitle = 'Create New Log';
    return MaterialApp(
        title: formTitle,
        home: Scaffold(
          appBar: AppBar( // paints the bar that appears at the top of every page
            title: const Text('Home'),
            // This button is the one to get to the profile, it exists on every appbar, on every page
            actions: <Widget>[IconButton(onPressed: (){}, icon: const Icon(Icons.account_circle_rounded),)],
          ),
          body: NewFoodLog(),
        )
    );
  }

}

class NewFoodLog extends StatefulWidget{
  const NewFoodLog({super.key});


  @override
  NewFoodLogState createState(){
    return NewFoodLogState();
  }
}

class NewFoodLogState extends State<NewFoodLog>{
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context){
    Widget TimeField = TextFormField(
        decoration: const InputDecoration(
          icon: const Icon(Icons.schedule),
          hintText: 'When did you eat?',
          labelText: 'Time',
        )
    );

    Widget NameField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.fastfood),
        hintText: 'What did you eat?',
        labelText: 'Name',
      ),
    );

    Widget CaloriesField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.scale),
        hintText: 'How many total calories?',
        labelText: 'Calories',
      ),
    );

    Widget FatField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.scale),
        hintText: 'How many total grams of fat?',
        labelText: 'Fat',
      ),
    );

    Widget ProteinField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.scale),
        hintText: 'How many grams of protein?',
        labelText: 'Protein',
      ),
    );

    Widget CarbsField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.scale),
        hintText: 'How many total grams of Carbohydrates?',
        labelText: 'Carbohydrates',
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
            Row(children: [Expanded(child: NameField)]),
            Row(children: [Expanded(child: CaloriesField)]),
            Row(children: [Expanded(child: FatField)]),
            Row(children: [Expanded(child: ProteinField)]),
            Row(children: [Expanded(child: CarbsField)]),
            Row(children: [Expanded(child: Submit)])
            // TODO: add rating widget
          ],
        )
    );
  }
}