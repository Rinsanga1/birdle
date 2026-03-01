import 'dart:collection';
import 'dart:math';

const List<String> validWords = [
  'novel',
  'chiah',
  'taksa',
  'danah',
  'murna',
  'hluii',
  'hming',
  'ellen',
  'tunah',
  'johns',
  'arawk',
  'nutei',
  'pasal',
  'atana',
  'world',
  'thlen',
  'chhuk',
  'group',
  'berah',
  'chuan',
  'huana',
  'dikna',
  'human',
  'zirna',
  'brush',
  'level',
  'velah',
  'mpess',
  'nghal',
  'emery',
  'tirha',
  'match',
  'hmasa',
  'tlawm',
  'zawng',
  'angin',
  'hrang',
  'zinga',
  'inher',
  'duhna',
  'lucky',
  'pitar',
  'filma',
  'raqqa',
  'sailo',
  'tawia',
  'awmze',
  'thlak',
  'cotpa',
  'mante',
  'chawi',
  'tling',
  'khawm',
  'bible',
  'vikas',
  'reiek',
  'snack',
  'turin',
  'hnuai',
  'bakah',
  'tinah',
  'vents',
  'entry',
  'audio',
  'speed',
  'thung',
  'phone',
  'nasat',
  'neitu',
  'email',
  'sales',
  'chhan',
  'hnena',
  'damlo',
  'court',
  'squad',
  'chung',
  'bazar',
  'turah',
  'inang',
  'build',
  'theih',
  'thuai',
  'crime',
  'manto',
  'zahna',
  'hmaah',
  'phuba',
  'innel',
  'takte',
  'natna',
  'zante',
  'hunbi',
  'lohna',
  'ropui',
  'lalte',
  'ngaih',
  'rilru',
  'hriat',
  'thiam',
  'harsa',
  'lutuk',
  'pekna',
  'staff',
  'tihna',
  'takah',
  'takin',
  'vanga',
  'tihbo',
  'cheng',
  'khawl',
  'leite',
  'biate',
  'chauh',
  'awmna',
  'lamah',
  'kawng',
  'minit',
  'black',
  'music',
  'video',
  'round',
  'inkar',
  'chang',
  'tumin',
  'khual',
  'niawm',
  'hmuna',
  'phuah',
  'chawp',
  'india',
  'kumin',
  'state',
  'zanga',
  'panga',
  'price',
  'hmulo',
  'zaklo',
  'hetia',
  'laiin',
  'paula',
  'sipai',
  'mjate',
  'zepui',
  'hnuah',
  'inlan',
  'kalin',
  'maken',
  'press',
  'nitin',
  'index',
  'phase',
  'thawh',
  'mahse',
  'jamie',
  'puhna',
  'nunna',
  'lovin',
  'rural',
  'phura',
  'ineln',
  'thlan',
  'power',
  'dawng',
  'chief',
  'local',
  'kalta',
  'khalh',
  'house',
  'diklo',
  'dawna',
  'thlah',
  'lalpa',
  'keini',
  'bawih',
  'erawh',
  'lalut',
  'union',
  'naxal',
  'force',
  'hliam',
  'chhim',
  'tlawh',
  'jordi',
  'elche',
  'lakah',
  'banah',
  'barca',
  'diltu',
  'helai',
  'tamna',
  'tlang',
  'tahan',
  'telin',
  'hrilh',
  'miten',
  'nimin',
  'board',
  'kamah',
  'lehah',
  'cupah',
  'hralh',
  'thian',
  'phawt',
  'grass',
  'avang',
  'puhin',
  'hmang',
  'wayne',
  'hotel',
  'zuang',
  'bikin',
  'piang',
  'medal',
  'assam',
  'spain',
  'khelh',
  'senso',
  'bituk',
  'vardy',
  'tawlh',
  'chuap',
  'bikah',
  'lawng',
  'khenh',
  'armed',
  'nakin',
  'tesla',
  'tweet',
  'ramri',
  'chian',
  'hlawh',
  'helho',
  'tinin',
  'mahni',
  'march',
  'mipat',
  'hawia',
  'judai',
  'ruala',
  'covid',
  'hluai',
  'hluar',
  'mayor',
  'dilna',
  'trump',
  'isuan',
  'mipui',
  'palai',
  'aanga',
  'varte',
  'eizwn',
  'tunge',
  'likud',
  'party',
  'ramah',
  'hiato',
  'atang',
  'check',
  'inbei',
  'james',
  'point',
  'baval',
  'citya',
  'karah',
  'tirah',
  'tawng',
  'brbae',
  'uidai',
  'civil',
  'himna',
  'phung',
  'hmuam',
  'itawm',
  'hmuin',
  'reite',
  'lanka',
  'hruai',
  'nupui',
  'kaite',
  'kiosk',
  'white',
  'blood',
  'cells',
  'khawi',
  'laiah',
  'hunah',
  'asean',
  'maiin',
  'paper',
  'scrap',
  'fanny',
  'amico',
  'chhoh',
  'judge',
  'helen',
  'jaila',
  'minlo',
  'danga',
  'inzat',
  'media',
  'units',
  'hetah',
  'singh',
  'china',
  'awmte',
  'syria',
  'danin',
  'dubai',
  'mimal',
  'thawk',
  'omkei',
  'halla',
  'zaiha',
  'chona',
  'namen',
  'nghei',
  'lamin',
  'khauh',
  'outro',
  'awmlo',
  'nihna',
  'manna',
  'rawng',
  'apple',
  'mosia',
  'hniam',
  'likbk',
  'deuha',
  'finna',
  'lehin',
  'neiin',
  'zanah',
  'chher',
  'vuain',
  'bulah',
  'piano',
  'lilam',
  'mawng',
  'thing',
  'achin',
  'hleka',
  'mawza',
  'phian',
  'liaha',
  'chhut',
  'gaala',
  'chuti',
  'tuite',
  'vekah',
  'pisaa',
  'royte',
  'click',
  'neite',
  'nerve',
  'artui',
  'dante',
  'khami',
  'award',
  'awmin',
  'hausa',
  'vekin',
  'khasi',
  'hills',
  'mbose',
  'major',
  'tumna',
  'henry',
  'rihna',
  'pound',
  'hlauh',
  'davis',
  'ziaka',
  'mekte',
  'astro',
  'vawng',
  'velin',
  'motor',
  'leitu',
  'hmuan',
  'putar',
  'chiam',
  'lakhs',
  'thlir',
  'youth',
  'khawp',
  'north',
  'entos',
  'khang',
  'ngang',
  'khung',
  'stage',
  'zoram',
  'delhi',
  'chhui',
  'duhlo',
  'suala',
  'inbum',
  'essay',
  'thalo',
];

