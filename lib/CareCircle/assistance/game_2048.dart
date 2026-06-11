// ignore_for_file: curly_braces_in_flow_control_structures, unused_local_variable

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Game2048 extends StatefulWidget {
  const Game2048({super.key});
  @override
  State<Game2048> createState() => _Game2048State();
}

class _Game2048State extends State<Game2048> {
  static const int size = 4;
  final _rng = Random();
  late List<List<int>> grid;
  int score = 0;
  int best = 0;
  bool animLock = false;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    grid = List.generate(size, (_) => List.filled(size, 0));
    score = 0;
    _spawn();
    _spawn();
    setState(() {});
  }

  void _spawn() {
    final empties = <Point<int>>[];
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid[r][c] == 0) empties.add(Point(r, c));
      }
    }
    if (empties.isEmpty) return;
    final p = empties[_rng.nextInt(empties.length)];
    grid[p.x][p.y] = _rng.nextDouble() < 0.9 ? 2 : 4;
  }

  // slide + merge a single row to the left, return (newRow, gainedScore, changed?)
  (List<int>, int, bool) _slideAndCombineRow(List<int> row) {
    final compact = row.where((v) => v != 0).toList();
    final out = <int>[];
    int gained = 0;
    int i = 0;
    while (i < compact.length) {
      if (i + 1 < compact.length && compact[i] == compact[i + 1]) {
        final m = compact[i] * 2;
        out.add(m);
        gained += m;
        i += 2;
      } else {
        out.add(compact[i]);
        i++;
      }
    }
    while (out.length < size) out.add(0);
    final changed = ListEquality.equals(out, row) == false;
    return (out, gained, changed);
  }

  // generic move by rotating the board to reuse "move left"
  bool _moveLeft() {
    bool changed = false;
    int gained = 0;
    final newGrid = List<List<int>>.generate(size, (_) => List.filled(size, 0));
    for (int r = 0; r < size; r++) {
      final res = _slideAndCombineRow(grid[r]);
      newGrid[r] = res.$1;
      gained += res.$2;
      changed = changed || res.$3;
    }
    if (changed) {
      grid = newGrid;
      score += gained;
      best = max(best, score);
      _spawn();
    }
    return changed;
  }

  List<List<int>> _rotateCW(List<List<int>> g) {
    final out = List.generate(size, (_) => List.filled(size, 0));
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        out[c][size - 1 - r] = g[r][c];
      }
    }
    return out;
  }

  bool _moveUp() {
    grid = _rotateCW(grid); // left <- up
    grid = _rotateCW(grid); // two rotations equals 180? wait, we need to map up to left:
    grid = _rotateCW(grid); // Actually: up = rotate CCW once. CCW = CW x3.
    final changed = _moveLeft();
    grid = _rotateCW(grid); // rotate back CW once
    return changed;
  }

  bool _moveDown() {
    grid = _rotateCW(grid); // down = rotate CW once -> left
    final changed = _moveLeft();
    grid = _rotateCW(grid); // back
    grid = _rotateCW(grid);
    grid = _rotateCW(grid);
    return changed;
  }

  bool _moveRight() {
    grid = _rotateCW(grid); // right = 180 rotate -> left
    grid = _rotateCW(grid);
    final changed = _moveLeft();
    grid = _rotateCW(grid);
    grid = _rotateCW(grid);
    return changed;
  }

  bool _canMove() {
    // has empty?
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid[r][c] == 0) return true;
      }
    }
    // or adjacent equals?
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final v = grid[r][c];
        if (r + 1 < size && grid[r + 1][c] == v) return true;
        if (c + 1 < size && grid[r][c + 1] == v) return true;
      }
    }
    return false;
  }

  void _handleSwipe(DragEndDetails d, Offset velocity, Offset totalDelta) {
    if (animLock) return;
    final dx = totalDelta.dx.abs();
    final dy = totalDelta.dy.abs();
    if (dx < 8 && dy < 8) return;

    bool moved = false;
    setState(() {
      if (dx > dy) {
        moved = totalDelta.dx > 0 ? _moveRight() : _moveLeft();
      } else {
        moved = totalDelta.dy > 0 ? _moveDown() : _moveUp();
      }
    });

    if (moved && !_canMove()) {
      _showGameOver();
    } else if (!moved && !_canMove()) {
      _showGameOver();
    }
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Score: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(_newGame);
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Offset dragStart = Offset.zero;
    Offset dragDelta = Offset.zero;

    return Scaffold(
      backgroundColor: const Color(0xFF121524),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Container(
          width: 25.w,
          height: 25.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFDF3DD), // background color
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            tooltip: 'Back',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.cancel_outlined, color: Colors.black),
          ),
        ),
        // title: Text(
        //   'Flutter 2048',
        //   style: TextStyle(color: cs.onBackground, fontWeight: FontWeight.w700),
        // ),
        actions: [
          _hudTile('Score', '$score'),
          const SizedBox(width: 8),
          _hudTile('Best', '$best'),
          IconButton(
            tooltip: 'Restart',
            onPressed: () => setState(_newGame),
            icon: Icon(Icons.restart_alt, color: Colors.white),
          ),
          // const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (_, c) {
                final w = c.maxWidth;
                final gap = w * .02;
                final cell = (w - gap * 5) / 4; // 4 cells + 5 gaps (outer + inner)

                return GestureDetector(
                  onPanStart: (d) => dragStart = d.localPosition,
                  onPanUpdate: (d) => dragDelta = d.localPosition - dragStart,
                  onPanEnd: (d) => _handleSwipe(d, d.velocity.pixelsPerSecond, dragDelta),
                  child: Container(
                    padding: EdgeInsets.all(gap),
                    decoration: BoxDecoration(color: const Color(0xFF1A1E35), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: List.generate(size, (r) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: r == size - 1 ? 0 : gap),
                          child: Row(
                            children: List.generate(size, (cIdx) {
                              final v = grid[r][cIdx];
                              return Padding(
                                padding: EdgeInsets.only(right: cIdx == size - 1 ? 0 : gap),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 120),
                                  width: cell,
                                  height: cell,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: _tileColor(v), borderRadius: BorderRadius.circular(10)),
                                  child: Text(
                                    v == 0 ? '' : '$v',
                                    style: TextStyle(
                                      color: v <= 4 ? const Color(0xFF444B63) : Colors.white,
                                      fontSize: v < 100
                                          ? 28
                                          : v < 1000
                                          ? 24
                                          : 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Wrap(
          spacing: 10,
          children: [
            _btn(Icons.keyboard_arrow_up, _moveUp),
            _btn(Icons.keyboard_arrow_left, _moveLeft),
            _btn(Icons.keyboard_arrow_down, _moveDown),
            _btn(Icons.keyboard_arrow_right, _moveRight),
          ],
        ),
      ),
    );
  }

  Widget _btn(IconData icon, bool Function() action) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          final moved = action();
          if (!_canMove()) _showGameOver();
          if (!moved && !_canMove()) _showGameOver();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white10,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Icon(icon),
    );
  }

  Widget _hudTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Color _tileColor(int v) {
    switch (v) {
      case 0:
        return const Color(0xFF232947);
      case 2:
        return const Color(0xFFE5E7FB);
      case 4:
        return const Color(0xFFC9CEF7);
      case 8:
        return const Color(0xFFFFA55B);
      case 16:
        return const Color(0xFFFF8F5B);
      case 32:
        return const Color(0xFFFF6E5B);
      case 64:
        return const Color(0xFFFF5B5B);
      case 128:
        return const Color(0xFFEDCF72);
      case 256:
        return const Color(0xFFE4C75E);
      case 512:
        return const Color(0xFFD5BA3F);
      case 1024:
        return const Color(0xFFB59E2D);
      case 2048:
        return const Color(0xFFAF8B1C);
      default:
        return const Color(0xFF8C7A1C);
    }
  }
}

/// Simple list equality helper (no extra packages)
class ListEquality {
  static bool equals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
