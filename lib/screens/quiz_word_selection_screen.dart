import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';  // Used to display toast messages to the user

import 'package:ibanag_dictionary_app/shared_methods_mixin.dart';

import 'package:ibanag_dictionary_app/classes/dict_entry.dart';

import 'package:ibanag_dictionary_app/screens/quiz_screen.dart';

class QuizWordSelectionScreen extends StatefulWidget {
  late List<DictionaryEntry> _favoriteWords;
  
  QuizWordSelectionScreen(List<DictionaryEntry> favoriteWords, {super.key}) {
    _favoriteWords = favoriteWords;
  }

  @override
  State<QuizWordSelectionScreen> createState() => _QuizWordSelectionScreenState();
}

class _QuizWordSelectionScreenState extends State<QuizWordSelectionScreen> with SharedMethods {
  late List<bool> _favoriteWordsSelected;
  final List<DictionaryEntry> _selectedWords = [];

  @override
  void initState() {
    super.initState();
    // Initialize 'favoriteWordsSelected'
    _favoriteWordsSelected = List<bool>.filled(widget._favoriteWords.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Words for the Quiz'),
      ),
      body: FutureBuilder(
        future: fetchFavoriteWords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Case: Still Loading
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Case: Error Found
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Case: Successfully Loaded in Favorite Words
            return Center(
              child: ListView.builder(
                itemCount: widget._favoriteWords.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    // Ibanag Word
                    title: Text(
                      widget._favoriteWords.elementAt(index).ibanagWord,
                      style: const TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    // Part of Speech and English Word
                    subtitle: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: '\t\t\t${widget._favoriteWords.elementAt(index).partOfSpeech}', style: const TextStyle(fontStyle: FontStyle.italic)),
                          const TextSpan(text: '\t-\t'),
                          TextSpan(text: widget._favoriteWords.elementAt(index).englishWord)
                        ]
                      ),
                    ),
                    // Select/Deselect Ibanag Word on Tap
                    onChanged: (bool? value) {
                      // Add/Remove from Selected Words List
                      if (value!) {
                        // Case: Add to Selected Words List
                        // Only add if not already in the list
                        if (!_selectedWords.contains(widget._favoriteWords.elementAt(index))) {
                          _selectedWords.add(widget._favoriteWords.elementAt(index));
                        }
                      } else {
                        // Only remove if part of the list
                        // Case: Remove from Selected Words List
                        if (_selectedWords.contains(widget._favoriteWords.elementAt(index))) {
                          _selectedWords.remove(widget._favoriteWords.elementAt(index));
                        }
                      }
                      // Refresh Screen
                      setState(() {
                        _favoriteWordsSelected[index] = value;
                      });
                    },
                    value: _favoriteWordsSelected.elementAt(index),
                  );
                }
              ),
            );
          }
        }
      ),
      // Floating Action Button to Start Quiz with Selected Words
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Check if user has selected any words
          if (_selectedWords.isEmpty) {
            // Display error message
            Fluttertoast.showToast(
              msg: 'Please select at least one (1) word',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0
            );
            return;
          }
          // Randomize word order
          _selectedWords.shuffle();
          // Navigate to actual Quiz Screen
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => QuizScreen(_selectedWords, widget._favoriteWords))
          );
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}