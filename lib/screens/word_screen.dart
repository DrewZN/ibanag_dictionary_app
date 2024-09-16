import 'package:flutter/material.dart';

import 'package:ibanag_dictionary_app/classes/dict_entry.dart';
import 'package:ibanag_dictionary_app/classes/ex_sentence.dart';

class WordScreen extends StatefulWidget {
  const WordScreen({super.key, required this.currentEntry, required this.exampleSentences});

  final DictionaryEntry currentEntry;
  final List<ExampleSentence> exampleSentences;

  @override
  State<WordScreen> createState() => _WordScreenState();
}

class _WordScreenState extends State<WordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ListView(
          children: <Widget>[
            // Ibanag Word
            Text(
              widget.currentEntry.ibanagWord,
              style: const TextStyle(
                fontSize: 75.0,
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
            // Part of Speech
            Text(
              widget.currentEntry.partOfSpeech,
              style: const TextStyle(
                fontSize: 20.0,
                fontStyle: FontStyle.italic
              ),
              textAlign: TextAlign.center,
            ),
            // Spacing
            const SizedBox(
              height: 15.0,
            ),
            // English Word
            Text(
              widget.currentEntry.englishWord,
              style: const TextStyle(
                fontSize: 35.0
              ),
              textAlign: TextAlign.center,
            ),
            // Padding
            const SizedBox(
              height: 100.0,
            ),
            // Example Sentence(s)
            const Text(
              'Example Sentences',
              style: TextStyle(
                fontSize: 40.0
              ),
              textAlign: TextAlign.center,
            ),
            // Padding
            const SizedBox(
              height: 15.0,
            ),
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(25.0, 0, 25.0, 0),
              shrinkWrap: true,
              itemCount: widget.exampleSentences.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Text(
                      widget.exampleSentences.elementAt(index).ibanagSentence,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center
                    ),
                    // Padding
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      widget.exampleSentences.elementAt(index).englishSentence,
                      textAlign: TextAlign.center
                    ),
                    // Padding
                    const SizedBox(
                      height: 10.0,
                    ),
                  ],
                );
              }
            )
          ],
        ),
      )
    );
  }
}