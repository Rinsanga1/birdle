import 'package:flutter/material.dart';
import 'api_service.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Align(alignment: Alignment.center, child: Text("Zodle")),
        ),
        body: Center(child: GamePage(baseUrl: 'http://localhost:3000')),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  final String baseUrl;

  const GamePage({super.key, required this.baseUrl});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late ApiService _apiService;
  String? _hiddenWord;
  List<List<Letter>> _guesses = [];
  bool _isLoading = true;
  String? _error;
  final int _maxGuesses = 6;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(baseUrl: widget.baseUrl);
    _initGame();
  }

  Future<void> _initGame() async {
    try {
      final todayWord = await _apiService.getTodayWord();
      setState(() {
        _hiddenWord = todayWord.word;
        _guesses = List.generate(_maxGuesses, (_) => []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _onSubmitGuess(String guess) async {
    if (_hiddenWord == null) return;

    try {
      final isValid = await _apiService.validateGuess(guess);
      if (!isValid) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Not a valid word')));
        }
        return;
      }

      final letters = await _apiService.evaluateGuess(_hiddenWord!, guess);

      setState(() {
        final emptyIndex = _guesses.indexWhere((g) => g.isEmpty);
        if (emptyIndex != -1) {
          _guesses[emptyIndex] = letters;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
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
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    if (_error != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: $_error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _initGame();
            },
            child: const Text('Retry'),
          ),
        ],
      );
    }

    return Padding(
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
              child: Text('🎉 You won!', style: TextStyle(fontSize: 24)),
            ),
          if (_didLose)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Game over!', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _resetGame,
                    child: const Text('Play Again'),
                  ),
                ],
              ),
            ),
          if (!_didWin && !_didLose) GuessInput(onSubmitGuess: _onSubmitGuess),
        ],
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.bounceIn,
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        color: switch (hitType) {
          HitType.hit => Colors.green,
          HitType.partial => Colors.yellow,
          HitType.miss => Colors.grey,
          HitType.none => Colors.white,
        },
      ),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

class GuessInput extends StatelessWidget {
  final Future<void> Function(String) onSubmitGuess;

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
