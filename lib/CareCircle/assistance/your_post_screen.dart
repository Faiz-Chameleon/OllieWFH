// ignore_for_file: use_full_hex_values_for_flutter_colors, avoid_unnecessary_containers, avoid_print

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ollie/Auth/login/user_controller.dart';
import 'package:ollie/CareCircle/assistance/game_font.dart'; // uses TicGlyph(mark: , size: )

class YourPostsScreen extends StatefulWidget {
  const YourPostsScreen({super.key});

  @override
  State<YourPostsScreen> createState() => _YourPostsScreenState();
}

class _YourPostsScreenState extends State<YourPostsScreen> {
  final UserController userController = Get.find<UserController>();

  // --- Game Modes & Config ---
  final List<String> gameModes = ['Easy', 'Medium', 'Hard', '2 Players'];
  String selectedMode = 'Medium';
  bool vsAI = true; // false for 2 Players
  String difficulty = 'medium'; // 'easy' | 'medium' | 'hard'
  bool randomizeStarter = true; // if true, O/X starter random each round

  // --- Marks ---
  static const String human = 'X';
  static const String ai = 'O';

  // --- Game state ---
  bool oTurn = false; // false => X to move, true => O to move
  List<String> displayElement = List.filled(9, '');
  int oScore = 0;
  int xScore = 0;
  int filledBoxes = 0;
  bool gameOver = false;
  bool aiThinking = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Start with a fresh board & possibly let AI start if randomizer says so.
    _clearBoard(); // also triggers AI opening if needed
  }

  @override
  Widget build(BuildContext context) {
    final youName = userController.user.value?.firstName ?? "You";
    final opponentLabel = vsAI ? 'Bot' : 'Player O';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF2D6),
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            tooltip: 'Game Settings',
            onPressed: _showModeDialog,
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Container(
            width: 25.w,
            height: 25.h,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            child: IconButton(
              padding: EdgeInsets.zero,
              tooltip: 'Back',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.cancel_outlined, color: Colors.black),
            ),
          ),
        ),
        elevation: 0,
      ),

      body: Column(
        children: <Widget>[
          // --- Scoreboard ---
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12, right: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _ScoreBlock(title: youName, score: xScore),
                SizedBox(width: 16.w),
                _ScoreBlock(title: opponentLabel, score: oScore),
              ],
            ),
          ),

          // --- Mode Selector ---
          // Padding(
          //   padding: const EdgeInsets.only(top: 8, left: 12, right: 12),
          //   child: Wrap(
          //     spacing: 10,
          //     children: gameModes.map((mode) {
          //       final isSelected = selectedMode == mode;
          //       return ChoiceChip(
          //         label: Text(mode),
          //         selected: isSelected,
          //         onSelected: (_) {
          //           setState(() {
          //             selectedMode = mode;
          //             if (mode == '2 Players') {
          //               vsAI = false;
          //             } else {
          //               vsAI = true;
          //               difficulty = mode.toLowerCase();
          //             }
          //             _clearBoard();
          //           });
          //         },
          //       );
          //     }).toList(),
          //   ),
          // ),

          // --- Who's turn indicator ---
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              gameOver ? 'Game Over' : 'Turn: ${oTurn ? 'O' : 'X'}${aiThinking ? ' (AI thinking...)' : ''}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),

          // --- Board ---
          Expanded(
            flex: 4,
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
              itemCount: 9,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemBuilder: (BuildContext context, int index) {
                final disabled = gameOver || (_isAITurn() && vsAI) || displayElement[index].isNotEmpty;
                return GestureDetector(
                  onTap: disabled ? null : () => _tapped(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E1020),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Center(child: TicGlyph(mark: displayElement[index], size: 56)),
                  ),
                );
              },
            ),
          ),

          // --- Actions ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clearBoard,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                    child: const Text('New Round'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearScoreBoard,
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
                    child: const Text('Reset Scores'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Future<void> _showModeDialog() async {
    String tempMode = selectedMode; // local selection
    bool tempRandomize = randomizeStarter; // local toggle

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text('Choose Game Mode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: gameModes.map((mode) {
                  final isSelected = tempMode == mode;
                  return ChoiceChip(label: Text(mode), selected: isSelected, onSelected: (_) => setState(() => tempMode = mode));
                }).toList(),
              ),
              const SizedBox(height: 12),
              // SwitchListTile(
              //   contentPadding: EdgeInsets.zero,
              //   title: const Text('Randomize starter (X/O)'),
              //   value: tempRandomize,
              //   onChanged: (v) => setState(() => tempRandomize = v),
              // ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // cancel = keep current settings
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _applyMode(tempMode);
                  randomizeStarter = tempRandomize;
                });
                Navigator.of(context).pop();
                _clearBoard(); // start fresh with chosen settings
              },
              child: const Text('Start Game'),
            ),
          ],
        );
      },
    );
  }

  void _applyMode(String mode) {
    selectedMode = mode;
    if (mode == '2 Players') {
      vsAI = false;
      // difficulty ignored in 2P
    } else {
      vsAI = true;
      difficulty = mode.toLowerCase(); // 'easy' | 'medium' | 'hard'
    }
  }

  // ===================== GAMEPLAY =====================

  void _tapped(int index) {
    if (gameOver || displayElement[index].isNotEmpty) return;

    setState(() {
      displayElement[index] = oTurn ? 'O' : 'X';
      filledBoxes++;
      oTurn = !oTurn;
    });

    _checkWinnerOrAI();
  }

  void _checkWinnerOrAI() {
    final winner = _winner(displayElement);
    if (winner != null) {
      _finish(winner);
      return;
    }
    if (filledBoxes == 9) {
      _showDrawDialog();
      return;
    }

    // If it's AI's turn, make a move with a short delay
    if (vsAI && _isAITurn() && !gameOver) {
      aiThinking = true;
      Future.delayed(const Duration(milliseconds: 300), _computerMove);
    }
  }

  bool _isAITurn() => (oTurn && ai == 'O') || (!oTurn && ai == 'X');

  void _computerMove() {
    if (gameOver) return;

    final move = _bestMove();
    if (move != null && displayElement[move].isEmpty) {
      setState(() {
        displayElement[move] = ai;
        filledBoxes++;
        oTurn = !oTurn;
      });
    }
    aiThinking = false;

    final winner = _winner(displayElement);
    if (winner != null) {
      _finish(winner);
    } else if (filledBoxes == 9) {
      _showDrawDialog();
    }
  }

  // ===================== AI MODES =====================

  int? _bestMove() {
    if (!vsAI) return null; // 2 Players
    switch (difficulty) {
      case 'easy':
        return _easyMove();
      case 'medium':
        return _mediumMove();
      case 'hard':
      default:
        return _minimaxBestMove();
    }
  }

  int? _easyMove() {
    // 50% chance: take an immediate win if available; else random move
    final win = _findImmediateWin(ai);
    if (win != null && _random.nextDouble() < 0.5) return win;

    final empties = _availableMoves()..shuffle(_random);
    return empties.isNotEmpty ? empties.first : null;
  }

  int? _mediumMove() {
    // 1) Win if possible
    final w = _findImmediateWin(ai);
    if (w != null) return w;

    // 2) Block opponent
    final b = _findImmediateWin(human);
    if (b != null) return b;

    // 3) Small "mistake" chance so it's beatable
    if (_random.nextDouble() < 0.2) {
      final rnd = _availableMoves()..shuffle(_random);
      return rnd.isNotEmpty ? rnd.first : null;
    }

    // 4) Center
    if (displayElement[4].isEmpty) return 4;

    // 5) Corners
    final corners = [0, 2, 6, 8].where((i) => displayElement[i].isEmpty).toList();
    if (corners.isNotEmpty) return corners[_random.nextInt(corners.length)];

    // 6) Sides
    final sides = [1, 3, 5, 7].where((i) => displayElement[i].isEmpty).toList();
    if (sides.isNotEmpty) return sides[_random.nextInt(sides.length)];

    return null;
  }

  int? _minimaxBestMove() {
    int bestScore = -1000;
    int? move;
    for (final index in _availableMoves()) {
      displayElement[index] = ai;
      final score = _minimax(displayElement, 0, false);
      displayElement[index] = '';
      if (score > bestScore) {
        bestScore = score;
        move = index;
      }
    }
    return move;
  }

  int? _findImmediateWin(String player) {
    for (final i in _availableMoves()) {
      displayElement[i] = player;
      final win = _winner(displayElement) == player;
      displayElement[i] = '';
      if (win) return i;
    }
    return null;
  }

  int _minimax(List<String> board, int depth, bool isMaximizing) {
    final result = _winner(board);
    if (result != null) {
      if (result == ai) return 10 - depth;
      if (result == human) return depth - 10;
    }
    if (!_hasMoves(board)) return 0;

    if (isMaximizing) {
      int bestScore = -1000;
      for (final index in _availableMoves(board: board)) {
        board[index] = ai;
        final score = _minimax(board, depth + 1, false);
        board[index] = '';
        bestScore = max(bestScore, score);
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (final index in _availableMoves(board: board)) {
        board[index] = human;
        final score = _minimax(board, depth + 1, true);
        board[index] = '';
        bestScore = min(bestScore, score);
      }
      return bestScore;
    }
  }

  bool _hasMoves(List<String> board) => board.contains('');

  List<int> _availableMoves({List<String>? board}) {
    final source = board ?? displayElement;
    final moves = <int>[];
    for (int i = 0; i < source.length; i++) {
      if (source[i].isEmpty) moves.add(i);
    }
    return moves;
  }

  String? _winner(List<String> b) {
    const lines = <List<int>>[
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (final l in lines) {
      if (b[l[0]].isNotEmpty && b[l[0]] == b[l[1]] && b[l[1]] == b[l[2]]) {
        return b[l[0]]; // "X" or "O"
      }
    }
    return null;
  }

  void _finish(String winner) {
    gameOver = true;
    _showWinDialog(winner);
    if (winner == 'O') {
      oScore++;
    } else if (winner == 'X') {
      xScore++;
    }
  }

  // ===================== DIALOGS =====================

  void _showWinDialog(String winner) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('" $winner " is Winner!!!'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Play Again"),
              onPressed: () {
                _clearBoard();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDrawDialog() {
    gameOver = true;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Draw"),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                _clearBoard();
                Navigator.of(context).pop();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  // ===================== RESET =====================

  void _clearBoard() {
    setState(() {
      for (int i = 0; i < 9; i++) {
        displayElement[i] = '';
      }
      filledBoxes = 0;
      gameOver = false;
      // Decide who starts (false => X; true => O)
      oTurn = randomizeStarter ? _random.nextBool() : false;
    });

    // If AI (O) starts and it's AI's turn, let AI make the opening move
    if (vsAI && _isAITurn() && !gameOver) {
      aiThinking = true;
      Future.delayed(const Duration(milliseconds: 250), _computerMove);
    }
  }

  void _clearScoreBoard() {
    setState(() {
      xScore = 0;
      oScore = 0;
    });
    _clearBoard();
  }
}

// -------------------- UI Helpers --------------------

class _ScoreBlock extends StatelessWidget {
  const _ScoreBlock({required this.title, required this.score});

  final String title;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 6),
          Text(score.toString(), style: const TextStyle(fontSize: 18, color: Colors.black)),
        ],
      ),
    );
  }
}
