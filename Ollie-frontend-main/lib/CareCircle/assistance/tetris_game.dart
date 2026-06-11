// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// --- Game constants ---
// --- Game constants ---
const int cols = 10;
const int rows = 20;
const double aspect = cols / rows;

// Tetromino IDs
enum T { I, O, t, S, Z, J, L }

// Color palette
const Map<T, Color> tColors = {
  T.I: Color(0xFF00BCD4),
  T.O: Color(0xFFFFC107),
  T.t: Color(0xFF9C27B0),
  T.S: Color(0xFF4CAF50),
  T.Z: Color(0xFFF44336),
  T.J: Color(0xFF3F51B5),
  T.L: Color(0xFFFF9800),
};

// Shapes: for each T piece, its 4 rotation states as lists of (x,y) block offsets
final Map<T, List<List<Point<int>>>> shapes = {
  T.I: [
    [p(-1, 0), p(0, 0), p(1, 0), p(2, 0)],
    [p(1, -1), p(1, 0), p(1, 1), p(1, 2)],
    [p(-1, 1), p(0, 1), p(1, 1), p(2, 1)],
    [p(0, -1), p(0, 0), p(0, 1), p(0, 2)],
  ],
  T.O: [
    [p(0, 0), p(1, 0), p(0, 1), p(1, 1)],
    [p(0, 0), p(1, 0), p(0, 1), p(1, 1)],
    [p(0, 0), p(1, 0), p(0, 1), p(1, 1)],
    [p(0, 0), p(1, 0), p(0, 1), p(1, 1)],
  ],
  T.t: [
    [p(-1, 0), p(0, 0), p(1, 0), p(0, 1)],
    [p(0, -1), p(0, 0), p(1, 0), p(0, 1)],
    [p(0, -1), p(-1, 0), p(0, 0), p(1, 0)],
    [p(0, -1), p(-1, 0), p(0, 0), p(0, 1)],
  ],
  T.S: [
    [p(0, 0), p(1, 0), p(-1, 1), p(0, 1)],
    [p(0, -1), p(0, 0), p(1, 0), p(1, 1)],
    [p(0, 0), p(1, 0), p(-1, 1), p(0, 1)],
    [p(0, -1), p(0, 0), p(1, 0), p(1, 1)],
  ],
  T.Z: [
    [p(-1, 0), p(0, 0), p(0, 1), p(1, 1)],
    [p(1, -1), p(1, 0), p(0, 0), p(0, 1)],
    [p(-1, 0), p(0, 0), p(0, 1), p(1, 1)],
    [p(1, -1), p(1, 0), p(0, 0), p(0, 1)],
  ],
  T.J: [
    [p(-1, 0), p(-1, 1), p(0, 0), p(1, 0)],
    [p(0, -1), p(0, 0), p(0, 1), p(1, 1)],
    [p(-1, 0), p(0, 0), p(1, 0), p(1, -1)],
    [p(-1, -1), p(0, -1), p(0, 0), p(0, 1)],
  ],
  T.L: [
    [p(-1, 0), p(0, 0), p(1, 0), p(1, 1)],
    [p(0, -1), p(0, 0), p(0, 1), p(1, -1)],
    [p(-1, -1), p(-1, 0), p(0, 0), p(1, 0)],
    [p(-1, 1), p(0, -1), p(0, 0), p(0, 1)],
  ],
};

Point<int> p(int x, int y) => Point(x, y);

// --- Game widget ---
class TetrisGame extends StatefulWidget {
  const TetrisGame({super.key});
  @override
  State<TetrisGame> createState() => _TetrisGameState();
}

class _TetrisGameState extends State<TetrisGame> with TickerProviderStateMixin {
  late List<List<T?>> board; // rows x cols, null = empty
  late Timer _timer;
  bool running = false;
  bool paused = false;

  // piece state
  T? curType;
  int curRot = 0;
  int curX = cols ~/ 2; // piece origin X (grid coords)
  int curY = 0; // origin Y
  final _rng = Random();

  // next & hold
  final List<T> bag = [];
  final List<T> queue = [];
  T? hold;
  bool canHold = true;

  // score
  int score = 0;
  int level = 1;
  int lines = 0;

  // speeds (ms)
  int get tickMs => max(80, 800 - (level - 1) * 60);

