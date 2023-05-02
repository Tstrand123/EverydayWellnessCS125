import 'package:flutter/material.dart';
import 'package:health/health.dart';

//referenced https://pub.dev/packages/health
// and https://pub.dev/packages/permission_handler

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {

  Future<int> getSteps()  async{
    //Heavily referenced https://pub.dev/packages/health
    HealthFactory healthData = HealthFactory();

    var now = DateTime.now();
    var midnight = DateTime(now.year,now.month,now.day);
    int? steps = await healthData.getTotalStepsInInterval(midnight, now);
    steps ??= -1;

    return steps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test'),),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder(
                future: getSteps(),
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Found an Error');
                  }else if (snapshot.hasData) {
                    final tempVal = snapshot.data.toString(); //https://flutterforyou.com/how-to-call-a-variable-inside-string-in-flutter/
                    return Text(tempVal);
                  }else{
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
