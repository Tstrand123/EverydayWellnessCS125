import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:everyday_wellness_cs125/Sleep/new_sleep_log.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../Misc/app_functions.dart';
import '../Misc/app_classes.dart';
import 'package:health/health.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Widget that paints SleepHome page
class SleepHome extends StatefulWidget {
  // draws page for sleep home
  const SleepHome({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<SleepHome> createState() => _SleepHomeState();
}

class _SleepHomeState extends State<SleepHome> {
  int sleepRating = 0;
  String bedtimeGoalText = '';
  String durationGoalText = '';
  String EntireBedTimeGoalText = '';
  //Grabs logs
  //Referenced https://firebase.flutter.dev/docs/firestore/usage/#querying
  //Referenced https://www.youtube.com/watch?v=ErP_xomHKTw&t=276s
  Stream<List<SleepLog>> readSleepLogs() => FirebaseFirestore.instance
      .collection('SleepLogs')
      .where('userID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => SleepLog.fromJson(doc.data())).toList());

  //TODO: add rating on this page, grab exercise
  void uploadNewSleepLog() async {
    //check if log already exists - match title
    //title - userID and EndTime

    //grabs data from previous night
    //Heavily referenced https://pub.dev/packages/health
    HealthFactory health =
        HealthFactory(); //Creates health factory - necessary for grabbing data
    var types = [
      HealthDataType.SLEEP_IN_BED
    ]; //types of data collected - needs Google Fit installed on app

    bool requested = await health.requestAuthorization(
        types); //requests authorization for accessing sleep data

    var now = DateTime.now(); //Grabs current time

    //Unused but do not delete
    List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
        now.subtract(const Duration(days: 1)), now, types);

    types = [HealthDataType.SLEEP_IN_BED];
    var permissions = [HealthDataAccess.READ]; // requesting read access
    await health.requestAuthorization(types,
        permissions: permissions); //requests authorization again

    var midnight = DateTime(now.year, now.month, now.day); //get midnight info
    //This will get previous day's minutes slept
    List<HealthDataPoint> asleepMinutesList =
        await health.getHealthDataFromTypes(
            midnight.subtract(const Duration(days: 1)),
            now,
            types); //gets sleep datapoint
    //final asleepMinutes = asleepMinutesList.first.value.toString(); //this is the actual value of sleep minutes
    //HealthDataPoint sleepData = asleepMinutesList.first;

    if (asleepMinutesList.isEmpty) {
      //No Sleep Data
      //TODO: return snackbar at bottom
      return;
    } else {
      //iterate, see if most recent date to matches with this day
      //Referenced https://stackoverflow.com/questions/49514807/how-to-loop-through-a-list-of-elements
      //Referenced https://stackoverflow.com/questions/69910445/i-want-to-check-condition-for-all-for-loop-iteration-and-after-that-statement-wi
      HealthDataPoint loopData;
      bool found = false;
      int index = -1;
      
      for (int i = 0; i < asleepMinutesList.length; i++) {
        loopData = asleepMinutesList[i];
        if (loopData.dateTo.month == now.month &&
            loopData.dateTo.day == now.day) {
            found = true;
            index = i;
            break;
        }
      }

      if (found == false) {
        print('No data');
        return;
      }

      HealthDataPoint sleepData = asleepMinutesList[index];

      //referenced https://stackoverflow.com/questions/46880323/how-to-check-if-a-cloud-firestore-document-exists-when-using-realtime-updates
      //Referenced https://www.youtube.com/watch?v=ErP_xomHKTw&t=332s
      //Referenced https://stackoverflow.com/questions/57877154/flutter-dart-how-can-check-if-a-document-exists-in-firestore

      final docSleepLogs = FirebaseFirestore.instance.collection(
          'SleepLogs'); //referenced https://stackoverflow.com/questions/57877154/flutter-dart-how-can-check-if-a-document-exists-in-firestore

      String docName =
          "${FirebaseAuth.instance.currentUser!.uid}-${sleepData.dateTo}"; //check if this exists
      var docExists = await docSleepLogs.doc(docName).get();
      bool doesDocExist = docExists.exists;
      if (doesDocExist) {
        //doc exists - do not send, as it will be a duplicate
        print('exists!'); //TODO: Figure out what to do when duplicate exists
        return;
      } else {
        //doc does not exist - send to firestore
        print('Does Not Exist!');
        final newSleepLog = SleepLog(
            userID: FirebaseAuth.instance.currentUser!.uid,
            bedTime: sleepData.dateFrom,
            awakeTime: sleepData.dateTo,
            rating: sleepRating.toInt()); //TODO: Get Rating, place here
        docSleepLogs.doc(docName).set(newSleepLog.toJson());
      }

      return;
    }

    //Figure out if data is null or does not exist!
    //TODO: Get one with date that is most recent, not necessarily first!
    //Check if list is empty
  }

  //builds log for list - this is what we want to display on the tile
  Widget buildLog(SleepLog log) => ListTile(
        leading: Text('${log.rating}, ${log.awakeTime}'),
      );

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                  }
                  else{
                  DocumentReference sleepGoalsDocRef =
                      FirebaseFirestore.instance.collection('sleep_goals').doc(user.uid);

                  sleepGoalsDocRef.get().then((DocumentSnapshot snapshot) {
                    if (snapshot.exists) {
                      //String bedtime = snapshot.get('bedtime').toString() ?? 'Not Set';
                      String duration = snapshot.get('duration').toString() ?? 'Not Set';
                      DateTime bt = DateTime.parse((snapshot.get('bedtime')).toDate().toString());
                      String bedtime = "${(bt.hour)%12}:${bt.minute.toString().padLeft(2, '0')} ${bt.hour >= 12 ? 'PM' : 'AM'}";


                      setState(() {
                        bedtimeGoalText = bedtime;
                        durationGoalText = duration;
                        EntireBedTimeGoalText = "Bedtime at $bedtimeGoalText and sleep for $durationGoalText hours.";
                      });
                    } else {
                      setState(() {
                        bedtimeGoalText = 'Not Set';
                        durationGoalText = 'Not Set';
                        EntireBedTimeGoalText = "Goals not yet set.";
                      });
                    }
                  }).catchError((error) {
                    Text('Error: $error');
                  });}
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.account_circle_rounded),
          )
        ],
      ),

      // Body starts here
      body: Center(
          child: Column(
          children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5.0), // Adjust the vertical padding as needed
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 150,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white60,
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        border: Border.all(color: Colors.black12, width: 2),
                      ),
                      child: Center(
                        child: Text(EntireBedTimeGoalText),//"Bedtime at $bedtimeGoalText and sleep for $durationGoalText hours."),

                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Center(
            child: RatingBar(
              initialRating: 0,
              minRating: 0,
              maxRating: 0,
              allowHalfRating: false,
              itemSize: 30.0,
              ratingWidget: RatingWidget(
                full: const Icon(Icons.star, color: Colors.amber),
                half: const Icon(Icons.star_half, color: Colors.amber),
                empty: const Icon(
                  Icons.star,
                  color: Colors.grey,
                ),
              ),
              onRatingUpdate: (rating) {
                print(rating);
                setState(() {
                  sleepRating = rating.toInt();
                });
              },
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5.0), // Adjust the vertical padding as needed
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white60,
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        border: Border.all(color: Colors.black12, width: 2),
                      ),
                      child: Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UpdateSleepGoalsState()),//UpdateSleepGoals()),
                            );
                          },
                          child: const Text("New Sleep Goal"),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // NewLog widget: allows the user to manually create a new Sleep Log

          Container(
            padding: const EdgeInsets.symmetric(vertical: 5.0), // Adjust the vertical padding as needed
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white60,
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        border: Border.all(color: Colors.black12, width: 2),
                      ),
                      child: Center(
                      child: TextButton(
                          onPressed: uploadNewSleepLog,
                          child: const Text("New Log (Auto)")),
                    )
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 5.0), // Adjust the vertical padding as needed
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white60,
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        border: Border.all(color: Colors.black12, width: 2),
                      ),
                      child: Center(
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const CreateNewSleepLog();
                            }));
                          },
                          child: const Text("New Log (Manual)")),
                    )
                    ),
                  ),
                ),
              ],
            ),
          ),

          ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                ),
                
                onPressed: () {
                },

                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Bedtime Goal: $bedtimeGoalText',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Duration Goal: $durationGoalText hrs',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
          ),
          //Grab logs from DB
            StreamBuilder<List<SleepLog>>(
              stream: readLogs(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final logs = snapshot.data!;
                  //print('here');

                  return ListView(
                    shrinkWrap: true,
                    children: logs.map(buildLogMap).toList(),
                  );
                }else {
                  return const Center(child: CircularProgressIndicator(),);
                }
              },
            ),
            ElevatedButton(onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const MoreLogs(),
              ));
            },
                child: const Text('More Logs')),
        ],
      )
          ),
    );
  }

  Widget buildLogMap(SleepLog log) {
    Duration diff = DateTime.fromMillisecondsSinceEpoch(log.awakeTime.millisecondsSinceEpoch).difference(DateTime.fromMillisecondsSinceEpoch(log.bedTime.millisecondsSinceEpoch));
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    final awakeYear = log.awakeTime.year;
    final awakeMonth = log.awakeTime.month;
    final awakeDay = log.awakeTime.day;
    //('here');
    return ListTile(
        leading: Text('${awakeMonth}-${awakeDay}-${awakeYear} - ${hours} hours and ${minutes} minutes'),
    );

  }

  Stream<List<SleepLog>> readLogs() {
    final temp = FirebaseFirestore.instance
        .collection('SleepLogs')
        .where('userID', isEqualTo: FirebaseAuth.instance.currentUser!.uid.toString())
        .limit(5)
        .snapshots();

    //print(temp.first.toString());
    return FirebaseFirestore.instance
        .collection('SleepLogs')
        .where('userID', isEqualTo: FirebaseAuth.instance.currentUser!.uid.toString())
        .limit(5)
        .snapshots().map((snapshot) => snapshot.docs.map((doc) => SleepLog.fromJson(doc.data())).toList());
  }
}

