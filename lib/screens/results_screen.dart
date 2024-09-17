import 'dart:convert';  // Used to fetch dictionary data

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
        child: widget.searchResults.isNotEmpty ? ListView.builder(
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
              // Navigate to word screen on tap
              onTap: () async {
                DictionaryEntry currentEntry = widget.searchResults.elementAt(index);
                // Get example sentences for current Ibanag word
                List<ExampleSentence> exampleSentences = await fetchExampleSentences(currentEntry);
                // Get synonym(s) (if any) for current Ibanag word
                List<DictionaryEntry> synonyms = await fetchSynonyms(currentEntry);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => WordScreen(currentEntry: currentEntry, exampleSentences: exampleSentences, synonyms: synonyms))
                );
              },
            );
          }
        ) : const Text(
          'No Words Found',
          style: TextStyle(
            fontSize: 40.0,
            fontWeight: FontWeight.bold
          ),
          textAlign: TextAlign.center,
        )
      ),
    );
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