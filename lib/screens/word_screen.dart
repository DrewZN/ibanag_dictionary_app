import 'dart:async';  // Used for SQLite
import 'dart:convert';  // Used to fetch dictionary data

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;  // Used to fetch dictionary data
import 'package:path/path.dart';  // Used for SQLite
import 'package:sqflite/sqflite.dart';  // Used for SQLite

import 'package:ibanag_dictionary_app/shared_methods_mixin.dart';

import 'package:ibanag_dictionary_app/classes/dict_entry.dart';
import 'package:ibanag_dictionary_app/classes/ex_sentence.dart';

class WordScreen extends StatefulWidget {
  const WordScreen({super.key, required this.currentEntry, required this.exampleSentences, required this.synonyms});

  final DictionaryEntry currentEntry;
  final List<ExampleSentence> exampleSentences;
  final List<DictionaryEntry> synonyms;

  @override
  State<WordScreen> createState() => _WordScreenState();
}

class _WordScreenState extends State<WordScreen> with SharedMethods {

  late bool _favorited = false;

  @override
  void initState() {
    super.initState();
    // Check if current word is _favorited/unfavorited
    fetchFavoriteWords().then((response) {
      setState(() {
        _favorited = false;
        for (int i = 0; i < response.length; ++i) {
          if (response.elementAt(i).ibanagWord == widget.currentEntry.ibanagWord) {
            _favorited = true;
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // Favorite/Unfavorite Button
          IconButton(
            icon: Icon(_favorited ? Icons.favorite : Icons.favorite_border),
            onPressed: setFavoriteStatus
          ),
        ],
      ),
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
            // Padding
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
                          // Ibanag Sentence
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
                          // English Sentence
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
            ),
            // Padding
            const SizedBox(
              height: 40.0,
            ),
            // Synonym(s)
            const Text(
              'Synonym(s)',
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontSize: 25.0
              ),
              textAlign: TextAlign.center,
            ),
            widget.synonyms.isNotEmpty ? ListView.builder(
              shrinkWrap: true,
              itemCount: widget.synonyms.length,
              itemBuilder: (context, index) {
                return ListTile(
                  // Ibanag Word
                  title: Text(
                    widget.synonyms.elementAt(index).ibanagWord,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  // Part of Speech and English Word
                  subtitle: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(text: '\t\t\t${widget.synonyms.elementAt(index).partOfSpeech}', style: const TextStyle(fontStyle: FontStyle.italic)),
                        const TextSpan(text: '\t-\t'),
                        TextSpan(text: widget.synonyms.elementAt(index).englishWord)
                      ]
                    ),
                  ),
                  // Navigate to word screen on tap
                  onTap: () async {
                    DictionaryEntry currentEntry = widget.synonyms.elementAt(index);
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
              'No Synonyms Found',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      )
    );
  }

  // Method to Set _favorited/Unfavorited Status for Current Ibanag Word
  Future<void> setFavoriteStatus() async {
    // Open database
    WidgetsFlutterBinding.ensureInitialized();
    final favoriteIbanagWordsDB = openDatabase(
        join(await getDatabasesPath(), 'ibanag_dict_data.db'),
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE IF NOT EXISTS ibg_fav_word (entry_id INTEGER PRIMARY KEY ibg_word TEXT, eng_word TEXT, part_of_speech TEXT)'
          );
        },
        version: 1
    );
    final db = await favoriteIbanagWordsDB;
    // Favorite or unfavorite word
    if (_favorited == true) {
      // Unfavorite word
      // In DB
      await db.delete(
        'ibg_fav_word',
        where: 'entry_id = ?',
        whereArgs: [widget.currentEntry.entryID]
      );
      // In Word Screen
      _favorited = !_favorited;
    } else {
      // Favorite word
      // In DB
      await db.rawInsert('INSERT INTO ibg_fav_word (entry_id, ibg_word, eng_word, part_of_speech) VALUES (${widget.currentEntry.entryID}, "${widget.currentEntry.ibanagWord}", "${widget.currentEntry.englishWord}", "${widget.currentEntry.partOfSpeech}")');
      // In Word Screen
      _favorited = !_favorited;
    }
    // Close DB
    await db.close();
    // Refresh screen
    setState(() {});
  }
}