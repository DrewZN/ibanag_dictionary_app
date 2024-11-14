library QuizQuestion;

import 'package:ibanag_dictionary_app/classes/dict_entry.dart';

class QuizQuestion {
  DictionaryEntry? currentIbanagWord;
  List<DictionaryEntry>? otherAnswers; // Three random answers for use in the multiple-choice quiz
}