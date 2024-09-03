import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // Import the generated file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Initialize with options
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Club Registration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ClubRegistrationPage(),
    );
  }
}

class ClubRegistrationPage extends StatefulWidget {
  @override
  _ClubRegistrationPageState createState() => _ClubRegistrationPageState();
}

class _ClubRegistrationPageState extends State<ClubRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _discordUsernameController = TextEditingController();

  final List<String> clubs = [
    "Coding Clubs",
    "Corporate Connect Clubs",
    "Digital Marketing Clubs"
  ];

  List<String> selectedClubs = [];

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create a reference to the Firestore collection
        CollectionReference users = FirebaseFirestore.instance.collection('users');

        // Add the form data to the Firestore collection
        await users.add({
          'name': _nameController.text,
          'discordUsername': _discordUsernameController.text,
          'selectedClubs': selectedClubs,
        });

        // Log success message to console
        print('Data added successfully: '
            'Name: ${_nameController.text}, '
            'Discord Username: ${_discordUsernameController.text}, '
            'Selected Clubs: ${selectedClubs.join(', ')}');

        // Show a success message
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Registration Successful'),
              content: Text(
                'Name: ${_nameController.text}\n'
                    'Discord Username: ${_discordUsernameController.text}\n'
                    'Selected Clubs: ${selectedClubs.join(', ')}',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        // Log error message to console
        print('Error occurred: ${e.toString()}');

        // Show an error message if something goes wrong
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Registration Failed'),
              content: Text('An error occurred: ${e.toString()}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Club Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Real Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your real name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _discordUsernameController,
                  decoration: InputDecoration(labelText: 'Discord Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Discord username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Text(
                  'Select the clubs you are interested in:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ...clubs.map((club) {
                  return CheckboxListTile(
                    title: Text(club),
                    value: selectedClubs.contains(club),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedClubs.add(club);
                        } else {
                          selectedClubs.remove(club);
                        }
                      });
                    },
                  );
                }).toList(),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
