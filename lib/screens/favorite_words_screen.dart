import 'package:flutter/material.dart';

import 'package:path/path.dart';  // Used for SQLite
import 'package:sqflite/sqflite.dart';  // Used for SQLite

import 'package:ibanag_dictionary_app/shared_methods_mixin.dart';

import 'package:ibanag_dictionary_app/classes/dict_entry.dart';
import 'package:ibanag_dictionary_app/classes/ex_sentence.dart';

import 'package:ibanag_dictionary_app/screens/quiz_setup_screen.dart';
import 'package:ibanag_dictionary_app/screens/word_screen.dart';

class FavoriteWordsScreen extends StatefulWidget {
  const FavoriteWordsScreen({super.key});

  @override
  State<FavoriteWordsScreen> createState() => _FavoriteWordsScreenState();
}

class _FavoriteWordsScreenState extends State<FavoriteWordsScreen> with SharedMethods {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchFavoriteWords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Case: Still Loading
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Case: Error Found
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Case: Successfully Loaded User's Favorite Words
            var favoriteWords = snapshot.data;
            return Scaffold(
              appBar: AppBar(
                title: const Text('Your Favorite Words'),
                actions: <Widget>[
                  PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        // Quiz Setup Button
                        PopupMenuItem(
                          child: const Text('Take a Quiz'),
                          onTap: () {
                            // Navigate to Quiz Setup Screen
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const QuizSetupScreen())
                            );
                          },
                        ),
                      ];
                    }
                  ),
                ],
              ),
              body: Center(
                child: favoriteWords!.isNotEmpty ? ListView.builder(
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
                        // Unfavorite Button
                        trailing: IconButton(
                            onPressed: () {
                              // Delete word from user's favorite words list
                              unfavoriteWord(favoriteWords, favoriteWords.elementAt(index));
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
                            // Refresh screen
                            setState(() {});
                          });
                        },
                      );
                    }
                ) : const Text(
                  'No Favorite Words',
                  style: TextStyle(
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
        }
    );
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

  // Method to Unfavorite Current Ibanag Word
  Future<void> unfavoriteWord(List<DictionaryEntry> favoriteWords, DictionaryEntry wordToUnfavorite) async {
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