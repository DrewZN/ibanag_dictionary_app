import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;  // Used to fetch dictionary data

import 'package:ibanag_dictionary_app/shared_methods_mixin.dart';

import 'package:ibanag_dictionary_app/classes/dict_entry.dart';
import 'package:ibanag_dictionary_app/classes/ex_sentence.dart';
import 'package:ibanag_dictionary_app/classes/quiz_question.dart';

import 'package:ibanag_dictionary_app/screens/word_screen.dart';

class QuizScreen extends StatefulWidget {
  late final List<DictionaryEntry> _wordsForQuiz;
  late final List<DictionaryEntry> _favoriteWords;

  QuizScreen(List<DictionaryEntry> wordsForQuiz, List<DictionaryEntry> favoriteWords, {super.key}) {
    _wordsForQuiz = wordsForQuiz;
    _favoriteWords = favoriteWords;
  }

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SharedMethods {
  int _numberCorrect = 0;
  int _questionBankIndex = 0;

  late List<QuizQuestion> _questionBank;
  late List<DictionaryEntry> _incorrectlyAnsweredQuestions;

  @override
  void initState() {
    super.initState();
    _incorrectlyAnsweredQuestions = [];
    // Populate '_questionBank'
    _questionBank = populateQuestionBank();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: (_questionBankIndex <= (_questionBank.length - 1)) ? Column(
            children: <Widget>[
              // Display Current Word
              Text(
                'Question #${_questionBankIndex + 1}',
                style: const TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold
                ),
              ),
              Text(
                'What does \'${_questionBank.elementAt(_questionBankIndex).currentIbanagWord!.ibanagWord}\' mean?',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold
                ),
              ),
              // Padding
              const SizedBox(
                height: 30.0,
              ),
              // Display Four Answers
              // Answer #1
              ListTile(
                title: Text(_questionBank.elementAt(_questionBankIndex).answers!.elementAt(0).englishWord),
                onTap: () {
                  // Check if correct
                  if (_questionBank.elementAt(_questionBankIndex).answers!.elementAt(0).englishWord == _questionBank.elementAt(_questionBankIndex).currentIbanagWord!.englishWord) {
                    _numberCorrect++;
                  } else {
                    _incorrectlyAnsweredQuestions.add(_questionBank.elementAt(_questionBankIndex).currentIbanagWord!);
                  }
                  // Go to next question
                  setState(() {
                    _questionBankIndex++;
                  });
                },
              ),
              // Answer #2
              ListTile(
                title: Text(_questionBank.elementAt(_questionBankIndex).answers!.elementAt(1).englishWord),
                onTap: () {
                  // Check if correct
                  if (_questionBank.elementAt(_questionBankIndex).answers!.elementAt(1).englishWord == _questionBank.elementAt(_questionBankIndex).currentIbanagWord!.englishWord) {
                    _numberCorrect++;
                  } else {
                    _incorrectlyAnsweredQuestions.add(_questionBank.elementAt(_questionBankIndex).currentIbanagWord!);
                  }
                  // Go to next question
                  setState(() {
                    _questionBankIndex++;
                  });
                },
              ),
              // Answer #3
              ListTile(
                title: Text(_questionBank.elementAt(_questionBankIndex).answers!.elementAt(2).englishWord),
                onTap: () {
                  // Check if correct
                  if (_questionBank.elementAt(_questionBankIndex).answers!.elementAt(2).englishWord == _questionBank.elementAt(_questionBankIndex).currentIbanagWord!.englishWord) {
                    _numberCorrect++;
                  } else {
                    _incorrectlyAnsweredQuestions.add(_questionBank.elementAt(_questionBankIndex).currentIbanagWord!);
                  }
                  // Go to next question
                  setState(() {
                    _questionBankIndex++;
                  });
                },
              ),
              // Answer #4
              ListTile(
                title: Text(_questionBank.elementAt(_questionBankIndex).answers!.elementAt(3).englishWord),
                onTap: () {
                  // Check if correct
                  if (_questionBank.elementAt(_questionBankIndex).answers!.elementAt(3).englishWord == _questionBank.elementAt(_questionBankIndex).currentIbanagWord!.englishWord) {
                    _numberCorrect++;
                  } else {
                    _incorrectlyAnsweredQuestions.add(_questionBank.elementAt(_questionBankIndex).currentIbanagWord!);
                  }
                  // Go to next question
                  setState(() {
                    _questionBankIndex++;
                  });
                },
              ),
            ],
          ) : Center(
            child: ListView(
              children: <Widget>[
                // 'Your Score'
                const Text(
                  'Your Score',
                  style: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
                // Padding
                const SizedBox(
                  height: 30.0,
                ),
                Text(
                  '$_numberCorrect / ${_questionBank.length} Correct!',
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
                // Padding
                const SizedBox(
                  height: 30.0,
                ),
                // 'Words You Got Wrong'
                const Text(
                  'Words You Got Wrong',
                  style: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
                _incorrectlyAnsweredQuestions.isNotEmpty ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: _incorrectlyAnsweredQuestions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        // Ibanag Word
                        title: Text(
                          _incorrectlyAnsweredQuestions.elementAt(index).ibanagWord,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        // Part of Speech and English Word
                        subtitle: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(text: '\t\t\t${_incorrectlyAnsweredQuestions.elementAt(index).partOfSpeech}', style: const TextStyle(fontStyle: FontStyle.italic)),
                              const TextSpan(text: '\t-\t'),
                              TextSpan(text: _incorrectlyAnsweredQuestions.elementAt(index).englishWord)
                            ]
                          ),
                        ),
                        // Navigate to word screen on tap
                        onTap: () async {
                          DictionaryEntry currentEntry = _incorrectlyAnsweredQuestions.elementAt(index);
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
                ) : ListView(
                  shrinkWrap: true,
                  children: const <Widget>[
                    // Padding
                    SizedBox(
                      height: 30.0,
                    ),
                    Text(
                      'None',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                )
              ],
            ),
          ),
        )
    );
  }

