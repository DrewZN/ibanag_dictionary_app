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
              height: 40.0,
            ),
            // Example Sentence(s)
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
                  const Text(
                    'Example Sentence(s)',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 25.0
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Padding
                  const SizedBox(
                    height: 15.0,
                  ),
                  ListView.builder(
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
          ],
        ),
      )
    );
  }
}