import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';  // Used to display toast messages to the user
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
                            // First check if user has any words favorited
                            if (favoriteWords!.isEmpty) {
                              // Display error message
                              Fluttertoast.showToast(
                                msg: 'You have not favorited any words!',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 3,
                                backgroundColor: Colors.black,
                                textColor: Colors.white,
                                fontSize: 16.0
                              );
                              return;
                            }
                            // Navigate to Quiz Setup Screen
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => QuizSetupScreen(favoriteWords))
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
      where: 'entry_id = ?',
      whereArgs: [wordToUnfavorite.entryID]
    );
    // From screen
    favoriteWords.removeWhere((item) => item.ibanagWord == wordToUnfavorite.ibanagWord);
    // Close DB
    await db.close();
    // Refresh screen
    setState(() {});
  }
}