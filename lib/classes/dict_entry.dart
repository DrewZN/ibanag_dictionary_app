library DictionaryEntry;

class DictionaryEntry {
  final String ibanagWord;
  final String englishWord;
  final String partOfSpeech;

  const DictionaryEntry({
    required this.ibanagWord,
    required this.englishWord,
    required this.partOfSpeech
  });

  Map<String,Object?> toMap() {
    return {
      'ibg_word': ibanagWord,
      'eng_word': englishWord,
      'part_of_speech': partOfSpeech
    };
  }

  @override
  String toString() {
    return 'DictionaryEntry{ibg_word: $ibanagWord, eng_word: $englishWord, part_of_speech: $partOfSpeech}';
  }
}
