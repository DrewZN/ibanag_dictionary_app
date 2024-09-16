import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';  // Used to display toast messages to the user
import 'package:http/http.dart' as http;  // Used to fetch dictionary data

import 'package:ibanag_dictionary_app/classes/dict_entry.dart';
import 'package:ibanag_dictionary_app/screens/results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String inputtedText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(50.0),
          children: <Widget>[
            const SizedBox(
              height: 100
            ),
            // App Title
            const Text(
              'Ibanag',
              style: TextStyle(
                fontSize: 75,
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
            const Text(
              'Dictionary',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 25
            ),
            // Search Bar
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter an English/Ibanag word'
              ),
              onChanged: (value) {
                inputtedText = value;
              },
              onSubmitted: (value) {
                // Look up inputted term
                lookUpTerm();
              },
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 25
            ),
            // Search Button
            ElevatedButton(
              onPressed: () {
                // Look up inputted term
                lookUpTerm();
              },
              child: const Text(
                'Search',
              )
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  // Method to Look Up Term
  void lookUpTerm() async {
    // Check for empty input
    String inputToCheck = inputtedText;
    if (inputToCheck.replaceAll(' ','').isEmpty) {
      // Display error message
      Fluttertoast.showToast(
        msg: 'Please type in an English/Ibanag word',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0
      );
      return;
    }
    // Get search results
    Future<List<DictionaryEntry>> resultsFuture = fetchResults();
    List<DictionaryEntry> searchResults = await resultsFuture;
    // Send user to results screen with all the terms returned by the query
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ResultsScreen(title: inputtedText, searchResults: searchResults))
    );
  }

  // Method to Fetch Search Results
  Future<List<DictionaryEntry>> fetchResults() async {
    // Get English/Ibanag terms matching what the user entered in
    final response = await http.get(Uri.parse('http://192.168.1.42:3000/dict_entry?or=(ibg_word.ilike.*$inputtedText*,eng_word.ilike.*$inputtedText*)&order=ibg_word'));
    if (response.statusCode == 200) {
      List<dynamic> fetchedResults = jsonDecode(response.body);
      // Convert to List of DictionaryEntry
      List<DictionaryEntry> resultsArr = [];
      for (int i = 0; i < fetchedResults.length; ++i) {
        resultsArr.add(DictionaryEntry(ibanagWord: fetchedResults.elementAt(i)['ibg_word'], englishWord: fetchedResults.elementAt(i)['eng_word']));
      }
      // Sort in alphabetical order by Ibanag word
      resultsArr.sort((a, b) => a.ibanagWord.compareTo(b.ibanagWord));
      return resultsArr;
    } else {
      throw Exception('Failed to get results');
    }
  }
}