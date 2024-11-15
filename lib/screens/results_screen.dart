import 'package:flutter/material.dart';

import 'package:ibanag_dictionary_app/shared_methods_mixin.dart';

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

class _ResultsScreenState extends State<ResultsScreen> with SharedMethods {
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
              // Part of Speech and English Word
              subtitle: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(text: '\t\t\t${widget.searchResults.elementAt(index).partOfSpeech}', style: const TextStyle(fontStyle: FontStyle.italic)),
                    const TextSpan(text: '\t-\t'),
                    TextSpan(text: widget.searchResults.elementAt(index).englishWord)
                  ]
                ),
              ),
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
}