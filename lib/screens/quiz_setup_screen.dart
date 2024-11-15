import 'package:flutter/material.dart';

import 'package:ibanag_dictionary_app/classes/dict_entry.dart';

import 'package:ibanag_dictionary_app/screens/question_randomization_screen.dart';
import 'package:ibanag_dictionary_app/screens/quiz_word_selection_screen.dart';

class QuizSetupScreen extends StatefulWidget {
  late List<DictionaryEntry> _favoriteWords;

  QuizSetupScreen(List<DictionaryEntry> favoriteWords, {super.key}) {
    _favoriteWords = favoriteWords;
  }

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
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
            // Quiz Type Selection Screen
            const Text(
              'Tap on',
              style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
            const Text(
              '\'Randomize Quiz\'',
              style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
            const Text(
              'or',
              style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
            const Text(
              '\'Pick Words\'',
              style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
            // Padding
            const SizedBox(
              height: 150.0,
            ),
            // 'Randomize Quiz' and 'Pick Words' Buttons
            Column(
              children: [
                // Randomize Quiz Button
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Question Randomization Screen
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => QuestionRandomizationScreen(widget._favoriteWords))
                    );
                  },
                  child: const Text(
                    'Randomize Quiz'
                  ),
                ),
                // Padding
                const SizedBox(
                  height: 10.0,
                ),
                // Pick Words Button
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Word Selection Screen
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => QuizWordSelectionScreen(widget._favoriteWords))
                    );
                  },
                  child: const Text(
                    'Pick Words'
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