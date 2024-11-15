library QuizQuestion;

import 'package:ibanag_dictionary_app/classes/dict_entry.dart';

class QuizQuestion {
  DictionaryEntry? currentIbanagWord;
  List<DictionaryEntry>? answers; // Would include current word's English translation and three random answers for use in the multiple-choice quiz

  QuizQuestion(this.currentIbanagWord, this.answers);
}