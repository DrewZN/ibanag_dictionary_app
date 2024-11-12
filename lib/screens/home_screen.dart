import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';  // Used to display toast messages to the user
import 'package:http/http.dart' as http;  // Used to fetch dictionary data

import 'package:ibanag_dictionary_app/classes/dict_entry.dart';
import 'package:ibanag_dictionary_app/classes/ex_sentence.dart';

import 'package:ibanag_dictionary_app/screens/favorite_words_screen.dart';
import 'package:ibanag_dictionary_app/screens/results_screen.dart';
import 'package:ibanag_dictionary_app/screens/word_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String inputtedText = '';

  late DictionaryEntry randomWord;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // App Title
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text(
                'Ibanag Dictionary',
                style: TextStyle(
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold
                ),
              )
            ),
            // Favorite Words Screen
            ListTile(
              title: const Text('Favorite Words'),
              // Navigate to Favorite Words screen
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => FavoriteWordsScreen())
                );
              }
            )
          ],
        ),
      ),
      body: FutureBuilder<DictionaryEntry>(
        future: getRandomWord(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Case: Still Loading
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Case: Error Found
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Case: Successfully Loaded Random Word
            final randomWord = snapshot.data!;
            return Center(
              child: ListView(
                padding: const EdgeInsets.all(50.0),
                children: <Widget>[
                  // Padding
                  const SizedBox(
                    height: 80
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
                  // Padding
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
                  // Padding
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
                  ),
                  // Padding
                  const SizedBox(
                      height: 25
                  ),
                  // Random Word Box
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color:Colors.white)
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12
                    ),
                    child: Column(
                      children: [
                        // 'Random Word' Text
                        const Text(
                          'Random Word',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 25.0
                          ),
                          textAlign: TextAlign.center,
                        ),
                        // Button for the Word Screen of the Random Word
                        ListTile(
                          // Ibanag Word
                          title: Center(
                            child: Text(
                              randomWord.ibanagWord,
                              style: const TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          // Part of Speech and English Word
                          subtitle: Center(
                            child: RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(text: randomWord.partOfSpeech, style: const TextStyle(fontStyle: FontStyle.italic)),
                                  const TextSpan(text: '\t-\t'),
                                  TextSpan(text: randomWord.englishWord)
                                ]
                              ),
                            ),
                          ),
                          // Navigate to word screen on tap
                          onTap: () async {
                            DictionaryEntry currentEntry = randomWord;
                            // Get example sentences for current Ibanag word
                            List<ExampleSentence> exampleSentences = await fetchExampleSentences(currentEntry);
                            // Get synonym(s) (if any) for current Ibanag word
                            List<DictionaryEntry> synonyms = await fetchSynonyms(currentEntry);
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => WordScreen(currentEntry: currentEntry, exampleSentences: exampleSentences, synonyms: synonyms))
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
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
        resultsArr.add(DictionaryEntry(ibanagWord: fetchedResults.elementAt(i)['ibg_word'], englishWord: fetchedResults.elementAt(i)['eng_word'], partOfSpeech: fetchedResults.elementAt(i)['part_of_speech']));
      }
      // Sort in alphabetical order by Ibanag word
      resultsArr.sort((a, b) => a.ibanagWord.compareTo(b.ibanagWord));
      return resultsArr;
    } else {
      throw Exception('Failed to get results');
    }
  }

  // Method to Get Random Word
  Future<DictionaryEntry> getRandomWord() async {
    // Get Total Number of Entries in Dictionary
    int totalNumberEntries = 0;
    final response = await http.get(Uri.parse('http://192.168.1.42:3000/dict_entry?select=count'));
    if (response.statusCode == 200) {
      List<dynamic> fetchedResults = jsonDecode(response.body);
      totalNumberEntries = fetchedResults.elementAt(0)['count'];
    } else {
      throw Exception('Failed to get total number of entries in dictionary');
    }
    // Display 'null' if no words in the dictionary
    if (totalNumberEntries == 0) {
      return const DictionaryEntry(ibanagWord: 'null', englishWord: 'null', partOfSpeech: 'null');
    }
    // Select a random number from 1 to 'totalNumberEntries'
    int randomNumber = Random().nextInt(totalNumberEntries) + 1;
    // Get DictionaryEntry that corresponds with random number
    final response2 = await http.get(Uri.parse('http://192.168.1.42:3000/dict_entry?entry_id=eq.$randomNumber'));
    if (response2.statusCode == 200) {
      List<dynamic> fetchedResults = jsonDecode(response2.body);
      return DictionaryEntry(ibanagWord: fetchedResults.elementAt(0)['ibg_word'], englishWord: fetchedResults.elementAt(0)['eng_word'], partOfSpeech: fetchedResults.elementAt(0)['part_of_speech']);
    } else {
      throw Exception('Failed to get results');
    }
  }

  // Method to Fetch Example Sentence(s) for Current Ibanag Word
  Future<List<ExampleSentence>> fetchExampleSentences(DictionaryEntry currentEntry) async {
    // Look for all example sentences
    final response = await http.get(Uri.parse('http://192.168.1.42:3000/ex_sentence?ibg_word=eq.${currentEntry.ibanagWord}'));
    if (response.statusCode == 200) {
      List<dynamic> fetchedResults = jsonDecode(response.body);
      // Convert to List of ExampleSentence
      List<ExampleSentence> resultsArr = [];
      for (int i = 0; i < fetchedResults.length; ++i) {
        resultsArr.add(ExampleSentence(fetchedResults.elementAt(i)['ibg_sentence'], fetchedResults.elementAt(i)['eng_sentence']));
      }
      return resultsArr;
    } else {
      throw Exception('Failed to get results');
    }
  }

  // Method to Fetch Synonym(s) (If Any) for Current Ibanag Word (Based on English Word/Translation)
  Future<List<DictionaryEntry>> fetchSynonyms(DictionaryEntry currentEntry) async {
    // Look for all synonym(s) (if any)
    final response = await http.get(Uri.parse('http://192.168.1.42:3000/dict_entry?eng_word=eq.${currentEntry.englishWord}&ibg_word=neq.${currentEntry.ibanagWord}'));
    if (response.statusCode == 200) {
      List<dynamic> fetchedResults = jsonDecode(response.body);
      // Convert to List of DictionaryEntry
      List<DictionaryEntry> resultsArr = [];
      for (int i = 0; i < fetchedResults.length; ++i) {
        resultsArr.add(DictionaryEntry(ibanagWord: fetchedResults.elementAt(i)['ibg_word'], englishWord: fetchedResults.elementAt(i)['eng_word'], partOfSpeech: fetchedResults.elementAt(i)['part_of_speech']));
      }
      // Sort in alphabetical order by Ibanag word
      resultsArr.sort((a, b) => a.ibanagWord.compareTo(b.ibanagWord));
      return resultsArr;
    } else {
      throw Exception('Failed to get results');
    }
  }
}