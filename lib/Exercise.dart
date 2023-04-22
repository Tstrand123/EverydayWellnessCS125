import 'package:flutter/material.dart';
import 'package:everyday_wellness_cs125/NewExerciseLog.dart';

// Widget that paints SleepHome page
class ExerciseHome extends StatelessWidget{
  // draws page for sleep home
  const ExerciseHome({Key? key, required this.title}): super(key: key);
  final String title;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      // AppBar: basic bar at top of every page
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[IconButton(onPressed: (){}, icon: const Icon(Icons.account_circle_rounded),)],
      ),

      // Body starts here
      body:  Center(
          child: Container(
              child: Column(
                children: [
                  // Recommendation box: displays the current recommendation to the user
                  Expanded(child: Row(children: [Expanded(child: DecoratedBox(decoration: BoxDecoration(
                      color:  Colors.white60,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      border: Border.all(color: Colors.black12, width: 2)
                  ),
                    child: Center(child: Text("Recomendation")),
                  ))
                  ])),

                  // NewLog widget: allows the user to manually create a new Sleep Log
                  Expanded(child: Row(children: [Expanded(child:DecoratedBox(decoration: BoxDecoration(
                      color:  Colors.white60,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      border: Border.all(color: Colors.black12, width: 2)
                  ),
                      // TODO: create link to NewLog widget
                      child: Center(child: TextButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return CreateNewExerciseLog();
                        }
                        ));
                      },
                          child: Text("New Log")),
                      )))]
                  )),


                  // Log List: displays summary information on the last 5 logs
                  Expanded(child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: <Widget>[
                      // TODO: add additional details for each ListTile to display relevant information for each log
                      ListTile(title: Center(child: Text('Log 1'))),
                      ListTile(title: Center(child: Text('Log 2'))),
                      ListTile(title: Center(child: Text('Log 3'))),
                      ListTile(title: Center(child: Text('Log 4'))),
                      ListTile(title: Center(child: Text('Log 5'))),
                      // MoreLogs button: links to widget listing all previous logs
                      // TODO: create link to MoreLogs Widget
                      ListTile(title: TextButton( onPressed: (){},
                        child: Text('More Logs...'),
                      )
                      )
                    ],
                  )
                  )
                  //Expanded(child: )
                ],
              )
          ) //Text('hi'),
      ),
    );
  }
}