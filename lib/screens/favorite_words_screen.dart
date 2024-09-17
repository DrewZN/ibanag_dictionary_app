import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;  // Used to fetch dictionary data
import 'package:path/path.dart';  // Used for SQLite
import 'package:sqflite/sqflite.dart';  // Used for SQLite

import 'package:ibanag_dictionary_app/classes/dict_entry.dart';
import 'package:ibanag_dictionary_app/classes/ex_sentence.dart';

import 'package:ibanag_dictionary_app/screens/word_screen.dart';

class FavoriteWordsScreen extends StatefulWidget {
  const FavoriteWordsScreen({super.key});

  @override
  State<FavoriteWordsScreen> createState() => _FavoriteWordsScreenState();
}

class _FavoriteWordsScreenState extends State<FavoriteWordsScreen> {

  late List<DictionaryEntry> favoriteWords = [];

  @override
  void initState() {
    super.initState();
    // Fetch user's favorite words
    fetchFavoriteWords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Favorite Words')),
      body: Center(
        child: favoriteWords.isNotEmpty ? ListView.builder(
            itemCount: favoriteWords.length,
            itemBuilder: (context, index) {
              return ListTile(
                // Ibanag Word
                title: Text(
                  favoriteWords.elementAt(index).ibanagWord,
                  style: const TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
                // Part of Speech and English Word
                subtitle: RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(text: '\t\t\t${favoriteWords.elementAt(index).partOfSpeech}', style: const TextStyle(fontStyle: FontStyle.italic)),
                      const TextSpan(text: '\t-\t'),
                      TextSpan(text: favoriteWords.elementAt(index).englishWord)
                    ]
                  ),
                ),
                // Delete Favorite Button
                trailing: IconButton(
                  onPressed: () {
                    // Delete word from user's favorite words list
                    unfavoriteWord(favoriteWords.elementAt(index));
                  },
                  icon: const Icon(Icons.delete_forever)
                ),
                // Navigate to word screen on tap
                onTap: () async {
                  DictionaryEntry currentEntry = favoriteWords.elementAt(index);
                  // Get example sentences for current Ibanag word
                  List<ExampleSentence> exampleSentences = await fetchExampleSentences(currentEntry);
                  // Get synonym(s) (if any) for current Ibanag word
                  List<DictionaryEntry> synonyms = await fetchSynonyms(currentEntry);
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => WordScreen(currentEntry: currentEntry, exampleSentences: exampleSentences, synonyms: synonyms))
                  ).then((_) {
                    // Recheck user's favorite words
                    fetchFavoriteWords();
                  });
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
        ),
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

  // Method to Fetch User's Favorite Ibanag Words
  void fetchFavoriteWords() async {
    WidgetsFlutterBinding.ensureInitialized();
    final favoriteIbanagWordsDB = openDatabase(
        join(await getDatabasesPath(), 'ibanag_dict_data.db'),
        onCreate: (db, version) {
          return db.execute(
              'CREATE TABLE IF NOT EXISTS ibg_fav_word (ibg_word TEXT PRIMARY KEY, eng_word TEXT, part_of_speech TEXT)'
          );
        },
        version: 1
    );
    final db = await favoriteIbanagWordsDB;
    final List<Map<String, Object?>> favoriteIbanagWordMaps = await db.query('ibg_fav_word');
    // Close DB
    await db.close();
    // Convert to List of DictionaryEntry and set 'favoriteWords'
    favoriteWords = [
      for (final {
      'ibg_word': ibanagWord as String,
      'eng_word': englishWord as String,
      'part_of_speech': partOfSpeech as String
      } in favoriteIbanagWordMaps)
        DictionaryEntry(ibanagWord: ibanagWord, englishWord: englishWord, partOfSpeech: partOfSpeech)
    ];
    // Sort favorite words alphabetically by Ibanag word
    favoriteWords.sort((a, b) => a.ibanagWord.compareTo(b.ibanagWord));
    // Refresh screen
    setState(() {});
  }

  // Method to Unfavorite Current Ibanag Word
  Future<void> unfavoriteWord(DictionaryEntry wordToUnfavorite) async {
    // Open database
    WidgetsFlutterBinding.ensureInitialized();
    final favoriteIbanagWordsDB = openDatabase(
        join(await getDatabasesPath(), 'ibanag_dict_data.db')
    );
    final db = await favoriteIbanagWordsDB;
    // Favorite or unfavorite word
    await db.delete(
        'ibg_fav_word',
        where: 'ibg_word = ?',
        whereArgs: [wordToUnfavorite.ibanagWord]
    );
    // From screen
    favoriteWords.removeWhere((item) => item.ibanagWord == wordToUnfavorite.ibanagWord);
    // Close DB
    await db.close();
    // Refresh screen
    setState(() {});
  }
}