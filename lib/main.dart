import 'package:flutter/material.dart';
import 'game.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _isDarkMode = false;

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D0D0D),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(color: Color(0xFF1A1A1A)),
        dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1A1A1A)),
      ),
      home: HomeScreen(
        isDarkMode: _isDarkMode,
        onToggleDarkMode: _toggleDarkMode,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Zodle"),
            Text(
              "Daily Mizo Thu Puzzle Guessing Game",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: isDarkMode ? Colors.grey.shade400 : null,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const HelpDialog(),
            ),
          ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: onToggleDarkMode,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Choose Mode',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WordOfTheDayPage(
                          isDarkMode: isDarkMode,
                          onToggleDarkMode: onToggleDarkMode,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Word of the Day',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EndlessModePage(
                          isDarkMode: isDarkMode,
                          onToggleDarkMode: onToggleDarkMode,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Endless Mode',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WordOfTheDayPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;

  const WordOfTheDayPage({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
  });

  @override
  State<WordOfTheDayPage> createState() => _WordOfTheDayPageState();
}

class _WordOfTheDayPageState extends State<WordOfTheDayPage> {
  String? _hiddenWord;
  List<List<Letter>> _guesses = [];
  bool _isLoading = true;
  final int _maxGuesses = 6;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    final todayWord = getTodayWord();
    setState(() {
      _hiddenWord = todayWord;
      _guesses = List.generate(_maxGuesses, (_) => []);
      _isLoading = false;
    });
  }

  void _onSubmitGuess(String guess) {
    if (_hiddenWord == null) return;

    if (!isValidWord(guess)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Not a valid word')));
      return;
    }

    final letters = evaluateGuess(_hiddenWord!, guess);

    setState(() {
      final emptyIndex = _guesses.indexWhere((g) => g.isEmpty);
      if (emptyIndex != -1) {
        _guesses[emptyIndex] = letters;
      }
    });
  }

  bool get _hasMadeAllGuesses {
    return _guesses.isNotEmpty && _guesses.every((g) => g.isNotEmpty);
  }

  bool get _didWin {
    if (_guesses.isEmpty) return false;
    final lastGuess = _guesses.lastWhere((g) => g.isNotEmpty, orElse: () => []);
    if (lastGuess.isEmpty) return false;
    return lastGuess.every((l) => l.type == HitType.hit);
  }

  bool get _didLose {
    return _hasMadeAllGuesses && !_didWin;
  }

  void _resetGame() {
    setState(() {
      _guesses = List.generate(_maxGuesses, (_) => []);
      _isLoading = true;
    });
    _initGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Word of the Day"),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleDarkMode,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  for (var guess in _guesses)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < 5; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2.5,
                              vertical: 2.5,
                            ),
                            child: Tile(
                              i < guess.length ? guess[i].char : '',
                              i < guess.length ? guess[i].type : HitType.none,
                            ),
                          ),
                      ],
                    ),
                  if (_didWin)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('You won!', style: TextStyle(fontSize: 24)),
                    ),
                  if (_didLose)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Game over!',
                            style: TextStyle(fontSize: 24),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _resetGame,
                            child: const Text('Play Again'),
                          ),
                        ],
                      ),
                    ),
                  if (!_didWin && !_didLose)
                    GuessInput(onSubmitGuess: _onSubmitGuess),
                ],
              ),
            ),
    );
  }
}

class EndlessModePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;

  const EndlessModePage({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
  });

  @override
  State<EndlessModePage> createState() => _EndlessModePageState();
}

class _EndlessModePageState extends State<EndlessModePage> {
  String? _hiddenWord;
  List<List<Letter>> _guesses = [];
  bool _isLoading = true;
  final int _maxGuesses = 6;