const List<String> wordOfTheDay = validWords;

const defaultNumGuesses = 5;

enum HitType { none, hit, partial, miss, removed }

typedef Letter = ({String char, HitType type});

String getTodayWord() {
  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
  return wordOfTheDay[dayOfYear % wordOfTheDay.length];
}

bool isValidWord(String word) {
  return validWords.contains(word.toLowerCase());
}

List<Letter> evaluateGuess(String hiddenWord, String guess) {
  final guessWord = Word.fromString(guess);
  final hiddenWordObj = Word.fromString(hiddenWord);

  final result = guessWord.evaluateGuess(hiddenWordObj);

  return result.map((l) => (char: l.char, type: l.type)).toList();
}

/// This class holds game state for a single round of Bulls and Cows,
/// and exposes methods that a UI would need to manage the game state.
///
/// On it's own, this class won't manage a game. For example, it won't
/// call [startGame] on it's own. It assumes that a client will use it's
/// methods to progress through a game.
class Game {
  Game({this.numAllowedGuesses = defaultNumGuesses, this.seed}) {
    _wordToGuess = seed == null ? Word.random() : Word.fromSeed(seed!);
    _guesses = List<Word>.filled(numAllowedGuesses, Word.empty());
  }

  late final int numAllowedGuesses;
  late List<Word> _guesses;
  late Word _wordToGuess;
  int? seed;

  Word get hiddenWord => _wordToGuess;

  UnmodifiableListView<Word> get guesses => UnmodifiableListView(_guesses);

  Word get previousGuess {
    final index = _guesses.lastIndexWhere((word) => word.isNotEmpty);
    return index == -1 ? Word.empty() : _guesses[index];
  }

  int get activeIndex {
    return _guesses.indexWhere((word) => word.isEmpty);
  }

  int get guessesRemaining {
    if (activeIndex == -1) return 0;
    return numAllowedGuesses - activeIndex;
  }

  void resetGame() {
    _wordToGuess = seed == null ? Word.random() : Word.fromSeed(seed!);
    _guesses = List.filled(numAllowedGuesses, Word.empty());
  }

