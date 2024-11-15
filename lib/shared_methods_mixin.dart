import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;  // Used to fetch dictionary data

import 'package:ibanag_dictionary_app/classes/dict_entry.dart';
import 'package:ibanag_dictionary_app/classes/ex_sentence.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

mixin SharedMethods {
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
  Future<List<DictionaryEntry>> fetchFavoriteWords() async {
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
    List<DictionaryEntry> favoriteWords = [
      for (final {
      'ibg_word': ibanagWord as String,
      'eng_word': englishWord as String,
      'part_of_speech': partOfSpeech as String
      } in favoriteIbanagWordMaps)
        DictionaryEntry(ibanagWord: ibanagWord, englishWord: englishWord, partOfSpeech: partOfSpeech)
    ];
    // Sort favorite words alphabetically by Ibanag word
    favoriteWords.sort((a, b) => a.ibanagWord.compareTo(b.ibanagWord));
    return favoriteWords;
  }

  // Method to Get Random Word
  Future<DictionaryEntry> getRandomWord() async {
    // Get Total Number of Entries in Dictionary
    int totalNumberEntries = 0;
    final response = await http.get(Uri.parse('http://192.168.1.42:3000/dict_entry?select=count'));
    if (response.statusCode == 200) {
      List<dynamic> fetchedResults = jsonDecode(response.body);
      totalNumberEntries = fetchedResults.elementAt(0)['count'];
    } else {
      throw Exception('Failed to get total number of entries in dictionary');
    }
    // Display 'null' if no words in the dictionary
    if (totalNumberEntries == 0) {
      return const DictionaryEntry(ibanagWord: 'null', englishWord: 'null', partOfSpeech: 'null');
    }
    // Select a random number from 1 to 'totalNumberEntries'
    int randomNumber = Random().nextInt(totalNumberEntries) + 1;
    // Get DictionaryEntry that corresponds with random number
    final response2 = await http.get(Uri.parse('http://192.168.1.42:3000/dict_entry?entry_id=eq.$randomNumber'));
    if (response2.statusCode == 200) {
      List<dynamic> fetchedResults = jsonDecode(response2.body);
      return DictionaryEntry(ibanagWord: fetchedResults.elementAt(0)['ibg_word'], englishWord: fetchedResults.elementAt(0)['eng_word'], partOfSpeech: fetchedResults.elementAt(0)['part_of_speech']);
    } else {
      throw Exception('Failed to get results');
    }
  }
}