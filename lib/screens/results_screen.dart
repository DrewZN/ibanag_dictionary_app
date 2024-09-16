import 'package:flutter/material.dart';

import 'package:ibanag_dictionary_app/classes/dict_entry.dart';

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
            );
          }
        ),
      ),
    );
  }
}