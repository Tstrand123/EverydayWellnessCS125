import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import 'app_classes.dart';

// Creates a profile page to display information about the user.
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  final feetController = TextEditingController();
  final inchesController = TextEditingController();

  final weightController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();

    feetController.dispose();
    inchesController.dispose();

    weightController.dispose();

    super.dispose();
  }


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
            return Center(
              child: Text('${snapshot.error.toString()}'),
            );
          }
          if (snapshot.hasData) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 10),
                  child: Text(
                    'Name: ${snapshot.data!.firstName} ${snapshot.data!.lastName}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    //Referenced https://api.flutter.dev/flutter/material/AlertDialog-class.html
                    //Referenced https://stackoverflow.com/questions/68453845/the-return-type-widget-isnt-a-widget-as-required-by-the-closures-context
                    //Referenced https://api.flutter.dev/flutter/widgets/Column-class.html
                    //Referenced https://www.youtube.com/watch?v=ErP_xomHKTw


                    onPressed: () => showDialog(context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) =>
                          AlertDialog(
                            title: const Text('Update Name'),
                            content: Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  const Text('Enter New First Name'),
                                  TextFormField(
                                    controller: firstNameController,
                                    decoration: const InputDecoration(labelText: 'First Name'),
                                    validator: (value) => value != null && value.isEmpty
                                        ? 'Enter a valid name'
                                        : null,
                                  ),
                                  const SizedBox(height: 15,),
                                  const Text('Enter New Last Name'),
                                  TextFormField(
                                    controller: lastNameController,
                                    decoration: const InputDecoration(labelText: 'Last Name'),
                                    validator: (value) => value != null && value.isEmpty
                                        ? 'Enter a valid name'
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel')),
                              TextButton(onPressed: () => updateName(), //immediately quits
                              child: const Text('Update'),),

                            ],
                          )
                        ),
                    child: const Text('Update'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Text(
                    'DOB: ${snapshot.data!.birthDate}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Text(
                    'Biological Sex: ${snapshot.data!.biologicalSex}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17.0),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(bottom: 10),
                //   child: ElevatedButton(
                //     onPressed: () {
                //       Navigator.push(context,
                //           MaterialPageRoute(builder: (context) {
                //         return const Text('test');
                //       }));
                //     },
                //     child: const Text('Update'),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Text(
                    'Height: ${snapshot.data!.heightFeet}\'${snapshot.data!.heightInches}"',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: () => showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Update Height'),
                        content: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              const Text('Enter New Height in Feet'),
                              TextFormField(
                                controller: feetController,
                                decoration: const InputDecoration(labelText: 'Feet'),
                                validator: (value) => value != null && value.isEmpty
                                    ? 'Enter a valid Height'
                                    : null,
                              ),
                              const SizedBox(height: 15,),
                              const Text('Enter New Height in Inches'),
                              TextFormField(
                                controller: inchesController,
                                decoration: const InputDecoration(labelText: 'Inches'),
                                validator: (value) => value != null && value.isEmpty
                                    ? 'Enter a valid Height'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(onPressed: () => Navigator.pop(context), //no changes made
                              child: const Text('Cancel')),
                          TextButton(onPressed: () => updateHeight(), //immediately quits
                            child: const Text('Update'),),
                        ],
                      ),
                    ),
                    child: const Text('Update'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Text(
                    'Weight: ${snapshot.data!.weight} lbs',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 70),
                  child: ElevatedButton(
                    onPressed: () => showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Update Weight'),
                        content: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              const Text('Enter a New Weight in Pounds'),
                              TextFormField(
                                controller: weightController,
                                decoration: const InputDecoration(labelText: 'Weight'),
                                validator: (value) => value != null && value.isEmpty
                                    ? 'Enter a valid weight'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel')),
                          TextButton(onPressed: () => updateWeight(), //immediately quits
                            child: const Text('Update'),),
                        ],
                      ),
                    ),
                    child: const Text('Update'),
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
            ElevatedButton(
                onPressed: () => {
                      FirebaseAuth.instance.signOut().then((value) => {
                            //Referenced https://stackoverflow.com/questions/62036432/signout-does-not-work-after-i-navigate-to-a-screen-but-it-works-when-i-do-not
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MyAppLogin()))
                          })
                    },
                child: const Text('Sign out')),
          ]),
        ),
      ),
    );
  }

  void updateName() { //Make this update all fields on home page
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;
    
    final docUser = FirebaseFirestore.instance.collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    setState(() {
      docUser.update({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
      });
    });

    Navigator.pop(context);
  }

  void updateHeight() {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    final docUser = FirebaseFirestore.instance.collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    setState(() {
      docUser.update({
        'heightFeet': int.parse(feetController.text.trim()),
        'heightInches': int.parse(inchesController.text.trim()),
      });
    });

    Navigator.pop(context);
  }

  void updateWeight() {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    final docUser = FirebaseFirestore.instance.collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    setState(() {
      docUser.update({
        'weight': int.parse(weightController.text.trim()),
      });
    });


    Navigator.pop(context);
  }
}