  @override
  void initState() {
    super.initState();
    _resetBoard();
    _fillQueue();
    _spawn();
    _start();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _resetBoard() {
    board = List.generate(rows, (_) => List<T?>.filled(cols, null));
    score = 0;
    lines = 0;
    level = 1;
    hold = null;
    canHold = true;
    queue.clear();
    bag.clear();
  }

  void _start() {
    running = true;
    paused = false;
    _timer = Timer.periodic(Duration(milliseconds: tickMs), _tick);
  }

  void _pause() {
    setState(() => paused = !paused);
  }

  void _restart() {
    setState(() {
      _timer.cancel();
      _resetBoard();
      _fillQueue();
      _spawn();
      _start();
    });
  }

  void _tick(Timer t) {
    if (!mounted) return;
    if (paused || !running) return;

    setState(() {
      if (!_move(0, 1)) {
        _lockPiece();
        _clearLines();
        canHold = true;
        if (!_spawn()) {
          running = false;
          paused = true;
          _showGameOver();
        }
      }
    });
  }

  // --- Piece mechanics ---
  void _fillQueue() {
    while (queue.length < 5) {
      if (bag.isEmpty) {
        // 7-bag randomizer
        final all = T.values.toList()..shuffle(_rng);
        bag.addAll(all);
      }
      queue.add(bag.removeAt(0));
    }
  }

  bool _spawn() {
    _fillQueue();
    curType = queue.removeAt(0);
    curRot = 0;
    curX = cols ~/ 2;
    curY = 0;

    // spawn above the board slightly
    if (!_valid(curX, curY, curRot)) {
      // try nudge
      if (!_valid(curX - 1, curY, curRot) && !_valid(curX + 1, curY, curRot)) {
        return false;
      }
    }
    return true;
  }

  bool _valid(int ox, int oy, int rot) {
    final shape = shapes[curType]![rot];
    for (final b in shape) {
      final x = ox + b.x;
      final y = oy + b.y;
      if (x < 0 || x >= cols || y < 0 || y >= rows) return false;
      if (board[y][x] != null) return false;
    }
    return true;
  }

  bool _move(int dx, int dy) {
    final nx = curX + dx;
    final ny = curY + dy;
    if (_valid(nx, ny, curRot)) {
      curX = nx;
      curY = ny;
      return true;
    }
    return false;
  }

  void _hardDrop() {
    int drop = 0;
    while (_move(0, 1)) {
      drop++;
    }
    // scoring: 2 per cell dropped (guideline-ish)
    score += drop * 2;
    _lockPiece();
    _clearLines();
    canHold = true;
    if (!_spawn()) {
      running = false;
      paused = true;
      _showGameOver();
    }
    setState(() {});
  }

  void _rotate(int dir) {
    final nr = (curRot + dir) % 4;
    int ox = curX, oy = curY;

    // simple wall kicks: try some offsets
    const kicks = [Point(0, 0), Point(1, 0), Point(-1, 0), Point(0, -1), Point(0, 1), Point(2, 0), Point(-2, 0)];
    for (final k in kicks) {
      final nx = ox + k.x;
      final ny = oy + k.y;
      if (_valid(nx, ny, nr)) {
        setState(() {
          curRot = nr;
          curX = nx;
          curY = ny;
        });
        return;
      }
    }
  }

  void _hold() {
    if (!canHold) return;
    setState(() {
      canHold = false;
      if (hold == null) {
        hold = curType;
        _spawn();
      } else {
        final temp = hold;
        hold = curType;
        curType = temp;
        curRot = 0;
        curX = cols ~/ 2;
        curY = 0;
        if (!_valid(curX, curY, curRot)) {
          // if swapped piece overlaps -> game over
          running = false;
          paused = true;
          _showGameOver();
        }
      }
    });
  }

  void _lockPiece() {
    final shape = shapes[curType]![curRot];
    for (final b in shape) {
      final x = curX + b.x;
      final y = curY + b.y;
      if (y >= 0 && y < rows && x >= 0 && x < cols) {
        board[y][x] = curType;
      }
    }
  }

  void _clearLines() {
    int cleared = 0;
    for (int y = rows - 1; y >= 0; y--) {
      if (board[y].every((cell) => cell != null)) {
        // remove line
        for (int yy = y; yy > 0; yy--) {
          board[yy] = List<T?>.from(board[yy - 1]);
        }
        board[0] = List<T?>.filled(cols, null);
        cleared++;
        y++; // recheck this row after collapse
      }
    }

    if (cleared > 0) {
      // classic scoring
      const table = [0, 100, 300, 500, 800];
      score += table[cleared] * max(1, level);
      lines += cleared;
      level = 1 + lines ~/ 10;

      // update tick speed
      _timer.cancel();
      _timer = Timer.periodic(Duration(milliseconds: tickMs), _tick);
    }
  }

  // --- UI helpers ---
  List<Point<int>> _ghost() {
    // determine ghost drop position
    int gy = curY;
    while (_valid(curX, gy + 1, curRot)) {
      gy++;
    }
    return shapes[curType]![curRot].map((b) => Point(curX + b.x, gy + b.y)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1223),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
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
        //   'Flutter Tetris',
        //   style: TextStyle(color: cs.onBackground, fontWeight: FontWeight.w700),
        // ),
        actions: [
          IconButton(
            tooltip: paused ? 'Resume' : 'Pause',
            onPressed: _pause,
            icon: Icon(paused ? Icons.play_arrow : Icons.pause, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Restart',
            onPressed: _restart,
            icon: Icon(Icons.restart_alt, color: Colors.white),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: KeyboardListener(
          autofocus: true,
          focusNode: FocusNode(),
          onKeyEvent: (e) {
            if (!running || paused) return;
            final hw = HardwareKeyboard.instance;
            if (hw.isLogicalKeyPressed(LogicalKeyboardKey.arrowLeft)) setState(() => _move(-1, 0));
            if (hw.isLogicalKeyPressed(LogicalKeyboardKey.arrowRight)) setState(() => _move(1, 0));
            if (hw.isLogicalKeyPressed(LogicalKeyboardKey.arrowDown)) setState(() => _move(0, 1));
            if (hw.isLogicalKeyPressed(LogicalKeyboardKey.space)) _hardDrop();
            if (hw.isLogicalKeyPressed(LogicalKeyboardKey.keyZ)) _rotate(-1);
            if (hw.isLogicalKeyPressed(LogicalKeyboardKey.keyX)) _rotate(1);
            if (hw.isLogicalKeyPressed(LogicalKeyboardKey.shiftLeft)) _hold();
          },
          child: GestureDetector(
            onPanUpdate: (d) {
              if (paused || !running) return;
              if (d.delta.dx.abs() > d.delta.dy.abs()) {
                if (d.delta.dx > 0) {
                  setState(() => _move(1, 0));
                } else {
                  setState(() => _move(-1, 0));
                }
              } else {
                if (d.delta.dy > 0) setState(() => _move(0, 1));
              }
            },
            onDoubleTap: _hardDrop,
            child: Column(
              children: [
                // HUD
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [_hudTile('Score', '$score'), _hudTile('Lines', '$lines'), _hudTile('Level', '$level')],
                  ),
                ),
                // Game + sidebars
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // HOLD
                          // _sideBox(
                          //   title: 'HOLD',
                          //   child: AspectRatio(
                          //     aspectRatio: 1,
                          //     child: CustomPaint(painter: _MiniPiecePainter(piece: hold, rot: 0)),
                          //   ),
                          // ),
                          const SizedBox(width: 12),
                          // BOARD
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: aspect,
                              child: CustomPaint(
                                painter: _BoardPainter(board: board),
                                foregroundPainter: _ActivePiecePainter(board: board, type: curType, rot: curRot, ox: curX, oy: curY, ghost: _ghost()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // NEXT
                          _sideBox(
                            title: 'NEXT',
                            child: Column(
                              children: List.generate(3, (i) {
                                final t = (i < queue.length) ? queue[i] : null;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: AspectRatio(
                                      aspectRatio: 1.8,
                                      child: CustomPaint(painter: _MiniPiecePainter(piece: t, rot: 0)),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Controls
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _btn(Icons.rotate_left, () => _rotate(-1)),
                      _btn(Icons.arrow_left, () => setState(() => _move(-1, 0))),
                      _btn(Icons.arrow_downward, () => setState(() => _move(0, 1))),
                      _btn(Icons.arrow_right, () => setState(() => _move(1, 0))),
                      _btn(Icons.rotate_right, () => _rotate(1)),
                      // _btn(Icons.vertical_align_bottom, _hardDrop, label: 'HARD'),
                      // _btn(Icons.archive, _hold, label: 'HOLD'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hudTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  Widget _sideBox({required String title, required Widget child}) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap, {String? label}) {
    return InkWell(
      onTap: () {
        if (!paused && running) onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            if (label != null) ...[const SizedBox(width: 6), Text(label, style: const TextStyle(color: Colors.white))],
          ],
        ),
      ),
    );
  }

  void _showGameOver() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Score: $score\nLines: $lines\nLevel: $level'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restart();
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}

// --- Painters ---
class _BoardPainter extends CustomPainter {
  _BoardPainter({required this.board});
  final List<List<T?>> board;

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / cols;
    final cellH = size.height / rows;
    final bg = Paint()..color = const Color(0xFF12162B);
    final grid = Paint()..color = const Color(0xFF222747);
    canvas.drawRect(Offset.zero & size, bg);

    // grid
    for (int x = 0; x <= cols; x++) {
      canvas.drawLine(Offset(x * cellW, 0), Offset(x * cellW, size.height), grid);
    }
    for (int y = 0; y <= rows; y++) {
      canvas.drawLine(Offset(0, y * cellH), Offset(size.width, y * cellH), grid);
    }

    // locked blocks
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        final t = board[y][x];
        if (t != null) {
          _drawCell(canvas, Rect.fromLTWH(x * cellW, y * cellH, cellW, cellH), tColors[t]!);
        }
      }
    }
  }

  void _drawCell(Canvas canvas, Rect r, Color c) {
    final paint = Paint()..color = c;
    final shade = Paint()..color = Colors.black.withValues(alpha: .15);
    final shine = Paint()..color = Colors.white.withValues(alpha: .2);
    final rr = RRect.fromRectAndRadius(r.deflate(1.5), const Radius.circular(4));
    canvas.drawRRect(rr, paint);
    canvas.drawRRect(rr, shade);
    canvas.drawRRect(rr.deflate(4), shine);
  }

  @override
  bool shouldRepaint(covariant _BoardPainter old) => true;
}

class _ActivePiecePainter extends CustomPainter {
  _ActivePiecePainter({required this.board, required this.type, required this.rot, required this.ox, required this.oy, required this.ghost});

  final List<List<T?>> board;
  final T? type;
  final int rot, ox, oy;
  final List<Point<int>> ghost;

  @override
  void paint(Canvas canvas, Size size) {
    if (type == null) return;
    final cellW = size.width / cols;
    final cellH = size.height / rows;
    final col = tColors[type]!;

    // ghost (outline)
    final ghostPaint = Paint()
      ..color = col.withValues(alpha: .25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final g in ghost) {
      final r = Rect.fromLTWH(g.x * cellW, g.y * cellH, cellW, cellH).deflate(3);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(4)), ghostPaint);
    }

    // active blocks
    for (final b in shapes[type]![rot]) {
      final x = ox + b.x, y = oy + b.y;
      if (x < 0 || x >= cols || y < 0 || y >= rows) continue;
      final rect = Rect.fromLTWH(x * cellW, y * cellH, cellW, cellH);
      final rr = RRect.fromRectAndRadius(rect.deflate(1.5), const Radius.circular(4));
      final paint = Paint()..color = col;
      final shade = Paint()..color = Colors.black.withValues(alpha: .15);
      final shine = Paint()..color = Colors.white.withValues(alpha: .2);
      canvas.drawRRect(rr, paint);
      canvas.drawRRect(rr, shade);
      canvas.drawRRect(rr.deflate(4), shine);
    }
  }

  @override
  bool shouldRepaint(covariant _ActivePiecePainter old) =>
      old.type != type || old.rot != rot || old.ox != ox || old.oy != oy || old.board != board || old.ghost != ghost;
}

class _MiniPiecePainter extends CustomPainter {
  _MiniPiecePainter({required this.piece, required this.rot});
  final T? piece;
  final int rot;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = Colors.white10;
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)), bg);
    if (piece == null) return;

    final blocks = shapes[piece]![rot];
    final col = tColors[piece]!;
    final xs = blocks.map((e) => e.x).toList();
    final ys = blocks.map((e) => e.y).toList();
    final minX = xs.reduce(min), maxX = xs.reduce(max);
    final minY = ys.reduce(min), maxY = ys.reduce(max);
    final w = (maxX - minX + 1).toDouble();
    final h = (maxY - minY + 1).toDouble();

    final cell = min(size.width / (w + 1), size.height / (h + 1));
    final offX = (size.width - w * cell) / 2;
    final offY = (size.height - h * cell) / 2;

    for (final b in blocks) {
      final x = (b.x - minX) * cell + offX;
      final y = (b.y - minY) * cell + offY;
      final rect = Rect.fromLTWH(x, y, cell, cell).deflate(1);
      final rr = RRect.fromRectAndRadius(rect, const Radius.circular(3));
      canvas.drawRRect(rr, Paint()..color = col);
      canvas.drawRRect(rr.deflate(3), Paint()..color = Colors.white.withValues(alpha: .2));
    }
  }

  @override
  bool shouldRepaint(covariant _MiniPiecePainter old) => old.piece != piece || old.rot != rot;
}
