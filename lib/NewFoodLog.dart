import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'Food.dart';

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
        ),
      validator: (value){
        if (value == null || value.isEmpty){
          return 'Please enter text';
        }
        return null;
      },
      // TODO: change to a time picker?
    );

    Widget NameField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.fastfood),
        hintText: 'What did you eat?',
        labelText: 'Name',
      ),
      validator: (value){
        if (value == null || value.isEmpty){
          return 'Please enter text';
        }
        return null;
      },
      // TODO: change to a time picker?
    );

    Widget CaloriesField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.scale),
        hintText: 'How many total calories?',
        labelText: 'Calories',
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

    Widget FatField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.scale),
        hintText: 'How many total grams of fat?',
        labelText: 'Fat',
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

    Widget ProteinField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.scale),
        hintText: 'How many grams of protein?',
        labelText: 'Protein',
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

    Widget CarbsField = TextFormField(
      decoration: const InputDecoration(
        icon: const Icon(Icons.scale),
        hintText: 'How many total grams of Carbohydrates?',
        labelText: 'Carbohydrates',
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

    Widget foodRating = Container(padding: const EdgeInsets.symmetric(vertical: 30),
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
            return const FoodHome(title: 'FoodHome');
          }));
        }
      },
    )
    );

    // TODO: include validation
    return Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(8),
          children: <Widget>[
            Row(children: [Expanded(child: TimeField)]),
            Row(children: [Expanded(child: NameField)]),
            Row(children: [Expanded(child: CaloriesField)]),
            Row(children: [Expanded(child: FatField)]),
            Row(children: [Expanded(child: ProteinField)]),
            Row(children: [Expanded(child: CarbsField)]),
            Row(children: [Expanded(child: foodRating)],),
            Row(children: [Expanded(child: Submit)])
            // TODO: add rating widget
          ],
        )
    );
  }
}