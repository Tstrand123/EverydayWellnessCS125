import 'package:flutter/material.dart';

// TODO: link to rest of UI (I'm not sure where exactly we want it yet)
class UserInfo extends StatelessWidget {
  const UserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    const formTitle = 'Edit User Information';
    return MaterialApp(
        title: formTitle,
        home: Scaffold(
          appBar: AppBar(
            // paints the bar that appears at the top of every page
            title: const Text('Edit User Information'),
            // This button is the one to get to the profile, it exists on every appbar, on every page
            actions: <Widget>[
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.account_circle_rounded),
              )
            ],
          ),
          body: const UserInfoForm(),
        ));
  }
}

class UserInfoForm extends StatefulWidget {
  const UserInfoForm({super.key});

  @override
  UserInfoFormState createState() {
    return UserInfoFormState();
  }
}

// Dropdown box for Sex
const List<String> sexOptions = <String>[
  'Sex',
  'Male',
  'Female',
  'Prefer to not state'
];

class DropdownBox extends StatefulWidget {
  const DropdownBox({super.key});

  @override
  State<DropdownBox> createState() => _DropdownBoxState();
}

class _DropdownBoxState extends State<DropdownBox> {
  String dropdownVal = sexOptions.first; // default entry of text box

  @override
  Widget build(BuildContext context) {
    //return DropdownButton<String>(
    return Container(
        padding: const EdgeInsets.all(8),
        child: DropdownButtonFormField(
          value: dropdownVal,
          icon: const Icon(
            Icons.arrow_downward,
          ),
          elevation: 16,
          onChanged: (String? value) {
            setState(() {
              dropdownVal = value!;
            });
          },
          validator: (value) {
            if (sexOptions.indexOf(dropdownVal) == 0) {
              return 'Field required';
            } else {
              return null;
            }
          },
          items: sexOptions.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          isExpanded: true,
          alignment: Alignment.center,
        ));
  }
}

// Dropdown box for diet
const List<String> diets = <String>[
  'Select Diet (optional)',
  'Vegan',
  'Vegetarian',
  'Pescatarian',
  'Keto',
  'Paleo',
  'Low Carb',
  'Low Fat'
];

class DietBox extends StatefulWidget {
  const DietBox({super.key});

  @override
  State<DietBox> createState() => _DietBoxState();
}

class _DietBoxState extends State<DietBox> {
  String dropdownVal = diets.first; // default entry of text box

  // note: diet is not a required field, so it doesn't have a validator method
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownVal,
      icon: const Icon(
        Icons.arrow_downward,
      ),
      elevation: 16,
      underline: Container(
        height: 2,
        color: Colors.blueAccent,
      ),
      onChanged: (String? value) {
        setState(() {
          dropdownVal = value!;
        });
      },
      items: diets.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      isExpanded: true,
      alignment: Alignment.center,
    );
  }
}

// main body of the form
class UserInfoFormState extends State<UserInfoForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement a date picker
    Widget birthDayField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.calendar_month),
        hintText: 'When were you born?',
        labelText: 'Date of Birth',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter text';
        }
        return null;
      },
    );

    Widget weightField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.scale),
        hintText: 'How much do you weigh?',
        labelText: 'Weight',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a number';
        }
        var number = int.tryParse(value);
        if (number == null) {
          return 'Please enter a number';
        }
        return null;
      },
    );

    Widget heightField = TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.scale),
        hintText: 'How tall are you?',
        labelText: 'Height',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a number';
        }
        var number = int.tryParse(value);
        if (number == null) {
          return 'Please enter a number';
        }
        return null;
      },
    );

    Widget submit = Center(
        child: ElevatedButton(
      child: const Text('Submit'),
      onPressed: () {
        // TODO: fill in
      },
    ));

    return Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            Row(children: [Expanded(child: birthDayField)]),
            Row(children: [Expanded(child: weightField)]),
            Row(children: [Expanded(child: heightField)]),
            Row(
              children: const [Expanded(child: DropdownBox())],
            ),
            Row(
              children: const [Expanded(child: DietBox())],
            ),
            Row(children: [Expanded(child: submit)])
          ],
        ));
  }
}
