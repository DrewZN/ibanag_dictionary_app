library DictionaryEntry;

class DictionaryEntry {
  final int entryID;
  final String ibanagWord;
  final String englishWord;
  final String partOfSpeech;

  const DictionaryEntry({
    required this.entryID,
    required this.ibanagWord,
    required this.englishWord,
    required this.partOfSpeech
  });

  Map<String,Object?> toMap() {
    return {
      'entry_id': entryID,
      'ibg_word': ibanagWord,
      'eng_word': englishWord,
      'part_of_speech': partOfSpeech
    };
  }

  @override
  String toString() {
    return 'DictionaryEntry{entry_id: $entryID, ibg_word: $ibanagWord, eng_word: $englishWord, part_of_speech: $partOfSpeech}';
  }
}