  // Most common entry-point for handling guess logic.
  // For finer control over logic, use other methods such as [isGuessLegal]
  // and [matchGuess]
  Word guess(String guess) {
    final result = matchGuessOnly(guess);
    addGuessToList(result);
    return result;
  }

  bool get didWin {
    if (_guesses.first.isEmpty) return false;

    for (var letter in previousGuess) {
      if (letter.type != HitType.hit) return false;
    }

    return true;
  }

  bool get didLose => guessesRemaining == 0 && !didWin;

  // UIs can call this method before calling [guess] if they want
  // to show users messages based incorrect words
  bool isLegalGuess(String guess) {
    return Word.fromString(guess).isLegalGuess;
  }

  // Doesn't move the game forward, only executes match logic.
  Word matchGuessOnly(String guess) {
    // The hidden word will be used by subsequent guesses.
    var hiddenCopy = Word.fromString(_wordToGuess.toString());
    return Word.fromString(guess).evaluateGuess(hiddenCopy);
  }

  void addGuessToList(Word guess) {
    final i = _guesses.indexWhere((word) => word.isEmpty);
    _guesses[i] = guess;
  }
}

class Word with IterableMixin<Letter> {
  Word(this._letters);

  factory Word.empty() {
    return Word(List.filled(5, (char: '', type: HitType.none)));
  }

  factory Word.fromString(String guess) {
    var list = guess.toLowerCase().split('');
    var letters = list
        .map((String char) => (char: char, type: HitType.none))
        .toList();
    return Word(letters);
  }

  factory Word.random() {
    var rand = Random();
    var nextWord = validWords[rand.nextInt(validWords.length)];
    return Word.fromString(nextWord);
  }

  factory Word.fromSeed(int seed) {
    return Word.fromString(validWords[seed % validWords.length]);
  }

  final List<Letter> _letters;

  /// Loop over the Letters in this word
  @override
  Iterator<Letter> get iterator => _letters.iterator;

  @override
  bool get isEmpty {
    return every((letter) => letter.char.isEmpty);
  }

  @override
  bool get isNotEmpty => !isEmpty;

  Letter operator [](int i) => _letters[i];
  void operator []=(int i, Letter value) => _letters[i] = value;

  @override
  String toString() {
    return _letters.map((Letter c) => c.char).join().trim();
  }

  // Used to play game in the CLI implementation
  String toStringVerbose() {
    return _letters.map((l) => '${l.char} - ${l.type.name}').join('\n');
  }
}

// Domain specific methods that contain word related logic.
extension WordUtils on Word {
  bool get isLegalGuess {
    if (!validWords.contains(toString())) {
      return false;
    }

    return true;
  }

  /// Compares two [Word] objects and returns a new [Word] that
  /// has the same letters as the [this], but each [Letter]
  /// has new a [LetterType] of either [LetterType.hit],
  /// [LetterType.partial], or [LetterType.miss].
  Word evaluateGuess(Word other) {
    assert(isLegalGuess);

    // Find exact hits. Mark them as hits, and mark letters in the hidden word
    // as removed.
    for (var i = 0; i < length; i++) {
      if (other[i].char == this[i].char) {
        this[i] = (char: this[i].char, type: HitType.hit);
        other[i] = (char: other[i].char, type: HitType.removed);
      }
    }

    // Find the partial matches
    // The outer loop is through the hidden word
    for (var i = 0; i < other.length; i++) {
      // If a letter in the hidden word is already marked as "removed",
      // then it's already an exact match, so skip it
      Letter targetLetter = other[i];
      if (targetLetter.type != HitType.none) continue;

      // loop through the guessed word onces for each letter in the hidden word
      for (var j = 0; j < length; j++) {
        Letter guessedLetter = this[j];
        // skip letters that have already been marked as exact matches
        if (guessedLetter.type != HitType.none) continue;
        // If this letter, which must not be in the same position, is the same,
        // it's a partial match
        if (guessedLetter.char == targetLetter.char) {
          this[j] = (char: guessedLetter.char, type: HitType.partial);
          other[i] = (char: targetLetter.char, type: HitType.removed);
          break;
        }
      }
    }

    // Mark remaining letters in guessed word as misses
    for (var i = 0; i < length; i++) {
      if (this[i].type == HitType.none) {
        this[i] = (char: this[i].char, type: HitType.miss);
      }
    }

    return this;
  }
}
