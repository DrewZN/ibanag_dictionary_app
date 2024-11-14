import 'dart:math';

import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';  // Used to display toast messages to the user

import 'package:ibanag_dictionary_app/classes/dict_entry.dart';

import 'package:ibanag_dictionary_app/screens/quiz_screen.dart';

class QuestionRandomizationScreen extends StatefulWidget {
  late List<DictionaryEntry> _favoriteWords;

  QuestionRandomizationScreen(List<DictionaryEntry> favoriteWords, {super.key}) {
    _favoriteWords = favoriteWords;
  }

  @override
  State<QuestionRandomizationScreen> createState() => _QuestionRandomizationScreenState();
}

class _QuestionRandomizationScreenState extends State<QuestionRandomizationScreen> {
  late var _numberOfQuestionsStr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Setup')),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(50.0),
          children: <Widget>[
            // Padding
            const SizedBox(
              height: 30.0,
            ),
            // 'How many questions do you want?'
            const Text(
              'How many questions do you want?',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
            // '(Max: ${widget._favoriteWords.length})'
            Text(
              '(Max: ${widget._favoriteWords.length})',
              style: const TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
            // Padding
            const SizedBox(
              height: 80.0,
            ),
            // Number of Questions Text Field and Start Quiz Button
            Column(
              children: [
                // Number of Questions Text Field
                TextField(
                  onChanged: (text) {
                    // Set number of questions
                    _numberOfQuestionsStr = text;
                  },
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                ),
                // Padding
                const SizedBox(
                  height: 80.0,
                ),
                // Start Quiz Button
                ElevatedButton(
                  onPressed: () {
                    // Check if _numberOfQuestionsStr is not an integer
                    if (int.tryParse(_numberOfQuestionsStr) == null) {
                      // Display error message
                      Fluttertoast.showToast(
                        msg: 'Please type in a number (using digits)',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 3,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 16.0
                      );
                    }
                    // Convert to int
                    int numberOfQuestions = int.parse(_numberOfQuestionsStr);
                    // Check if less than 1 or more than 'widget._favoriteWords.length'
                    if (numberOfQuestions < 1 || numberOfQuestions > widget._favoriteWords.length) {
                      // Display error message
                      Fluttertoast.showToast(
                        msg: 'Please type in a number between 1 and ${widget._favoriteWords.length}',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 3,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 16.0
                      );
                      return;
                    }
                    // Randomly Select Words
                    List<DictionaryEntry> randomlySelectedWords = [];
                    for (var i = 0; i < numberOfQuestions; ++i) {
                      // Randomly select index from 0 (inclusive) to 'widget._favoriteWords.length' (exclusive)
                      var randomIndex = Random().nextInt(widget._favoriteWords.length);
                      DictionaryEntry randomlySelectedWord = widget._favoriteWords.elementAt(randomIndex);
                      // Only add randomly-selected word is not in the list of randomly-selected words
                      while (randomlySelectedWords.contains(randomlySelectedWord)) {
                        // Continuously select words until a unique one (relative to 'randomlySelectedWords') is found
                        randomIndex = Random().nextInt(widget._favoriteWords.length);
                        randomlySelectedWord = widget._favoriteWords.elementAt(randomIndex);
                      }
                      // Add word to 'randomlySelectedWords'
                      randomlySelectedWords.add(randomlySelectedWord);
                    }
                    // Navigate to actual Quiz Screen
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => QuizScreen(randomlySelectedWords, widget._favoriteWords))
                    );
                  },
                  child: const Text(
                    'Start Quiz'
                  ),
                ),
              ],
            )
          ],
        ),
      )
    );
  }
}