  // Method to Populate '_questionBank'
  List<QuizQuestion> populateQuestionBank() {
    List<QuizQuestion> ret = [];
    for (int i = 0; i < widget._wordsForQuiz.length; ++i) {
      DictionaryEntry currentWord = widget._wordsForQuiz.elementAt(i);
      // Select answers for current word
      List<DictionaryEntry> answersCurrentQuestion = selectAnswers(currentWord);
      // Add QuizQuestion to 'ret'
      ret.add(QuizQuestion(currentWord, answersCurrentQuestion));
    }
    return ret;
  }

  // Method to Select Answers for Each Question Randomly
  List<DictionaryEntry> selectAnswers(DictionaryEntry currentWord) {
    List<DictionaryEntry> selectedAnswers = [];
    // Add current word to 'selectedAnswers'
    selectedAnswers.add(currentWord);
    // Add three (if possible) other randomly-selected answers
    // Check if user has favorited enough words (4+) without duplicate English translations
    Set<String> favoriteWordsEnglish = widget._favoriteWords.map((DictionaryEntry currentEntry) {
      return currentEntry.englishWord;
    }).toSet();
    if (favoriteWordsEnglish.length >= 4) {
      // From user's favorite words list
      for (int i = 0; i < 3; ++i) {
        // Randomly select index from 0 (inclusive) to 'widget._favoriteWords.length' (exclusive)
        var randomIndex = Random().nextInt(widget._favoriteWords.length);
        DictionaryEntry randomlySelectedWord = widget._favoriteWords.elementAt(randomIndex);
        // Only add randomly-selected word if it is not the same as the current word being shown in the quiz
        // Also prevent duplicate English translations of words in 'selectedAnswers'
        List<String> selectedAnswersEnglish = selectedAnswers.map((DictionaryEntry currentAnswer) {
          return currentAnswer.englishWord;
        }).toList();
        while (!(randomlySelectedWord != currentWord && !selectedAnswersEnglish.contains(randomlySelectedWord.englishWord))) {
          randomIndex = Random().nextInt(widget._favoriteWords.length);
          randomlySelectedWord = widget._favoriteWords.elementAt(randomIndex);
        }
        // Add to 'selectedAnswers'
        selectedAnswers.add(randomlySelectedWord);
      }
    } else {
      // From overall dictionary
      for (int i = 0; i < 3; ++i) {
        DictionaryEntry randomlySelectedWord = getRandomWord(currentWord) as DictionaryEntry;
        // Prevent duplicate words in 'selectedAnswers'
        while (selectedAnswers.contains(randomlySelectedWord)) {
          randomlySelectedWord = getRandomWord(currentWord) as DictionaryEntry;
        }
        // Add to 'selectedAnswers'
        selectedAnswers.add(randomlySelectedWord);
      }
    }
    // Randomize order of answers
    selectedAnswers.shuffle();
    return selectedAnswers;
  }

  // Method to Get Random Word for Quiz
  Future<DictionaryEntry> getRandomWord(DictionaryEntry currentWord) async {
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
    // Get DictionaryEntry that corresponds with random number and that is a word other than 'currentWord'
    final response2 = await http.get(Uri.parse('http://192.168.1.42:3000/dict_entry?and=(entry_id=eq.$randomNumber,ibg_word=not.eq.${currentWord.ibanagWord})'));
    if (response2.statusCode == 200) {
      List<dynamic> fetchedResults = jsonDecode(response2.body);
      return DictionaryEntry(ibanagWord: fetchedResults.elementAt(0)['ibg_word'], englishWord: fetchedResults.elementAt(0)['eng_word'], partOfSpeech: fetchedResults.elementAt(0)['part_of_speech']);
    } else {
      throw Exception('Failed to get results');
    }
  }
}