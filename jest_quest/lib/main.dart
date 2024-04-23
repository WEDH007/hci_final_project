// Import Flutter material design and HTTP packages.
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON parsing
import 'filters_page.dart'; // Ensure this file exists and contains the FiltersPage class.

// The main entry point of the Flutter application.
void main() {
  runApp(JestQuestApp()); // Starts the JestQuestApp.
}

// StatelessWidget that serves as the root of the application.
class JestQuestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // MaterialApp is the root widget that wraps other widgets and provides theming and navigation.
    return MaterialApp(
      title: 'JestQuest', // Title for the app used in task manager.
      theme: ThemeData(
        primarySwatch: Colors.blue, // Main color theme.
        visualDensity: VisualDensity.adaptivePlatformDensity, // Adapts density for different platforms.
      ),
      home: HomePage(), // Specifies the home page widget.
    );
  }
}

// StatefulWidget that represents the home page.
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState(); // Creates state for HomePage.
}

// State class for HomePage.
class _HomePageState extends State<HomePage> {
  String _joke = ''; // Holds the current joke as a string.
  bool _isAnyCategory = true; // If true, any category of joke is acceptable.
  List<String> _selectedCategories = []; // Holds user-selected joke categories.
  String _selectedLanguage = 'en'; // Selected language for jokes, default is English.
  List<String> _blacklistFlags = []; // Flags to exclude certain types of jokes.
  bool _isSingle = true; // If true, fetches single-part jokes.
  bool _isTwopart = true; // If true, fetches two-part jokes.
  String _searchKeyword = ''; 

  // Asynchronous method to fetch a joke from an API.
  void fetchJoke() async {
    // Constructs the category part of the API URL.
    String category = _isAnyCategory ? 'Any' : _selectedCategories.join(",");
    // Constructs the blacklist part of the API URL.
    String blacklist = _blacklistFlags.join(',');
    // Decides the joke type based on the user settings.
    String jokeType = _isSingle && !_isTwopart ? 'single' : (_isTwopart && !_isSingle ? 'twopart' : 'any');
    // Builds the full API URL.
    Uri apiUrl = Uri.parse('https://v2.jokeapi.dev/joke/$category'
        '?format=json'
        '&blacklistFlags=$blacklist'
        '&type=$jokeType'
        '&lang=$_selectedLanguage'
        '&amount=1'
        '&contains=$_searchKeyword');

    try {
      // Makes an HTTP GET request to the API.
      http.Response response = await http.get(apiUrl);
      // Checks for a successful response.
      if (response.statusCode == 200) {
        // Parses the JSON response.
        Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          if (data['error'] == false) {
            // Handles different types of jokes.
            if (data['type'] == 'single') {
              _joke = data['joke'];
            } else if (data['type'] == 'twopart') {
              _joke = '${data['setup']}... ${data['delivery']}';
            }
          } else {
            _joke = 'No joke found.';
          }
        });
      } else {
        setState(() {
          _joke = 'Failed to load joke.';
        });
      }
    } catch (e) {
      setState(() {
        _joke = 'Error fetching joke.';
      });
    }
  }

  // Builds the HomePage widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JestQuest'), // Sets the title of the AppBar.
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _joke.isEmpty ? 'Press the button to get a joke!' : _joke,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.0), // Provides spacing between elements.
            ElevatedButton(
              onPressed: fetchJoke,
              child: Text('Tell me a joke!'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Navigates to the FiltersPage and awaits the result.
                final results = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FiltersPage(
                      isAnyCategory: _isAnyCategory,
                      selectedCategories: _selectedCategories,
                      selectedLanguage: _selectedLanguage,
                      blacklistFlags: _blacklistFlags,
                      isSingle: _isSingle,
                      isTwopart: _isTwopart,
                      searchKeyword: _searchKeyword,
                    ),
                  ),
                );

                // Updates the filter settings based on the returned results.
                if (results != null && results is Map) {
                  setState(() {
                    _isAnyCategory = results['isAnyCategory'];
                    _selectedCategories = List<String>.from(results['selectedCategories']);
                    _selectedLanguage = results['selectedLanguage'];
                    _blacklistFlags = List<String>.from(results['blacklistFlags']);
                    _isSingle = results['isSingle'];
                    _isTwopart = results['isTwopart'];
                    _searchKeyword = results['searchKeyword'];
                  });
                }
              },
              child: Text('Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
