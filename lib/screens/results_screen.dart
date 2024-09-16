import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;  // Used to fetch dictionary data

import 'package:ibanag_dictionary_app/classes/dict_entry.dart';
import 'package:ibanag_dictionary_app/classes/ex_sentence.dart';
import 'package:ibanag_dictionary_app/screens/word_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, required this.title, required this.searchResults});

  final String title;
  final List<DictionaryEntry> searchResults;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Results for: ${widget.title}')),
      body: Center(
        child: ListView.builder(
          itemCount: widget.searchResults.length,
          itemBuilder: (context, index) {
            return ListTile(
              // Ibanag Word
              title: Text(
                widget.searchResults.elementAt(index).ibanagWord,
                style: const TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold
                ),
              ),
              // English Word
              subtitle: Text(widget.searchResults.elementAt(index).englishWord),
              // Navigate to word page on tap
              onTap: () async {
                DictionaryEntry currentEntry = widget.searchResults.elementAt(index);
                // Get example sentences for current Ibanag word
                Future<List<ExampleSentence>> exampleSentencesFuture = fetchExampleSentences(currentEntry);
                List<ExampleSentence> exampleSentences = await exampleSentencesFuture;
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => WordScreen(currentEntry: currentEntry, exampleSentences: exampleSentences))
                );
              },
            );
          }
        ),
      ),
    );
  }

  // Method to Fetch Example Sentences for Current Ibanag Word
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
      return [];
    }
  }
}