  int _gamesPlayed = 0;
  int _wins = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    final game = Game();
    setState(() {
      _hiddenWord = game.hiddenWord.toString();
      _guesses = List.generate(_maxGuesses, (_) => []);
      _isLoading = false;
      _gamesPlayed++;
    });
  }

  void _onSubmitGuess(String guess) {
    if (_hiddenWord == null) return;

    if (!isValidWord(guess)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Not a valid word')));
      return;
    }

    final letters = evaluateGuess(_hiddenWord!, guess);

    setState(() {
      final emptyIndex = _guesses.indexWhere((g) => g.isEmpty);
      if (emptyIndex != -1) {
        _guesses[emptyIndex] = letters;
      }
    });
  }

  bool get _hasMadeAllGuesses {
    return _guesses.isNotEmpty && _guesses.every((g) => g.isNotEmpty);
  }

  bool get _didWin {
    if (_guesses.isEmpty) return false;
    final lastGuess = _guesses.lastWhere((g) => g.isNotEmpty, orElse: () => []);
    if (lastGuess.isEmpty) return false;
    return lastGuess.every((l) => l.type == HitType.hit);
  }

  bool get _didLose {
    return _hasMadeAllGuesses && !_didWin;
  }

  void _onSkip() {
    _guesses = List.generate(_maxGuesses, (_) => []);
    _isLoading = true;
    _initGame();
  }

  void _onWin() {
    setState(() {
      _wins++;
      _currentStreak++;
      if (_currentStreak > _bestStreak) {
        _bestStreak = _currentStreak;
      }
    });
  }

  void _onLoss() {
    setState(() {
      _currentStreak = 0;
    });
  }

  void _nextGame() {
    setState(() {
      _guesses = List.generate(_maxGuesses, (_) => []);
      _isLoading = true;
    });
    _initGame();
  }

  void _retryGame() {
    setState(() {
      _guesses = List.generate(_maxGuesses, (_) => []);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_didWin) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onWin());
    } else if (_didLose) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onLoss());
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Endless Mode"),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleDarkMode,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _buildStatsBar(),
                  const SizedBox(height: 8),
                  for (var guess in _guesses)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < 5; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2.5,
                              vertical: 2.5,
                            ),
                            child: Tile(
                              i < guess.length ? guess[i].char : '',
                              i < guess.length ? guess[i].type : HitType.none,
                            ),
                          ),
                      ],
                    ),
                  if (_didWin)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'You won!',
                            style: TextStyle(fontSize: 24),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _nextGame,
                            child: const Text('Next Word'),
                          ),
                        ],
                      ),
                    ),
                  if (_didLose)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Game over!',
                            style: TextStyle(fontSize: 24),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _retryGame,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  if (!_didWin && !_didLose)
                    Column(
                      children: [
                        GuessInput(onSubmitGuess: _onSubmitGuess),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _onSkip,
                          child: const Text('Skip'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Played', '$_gamesPlayed', isDark),
          _statItem('Wins', '$_wins', isDark),
          _statItem('Streak', '$_currentStreak', isDark),
          _statItem('Best', '$_bestStreak', isDark),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : null,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : null,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'How To Play',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Guess the Zodle in 6 tries.\n'
                'Each guess must be a valid 5-letter word.\n'
                'The color of the tiles will change to show how close your guess was to the word.',
                style: TextStyle(color: isDark ? Colors.white : null),
              ),
              const SizedBox(height: 16),
              Text(
                'Examples',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : null,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _exampleTile('A', HitType.none, isDark),
                  _exampleTile('N', HitType.hit, isDark),
                  _exampleTile('I', HitType.none, isDark),
                  _exampleTile('M', HitType.none, isDark),
                  _exampleTile('O', HitType.none, isDark),
                ],
              ),
              Text(
                'N is in the word and in the correct spot.',
                style: TextStyle(color: isDark ? Colors.white : null),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _exampleTile('A', HitType.none, isDark),
                  _exampleTile('N', HitType.none, isDark),
                  _exampleTile('I', HitType.partial, isDark),
                  _exampleTile('M', HitType.none, isDark),
                  _exampleTile('O', HitType.none, isDark),
                ],
              ),
              Text(
                'I is in the word but in the wrong spot.',
                style: TextStyle(color: isDark ? Colors.white : null),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _exampleTile('A', HitType.none, isDark),
                  _exampleTile('N', HitType.none, isDark),
                  _exampleTile('I', HitType.none, isDark),
                  _exampleTile('M', HitType.miss, isDark),
                  _exampleTile('O', HitType.none, isDark),
                ],
              ),
              Text(
                'M is not in the word in any spot.',
                style: TextStyle(color: isDark ? Colors.white : null),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 150,
                  child: Container(
                    height: 2,
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'A new puzzle is released daily at midnight.',
                style: TextStyle(color: isDark ? Colors.white : null),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Got it!'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _exampleTile(String letter, HitType hitType, bool isDark) {
    final hasLetter = letter.isNotEmpty;
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        border: Border.all(
          color: switch (hitType) {
            HitType.hit => const Color(0xFF27a644),
            HitType.partial => const Color(0xFFf0bf00),
            HitType.miss =>
              isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            HitType.none =>
              isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            HitType.removed =>
              isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          },
          width: 2,
        ),
        color: !hasLetter
            ? Colors.transparent
            : (switch (hitType) {
                HitType.hit => const Color(0xFF27a644),
                HitType.partial => const Color(0xFFf0bf00),
                HitType.miss =>
                  isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                HitType.none =>
                  isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                HitType.removed =>
                  isDark ? Colors.grey.shade700 : Colors.grey.shade400,
              }),
      ),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: !hasLetter
                ? Colors.transparent
                : (hitType == HitType.hit || hitType == HitType.partial
                      ? (hitType == HitType.hit ? Colors.white : Colors.black)
                      : (isDark ? Colors.white : Colors.black)),
          ),
        ),
      ),
    );
  }
}

class Tile extends StatelessWidget {
  final String letter;
  final HitType hitType;

  const Tile(this.letter, this.hitType, {super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasLetter = letter.isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.bounceIn,
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(
          color: switch (hitType) {
            HitType.hit => const Color(0xFF27a644),
            HitType.partial => const Color(0xFFf0bf00),
            HitType.miss =>
              isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            HitType.none =>
              isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            HitType.removed =>
              isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          },
          width: 2,
        ),
        color: !hasLetter
            ? Colors.transparent
            : (switch (hitType) {
                HitType.hit => const Color(0xFF27a644),
                HitType.partial => const Color(0xFFf0bf00),
                HitType.miss =>
                  isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                HitType.none =>
                  isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                HitType.removed =>
                  isDark ? Colors.grey.shade700 : Colors.grey.shade400,
              }),
      ),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: !hasLetter
                ? Colors.transparent
                : (hitType == HitType.hit || hitType == HitType.partial
                      ? (hitType == HitType.hit ? Colors.white : Colors.black)
                      : (isDark ? Colors.white : Colors.black)),
          ),
        ),
      ),
    );
  }
}

class GuessInput extends StatelessWidget {
  final void Function(String) onSubmitGuess;

  GuessInput({super.key, required this.onSubmitGuess});

  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _onSubmit(BuildContext context) {
    final text = _textEditingController.text.trim();
    if (text.length != 5) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Guess must be 5 letters')));
      return;
    }
    onSubmitGuess(text);
    _textEditingController.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              maxLength: 5,
              controller: _textEditingController,
              focusNode: _focusNode,
              autofocus: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(35),
                ),
                counterText: '',
              ),
              onSubmitted: (_) => _onSubmit(context),
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_circle_up),
          onPressed: () => _onSubmit(context),
        ),
      ],
    );
  }
}