class MoreLogs extends StatefulWidget {
  const MoreLogs({Key? key}) : super(key: key);

  @override
  State<MoreLogs> createState() => _MoreLogsState();
}

class _MoreLogsState extends State<MoreLogs> {
  TextEditingController dateInput = TextEditingController();
  TextEditingController dateInput2 = TextEditingController();
  TextEditingController sleepTimeInput = TextEditingController();
  TextEditingController wakeTimeInput = TextEditingController();

  int sleepRatingValue = 0;


  @override
  void dispose() {
    dateInput.dispose();
    dateInput2.dispose();
    sleepTimeInput.dispose();
    wakeTimeInput.dispose();
    super.dispose();
  }

  Stream<List<SleepLog>> readSleepLogs() => FirebaseFirestore.instance
      .collection('SleepLogs')
      .where('userID', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => SleepLog.fromJson(doc.data())).toList());

  Widget buildLog(SleepLog log) {
    Duration diff = DateTime.fromMillisecondsSinceEpoch(log.awakeTime.millisecondsSinceEpoch).difference(DateTime.fromMillisecondsSinceEpoch(log.bedTime.millisecondsSinceEpoch));
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    final awakeYear = log.awakeTime.year;
    final awakeMonth = log.awakeTime.month;
    final awakeDay = log.awakeTime.day;
    //('here');
    return ListTile(
      leading: Text('${awakeMonth}-${awakeDay}-${awakeYear} - ${hours} hours and ${minutes} minutes'),
      onTap: () => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Update Profile'),
          content: Column(
            children: [
              const Text('Change Date and Time'),
              TextField(
                controller: dateInput,
                decoration: const InputDecoration(
                  icon: Icon(Icons.calendar_month),
                  labelText: "Enter Date",
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    String formattedDate = DateFormat('M/d/y').format(pickedDate);
                    setState(() {
                      dateInput.text = formattedDate;
                    });
                  }
                },
              ),
              TextField(
                controller: sleepTimeInput,
                decoration: const InputDecoration(
                  icon: Icon(Icons.schedule),
                  hintText: '',
                  labelText: 'Bed Time',
                ),
                readOnly: true,
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    String formattedTime =
                        '${pickedTime.hour.toString()}:${pickedTime.minute.toString().padLeft(2, '0')}';
                    setState(() {
                      sleepTimeInput.text = formattedTime;
                    });
                  }
                },
              ),
              TextField(
                controller: dateInput2,
                decoration: const InputDecoration(
                  icon: Icon(Icons.calendar_month),
                  labelText: "Enter Date",
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    String formattedDate = DateFormat('M/d/y').format(pickedDate);
                    setState(() {
                      dateInput2.text = formattedDate;
                    });
                  }
                },
              ),
              TextField(
                controller: wakeTimeInput,
                decoration: const InputDecoration(
                  icon: Icon(Icons.schedule),
                  hintText: '',
                  labelText: 'Wake up time',
                ),
                readOnly: true,
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    String formattedTime =
                        '${pickedTime.hour.toString()}:${pickedTime.minute.toString().padLeft(2, '0')}';
                    setState(() {
                      wakeTimeInput.text = formattedTime;
                    });
                  }
                },
              ),
              const SizedBox(height: 15,),
              RatingBar(
                initialRating: 0,
                minRating: 0,
                maxRating: 5,
                allowHalfRating: true,
                itemSize: 30.0,
                ratingWidget: RatingWidget(
                  full: const Icon(Icons.star, color: Colors.amber),
                  half: const Icon(Icons.star, color: Colors.amber),
                  empty: const Icon(
                    Icons.star,
                    color: Colors.grey,
                  ),
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    sleepRatingValue = rating.toInt();
                  });
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(onPressed: () => updateSleepLog(log.awakeTime.toString()), //immediately quits
              child: const Text('Update'),),
          ],
        ),
      ),
    );
  }

  void updateSleepLog(String awakeTime) async {
    print('called');
    print(dateInput.text);
    print(DateTime.parse(awakeTime));

    final oldNameID = '${FirebaseAuth.instance.currentUser!.uid}-${DateTime.parse(awakeTime)}';
    print(oldNameID);

    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user!.uid;

    final CollectionReference logsCollection =
    FirebaseFirestore.instance.collection('SleepLogs');

    final temp = await logsCollection.get();
    print(temp.docs);

    final String dI = dateInput.text;
    final String bTI = sleepTimeInput.text;
    final String dI2 = dateInput2.text;
    final String wTI = wakeTimeInput.text;

    final Map<String, dynamic> logData = {
      'awakeTime': Timestamp.fromDate(DateFormat('M/d/y HH:mm').parse('$dI2 $wTI')),
      'bedTime': Timestamp.fromDate(DateFormat('M/d/y HH:mm').parse('$dI $bTI')),
      'rating': sleepRatingValue,
      'userID': userId,
    };

    await logsCollection.doc(oldNameID).update(logData);



    sleepTimeInput.clear();
    dateInput2.clear();
    wakeTimeInput.clear();
    dateInput.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More Logs'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              child: StreamBuilder<List<SleepLog>>(
                stream: readSleepLogs(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return Text('Error ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    var allSleepLogs = snapshot.data!;

                    return ListView(
                      shrinkWrap:
                          true, //Referenced https://stackoverflow.com/questions/50252569/vertical-viewport-was-given-unbounded-height
                      children: allSleepLogs.map(buildLog).toList(),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

int getSleepScore(){
  // compare time slept yesterday night to the goal
  var db = FirebaseFirestore.instance;
  var userId = FirebaseAuth.instance.currentUser!.uid;
  int duration = 8; // default, gets changed if needed below
  db.collection('sleep_goals').doc(userId).get().then(
          (event){
        var temp = event.data() as Map<String, dynamic>;
        duration = int.tryParse(temp['duration'])!;
      }
  );
  int sleepDuration = 0;
  DateTime yesterday = DateTime.now().subtract(const Duration(days: 1)); // get yesterday
  // might need to restructure how sleep logs are saved to make the query easier to do
  db.collection('SleepLogs').orderBy('bedTime', descending: true).get().then((event){//.where('userID', isEqualTo: userId).get().then((event){//where('bedTime' , isLessThanOrEqualTo: Timestamp.fromDate(DateTime.now())).get().then((event){
    for (var e in event.docs) {
      if (e['userID'] == userId){
        sleepDuration =
            (DateTime.parse(e['awakeTime'].toDate().toString()).difference( DateTime.parse(e['bedTime'].toDate().toString()))).inHours;
        break; // only get the one, hacky but whatever
      }
    }
  });
  // normalize the difference to 50 and return that
  int TimeDifference = duration - sleepDuration;
  // if TimeDifference is (+) then they slept longer then their goal
  // if TimeDifference is (-) then they needed to sleep longer
  if (TimeDifference < 0){

    if ((TimeDifference *-1) <= 1){ // if the difference is less then or = to one hour, give most points
      return 40;
    }
    else if((TimeDifference * -1) <= 2){
      return 30; // scale down the points as they get farther from their goal
    }
    else if ((TimeDifference * -1) <= 4){
      return 20;
    }
    else if (duration >= 2){
      return 10; // so long as they slept 2 hours, give them 10 points
    }
    else{ // anything less then that gets 0
      return 0;
    }
  }
  else
  {return 50;} // return the full score
}

Widget getSleepRec() {
  // TODO: fill in
  var db = FirebaseFirestore.instance;
  var userId = FirebaseAuth.instance.currentUser!.uid;
  //String bedTime = ''; // TODO: parse bedtime

  Future<DocumentSnapshot<Map<String, dynamic>>> snapshot =  db.collection('sleep_goals').doc(userId).get();//.then(
  // (event){
  /*var temp = event.data() as Map<String, dynamic>;

        DateTime bedtime = DateTime.parse(temp['bedtime'].toDate().toString()); // get the bedtime
            if (DateTime.now().isAfter(bedtime.subtract(const Duration(minutes:31)))){
              return "Bedtime in 30 minutes! Put away all electronic devices.";
            }
            else if (DateTime.now().isAfter(bedtime.subtract(const Duration(hours: 2)))){
              return "Bedtime in 2 hours, make sure to get your daily exercise in!"; // TODO: is there a way to check if exercise has been done without querying the db?
            }
            else{
              Duration timeTil = DateTime.now().difference(bedtime);
              return "Time until bedtime: ${timeTil.inHours.toString()} : ${(timeTil.inMinutes%60).toString()}"; // won't update continuously, but its something
            }*/
  //}
  //);
  return  FutureBuilder(future: snapshot,
    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> result){
      String str = 'Make a log to receive recommendations';
      if (result.hasData){
        //var temp = result.data != null ? (result.data as Map<String, dynamic>) : null;
        //QuerySnapshot<Map<String, dynamic>> temp = result.data!;
        DocumentSnapshot<Map<String, dynamic>> doc = result.data!;
        //if (temp != null) {
        //for (var d in result.data){
          DateTime bedtime = DateTime.parse(
              doc['bedtime'].toDate().toString()); // get the bedtime
        DateTime today = DateTime.now();
        DateTime todayBedTime = DateTime(today.year, today.month, today.day, bedtime.hour, bedtime.minute);
          if (DateTime.now().isAfter(
              todayBedTime.subtract(const Duration(minutes: 31)))) {
            str = "Bedtime in 30 minutes! Put away all electronic devices.";
          }
          else if (DateTime.now().isAfter(
              todayBedTime.subtract(const Duration(hours: 2)))) {
            str =
            "Bedtime in 2 hours, make sure to get your daily exercise in!"; // TODO: is there a way to check if exercise has been done without querying the db?
          }
          else {
            Duration timeTil = todayBedTime.difference(DateTime.now());//DateTime.now().difference(todayBedTime);
            str = "Time until bedtime: ${timeTil.inHours.toString()} : ${(timeTil
                .inMinutes % 60)
                .toString()}"; // won't update continuously, but its something
          }
        }
      return Text(str, textAlign: TextAlign.center,);
    },);
  //if (DateTime.now() >= bedTime - duration(minutes:30)) {}// compare current time to the scheduled bed time, if within 30 minutes, tell them to put away devices

  // If they haven't gotten in some exercise by 2 hours before bedtime, advise them to do so?

  // anything else?

  //return "Keep it up!"; // default response if there is nothing else to recommend
}

class UpdateSleepGoalsState extends StatefulWidget{
  const UpdateSleepGoalsState({super.key});

  @override
  UpdateSleepGoals createState(){
    return UpdateSleepGoals();
  }
}

class UpdateSleepGoals extends State<UpdateSleepGoalsState> {
  final TextEditingController _bedtimeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  var bedTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    Widget BedtimeInput = Container(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: TextField(
            controller: _bedtimeController,
            decoration: const InputDecoration(
              icon: Icon(Icons.schedule),
              hintText: '',
              labelText: 'BedTime',
            ),
            readOnly: true,
            onTap: () async {
              TimeOfDay? pickedTime = await showTimePicker(
                  context: context, initialTime: TimeOfDay.now());
              if (pickedTime != null) {
                String formattedTime =
                    '${pickedTime.hour.toString()} : ${pickedTime.minute.toString()}';
                setState(() {
                  _bedtimeController.text = formattedTime;
                  // only care about the hour and minute, everything else can be discarded, seconds aren't meaningful so ignore
                  bedTime = DateTime(0, 0, 0, pickedTime.hour, pickedTime.minute);

                });
              } else {}
            },
          ),
        ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Goals'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /*TextFormField(
              controller: _bedtimeController,
              decoration: const InputDecoration(
                labelText: 'Enter your desired bedtime',
              ),
            ),*/
            BedtimeInput, // time picker
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Enter your desired sleep duration (in hours)',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
               // String bedtimeText = _bedtimeController.text;
                String bedtimeText = bedTime.toString();
                String durationText = _durationController.text;

                User? user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  return;
                }
                String uid = user.uid.toString();

                DocumentReference sleepGoalsCollection = FirebaseFirestore.instance.collection('sleep_goals').doc(uid);
                Map<String, dynamic> sleepData = {
                  'bedtime': bedtimeText,
                  'duration': durationText,
                };
                
                sleepGoalsCollection.set(sleepData).then((value) {
                  const Text('Data saved successfully');
                  Navigator.pop(context);
                }).catchError((error) {
                  Text('Error: $error');
                });
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}