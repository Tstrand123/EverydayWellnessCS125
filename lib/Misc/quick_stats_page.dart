import 'package:flutter/material.dart';
import '../main.dart';
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
  int origbmr = 0;
  double bfp = 0.0;
  double bmi = 0.0;
  double origbmi = 0.0;

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
            if (snapshot.data!.biologicalSex == 'M'){
                bmr = (66.47 + (6.24 * snapshot.data!.weight) + (12.7 * (snapshot.data!.heightFeet * 12 + snapshot.data!.heightInches)) - (6.75 * (DateTime.now().year - int.parse(snapshot.data!.birthDate.substring(0, 4))))).toInt();
                origbmr = (66.47 + (6.24 * snapshot.data!.initWeight) + (12.7 * (snapshot.data!.initTotalInches)) - (6.75 * (DateTime.now().year - int.parse(snapshot.data!.birthDate.substring(0, 4))))).toInt();
            }
            if (snapshot.data!.biologicalSex == 'F'){
                bmr = (65.51 + (4.35 * snapshot.data!.weight) + (4.7 * (snapshot.data!.heightFeet * 12 + snapshot.data!.heightInches)) - (4.7 * (DateTime.now().year - int.parse(snapshot.data!.birthDate.substring(0, 4))))).toInt();
                origbmr = (65.51 + (4.35 * snapshot.data!.weight) + (4.7 * (snapshot.data!.initTotalInches)) - (4.7 * (DateTime.now().year - int.parse(snapshot.data!.birthDate.substring(0, 4))))).toInt();
            }
            bmi = double.parse((703 * snapshot.data!.weight / ((snapshot.data!.heightFeet * 12 + snapshot.data!.heightInches) * (snapshot.data!.heightFeet * 12 + snapshot.data!.heightInches))).toStringAsFixed(1));
            origbmi = double.parse((703 * snapshot.data!.weight / ((snapshot.data!.initTotalInches) * (snapshot.data!.initTotalInches))).toStringAsFixed(1));
            bfp = double.parse((1.2 * bmi + 0.23 * (DateTime.now().year - int.parse(snapshot.data!.birthDate.substring(0, 4))) - 5.4).toStringAsFixed(1));
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
                  child: Text(
                    'BMR: $bmr kcal',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 5),
                  child: Text(
                    'BMI: $bmi',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 10),
                  child: Text(
                    'Original: $origbmi',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Text(
                    'Body Fat Percentage: $bfp%',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17.0),
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
