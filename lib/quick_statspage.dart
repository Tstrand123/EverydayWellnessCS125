import 'package:flutter/material.dart';
import 'main.dart';
import 'app_classes.dart';

// Creates a profile page to display information about the user.
class StatsPage extends StatefulWidget {
  const StatsPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int bmr = 0;
  int metabolicage = 0;
  int bfp = 0;

  @override
  Widget build(BuildContext context) {
    Widget displayUsername = FutureBuilder<AppUser?>(
        future: readUser(),
        builder: (BuildContext context, AsyncSnapshot<AppUser?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error Occured'),
            );
          }
          if (snapshot.hasData) {
            bmr = 1900 + snapshot.data!.weight; // use real formula for this, consider making it a global variable
            metabolicage = 19; // implement real formula
            bfp = 23; // implement real formula
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 40, bottom: 10),
                  child: Text(
                    'Vital Statistics',
                    style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child:Text(
                    'BMR: $bmr',
                    style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child:Text(
                    'Metabolic Age: $metabolicage',
                    style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child:Text(
                    'Body Fat Percentage: $bfp%',
                    style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                  ),
                ),
                
              ],
            );
          } else {
            return const Text('Nothing to Display');
          }
        });

    return Scaffold(
      // AppBar: basic bar at top of every page.
      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Flexible(child: displayUsername)]),
          ]),
        ),
      ),
    );
  }
}
