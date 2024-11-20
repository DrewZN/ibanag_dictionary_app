import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;  // Used to fetch dictionary data
import 'package:path/path.dart';  // Used for SQLite
import 'package:sqflite/sqflite.dart';  // Used for SQLite

import 'package:ibanag_dictionary_app/classes/dict_entry.dart';
import 'package:ibanag_dictionary_app/classes/ex_sentence.dart';

mixin SharedMethods {
  // Method to Fetch Example Sentence(s) for Current Ibanag Word
  Future<List<ExampleSentence>> fetchExampleSentences(DictionaryEntry currentEntry) async {
    // Look for all example sentences
    final response = await http.get(Uri.parse('http://ec2-13-57-18-99.us-west-1.compute.amazonaws.com:3000/ex_sentence?entry_id=eq.${currentEntry.entryID}'));
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
    final response = await http.get(Uri.parse('http://ec2-13-57-18-99.us-west-1.compute.amazonaws.com:3000/dict_entry?eng_word=eq.${currentEntry.englishWord}&ibg_word=neq.${currentEntry.ibanagWord}'));
    if (response.statusCode == 200) {
      List<dynamic> fetchedResults = jsonDecode(response.body);
      // Convert to List of DictionaryEntry
      List<DictionaryEntry> resultsArr = [];
      for (int i = 0; i < fetchedResults.length; ++i) {
        resultsArr.add(DictionaryEntry(entryID: fetchedResults.elementAt(i)['entry_id'], ibanagWord: fetchedResults.elementAt(i)['ibg_word'], englishWord: fetchedResults.elementAt(i)['eng_word'], partOfSpeech: fetchedResults.elementAt(i)['part_of_speech']));
      }
      // Sort in alphabetical order by Ibanag word
      resultsArr.sort((a, b) => a.ibanagWord.compareTo(b.ibanagWord));
      return resultsArr;
    } else {
      throw Exception('Failed to get results');
    }
  }

  // Method to Fetch User's Favorite Ibanag Words
  Future<List<DictionaryEntry>> fetchFavoriteWords() async {
    WidgetsFlutterBinding.ensureInitialized();
    final favoriteIbanagWordsDB = openDatabase(
      join(await getDatabasesPath(), 'ibanag_dict_data.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS ibg_fav_word (entry_id INTEGER PRIMARY KEY, ibg_word TEXT, eng_word TEXT, part_of_speech TEXT)'
        );
      },
      version: 1
    );
    final db = await favoriteIbanagWordsDB;
    final List<Map<String, Object?>> favoriteIbanagWordMaps = await db.query('ibg_fav_word');
    // Close DB
    await db.close();
    // Convert to List of DictionaryEntry and set 'favoriteWords'
    List<DictionaryEntry> favoriteWords = [
      for (final {
      'entry_id': entryID as int,
      'ibg_word': ibanagWord as String,
      'eng_word': englishWord as String,
      'part_of_speech': partOfSpeech as String
      } in favoriteIbanagWordMaps)
        DictionaryEntry(entryID: entryID, ibanagWord: ibanagWord, englishWord: englishWord, partOfSpeech: partOfSpeech)
    ];
    // Sort favorite words alphabetically by Ibanag word
    favoriteWords.sort((a, b) => a.ibanagWord.compareTo(b.ibanagWord));
    return favoriteWords;
  }
}