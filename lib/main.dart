import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // Import the generated file
import 'package:url_launcher/url_launcher.dart'; // Add this import for URL launching

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

  List<String> selectedClubs = [];
  String? selectedBatch;
  List<String> yearOfStudy = ["1st Year", "2nd Year"];
  String? selectedYear;

  final List<String> clubs = [
    "Coding Clubs",
    "Corporate Connect Clubs",
    "Digital Marketing Clubs"
  ];

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Check if year of study and batch are selected
      if (selectedYear == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select your year of study.')),
        );
        return;
      }
      if (selectedBatch == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select your batch.')),
        );
        return;
      }

      try {
        CollectionReference users = FirebaseFirestore.instance.collection('users');

        await users.add({
          'name': _nameController.text,
          'discordUsername': _discordUsernameController.text,
          'selectedClubs': selectedClubs,
          'yearOfStudy': selectedYear,
          'batch': selectedBatch,
        });

        print('Data added successfully: '
            'Name: ${_nameController.text}, '
            'Discord Username: ${_discordUsernameController.text}, '
            'Selected Clubs: ${selectedClubs.join(', ')}, '
            'Year of Study: $selectedYear, '
            'Batch: $selectedBatch');

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Registration Successful'),
              content: Text(
                'Name: ${_nameController.text}\n'
                    'Discord Username: ${_discordUsernameController.text}\n'
                    'Selected Clubs: ${selectedClubs.join(', ')}\n'
                    'Year of Study: $selectedYear\n'
                    'Batch: $selectedBatch',
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
        print('Error occurred: ${e.toString()}');
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

  // Method to launch GitHub profile
  void _launchURL() async {
    const url = 'https://github.com/syedzubyl';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
                Text(
                  'Select Year of Study:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Column(
                  children: yearOfStudy.map((year) {
                    return RadioListTile<String>(
                      title: Text(year),
                      value: year,
                      groupValue: selectedYear,
                      onChanged: (value) {
                        setState(() {
                          selectedYear = value;
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                Text(
                  'Select Batch:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  hint: Text('Select Batch'),
                  value: selectedBatch,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedBatch = newValue;
                    });
                  },
                  items: <String>['A', 'B', 'C', 'D'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _launchURL,
        child: Text('Find Me'),
        tooltip: 'Visit my GitHub',
      ),
    );
  }
}
