// Import the Flutter material design package.
import 'package:flutter/material.dart';

// Define a StatefulWidget called FiltersPage, which is mutable and can have its state changed.
class FiltersPage extends StatefulWidget {
  // Declare variables to store filter settings as properties of the class.
  final bool isAnyCategory;
  final List<String> selectedCategories;
  final String selectedLanguage;
  final List<String> blacklistFlags;
  final bool isSingle;
  final bool isTwopart;
  final String searchKeyword;

  // Constructor for FiltersPage, initializing all its properties.
  // `required` keyword means these properties must be provided when creating an instance of FiltersPage.
  FiltersPage({
    Key? key,
    required this.isAnyCategory,
    required this.selectedCategories,
    required this.selectedLanguage,
    required this.blacklistFlags,
    required this.isSingle,
    required this.isTwopart,
    required this.searchKeyword,
  }) : super(
            key: key); // Initialize the superclass widget with an optional key.

  // Create state for this StatefulWidget.
  @override
  _FiltersPageState createState() => _FiltersPageState();
}

// Define the mutable state class for FiltersPage.
class _FiltersPageState extends State<FiltersPage> {
  // Declare mutable properties for the state.
  late bool isAnyCategory;
  late List<String> selectedCategories;
  late String selectedLanguage;
  late List<String> blacklistFlags;
  late bool isSingle;
  late bool isTwopart;
  late String searchKeyword;

  // Define default values for categories in a map.
  Map<String, bool> categories = {
    'Programming': false,
    'Misc': false,
    'Dark': false,
    'Pun': false,
    'Spooky': false,
    'Christmas': false,
  };

  // Define a constant list of languages.
  final List<String> languages = ['en', 'de', 'es', 'fr'];
  // Define a constant list of blacklist flags.
  final List<String> flags = [
    'nsfw',
    'religious',
    'political',
    'racist',
    'sexist',
    'explicit'
  ];

  // Initialize state in initState method which is called once when the widget is mounted.
  @override
  void initState() {
    super.initState();
    // Initialize filter settings from the widget properties.
    isAnyCategory = widget.isAnyCategory;
    selectedCategories = List<String>.from(widget.selectedCategories);
    selectedLanguage = widget.selectedLanguage;
    blacklistFlags = List<String>.from(widget.blacklistFlags);
    isSingle = widget.isSingle;
    isTwopart = widget.isTwopart;

    // Update categories based on the selected categories.
    categories.forEach((key, value) {
      categories[key] = selectedCategories.contains(key);
    });
  }

  // Function to save the filter settings and exit the current screen.
  void saveFiltersAndExit() {
    Navigator.pop(context, {
      'isAnyCategory': isAnyCategory,
      'selectedCategories': selectedCategories,
      'selectedLanguage': selectedLanguage,
      'blacklistFlags': blacklistFlags,
      'isSingle': isSingle,
      'isTwopart': isTwopart,
      'searchKeyword': searchKeyword,
    });
  }

  // Build the UI of the FiltersPage.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Filters'),
        actions: [
          TextButton(
            onPressed: saveFiltersAndExit,
            child: Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: [
          ListTile(
              title: Text('Select category/categories:'),
              subtitle: buildCategoriesSection()),
          ListTile(
              title: Text('Select language:'),
              trailing: buildLanguageDropdown()),
          ListTile(
              title: Text('Select flags to blacklist:'),
              subtitle: buildFlagsChips()),
          ListTile(
              title: Text('Select at least one joke type:'),
              subtitle: buildJokeTypeChips()),
          buildSearchInput(),
        ],
      ),
    );
  }

  // Build the UI section for selecting categories.
  Widget buildCategoriesSection() => Column(children: [
        RadioListTile<bool>(
          title: const Text('Any'),
          value: true,
          groupValue: isAnyCategory,
          onChanged: (value) => setState(() {
            isAnyCategory = value!;
            selectedCategories.clear();
          }),
        ),
        RadioListTile<bool>(
          title: const Text('Custom'),
          value: false,
          groupValue: isAnyCategory,
          onChanged: (value) {
            setState(() {
              isAnyCategory = false;
            });
          },
        ),
        if (!isAnyCategory) // The condition that checks if 'Custom' is selected
          ...categories.keys
              .map((key) => CheckboxListTile(
                    title: Text(key),
                    value: categories[key],
                    onChanged: (bool? value) {
                      if (value != null) {
                        setState(() {
                          categories[key] = value;
                          if (value) {
                            selectedCategories.add(key);
                          } else {
                            selectedCategories.remove(key);
                          }
                        });
                      }
                    },
                  ))
              .toList(),
      ]);

  // Build the dropdown menu for selecting a language.
  Widget buildLanguageDropdown() => DropdownButton<String>(
        value: selectedLanguage,
        onChanged: (newValue) => setState(() => selectedLanguage = newValue!),
        items: languages
            .map<DropdownMenuItem<String>>(
                (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ))
            .toList(),
      );

  // Build the UI section for selecting blacklist flags.
  Widget buildFlagsChips() => Wrap(
        spacing: 8.0,
        children: flags
            .map((flag) => FilterChip(
                  label: Text(flag),
                  selected: blacklistFlags.contains(flag),
                  onSelected: (selected) => setState(() => selected
                      ? blacklistFlags.add(flag)
                      : blacklistFlags.remove(flag)),
                ))
            .toList(),
      );

  // Build the UI section for selecting joke types.
  Widget buildJokeTypeChips() => Wrap(
        spacing: 8.0,
        children: [
          ChoiceChip(
            label: Text('Single'),
            selected: isSingle,
            onSelected: (selected) => setState(() => isSingle = selected),
          ),
          ChoiceChip(
            label: Text('Twopart'),
            selected: isTwopart,
            onSelected: (selected) => setState(() => isTwopart = selected),
          ),
        ],
      );

  // Build the UI section for inputting a search keyword.
  Widget buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Search for a joke that contains this keyword',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => setState(() {
          searchKeyword = value;
        }),
      ),
    );
  }
}
