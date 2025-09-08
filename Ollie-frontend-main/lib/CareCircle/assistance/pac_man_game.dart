import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

enum Dir { up, down, left, right, none }

class PacmanGame extends StatefulWidget {
  const PacmanGame({super.key});
  @override
  State<PacmanGame> createState() => _PacmanGameState();
}

class _PacmanGameState extends State<PacmanGame> with TickerProviderStateMixin {
  // --- Maze (0 wall, 1 pellet, 2 empty, 3 power pellet (bonus)) ---
  // 15 cols × 21 rows (keep small so it runs everywhere)
  static const int cols = 15;
  static const int rows = 21;

  late List<int> map; // rows*cols flattened

  // --- Game state ---
  int score = 0;
  int lives = 3;
  bool running = false;
  bool paused = false;

  // Pac-Man
  int p = 0; // index in map
  Dir dir = Dir.left;
  Dir nextDir = Dir.left;

  // Ghost (single red)
  int g = 0;
  final _rng = Random();

  // Tick
  Timer? timer;
  static const tickMs = 140;

  // Mouth animation
  late AnimationController mouthCtrl;

  // Helpers
  int idx(int r, int c) => r * cols + c;
  int rOf(int i) => i ~/ cols;
  int cOf(int i) => i % cols;

  @override
  void initState() {
    super.initState();
    mouthCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 220))..repeat(reverse: true);
    _resetLevel();
    _start();
  }

  @override
  void dispose() {
    timer?.cancel();
    mouthCtrl.dispose();
    super.dispose();
  }

  void _start() {
    running = true;
    paused = false;
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: tickMs), (_) {
      if (!paused) _tick();
    });
  }

  void _pause() => setState(() => paused = !paused);

  void _restartAll() {
    setState(() {
      score = 0;
      lives = 3;
    });
    _resetLevel();
    _start();
  }

  void _resetLevel() {
    // Simple symmetric maze
    const raw = [
      "###############",
      "#........#....#",
      "#.###.##.#.##.#",
      "#.#.....#....#.",
      "#.#.###.#.##..#",
      "#.#.#...#..#..#",
      "#...#.#.##.#..#",
      "###.#.#....#..#",
      "#...#.#.####..#",
      "#.#...#....#..#",
      "#.#.###.##.#..#",
      "#.#.....##.#..#",
      "#.#####....#..#",
      "#.....######..#",
      "#.###.......#.#",
      "#...#.#####.#.#",
      "###.#.....#.#.#",
      "#...#.###.#.#.#",
      "#.#.....#...#.#",
      "#....#....#...#",
      "###############",
    ];
    map = List.generate(rows * cols, (i) {
      final ch = raw[rOf(i)][cOf(i)];
      if (ch == '#') return 0;
      return 1; // pellet
    });

    // Power pellets at corners (value 3)
    for (final i in [idx(1, 1), idx(1, cols - 2), idx(rows - 2, 1), idx(rows - 2, cols - 2)]) {
      if (map[i] != 0) map[i] = 3;
    }

    // Start positions
    p = idx(rows - 2, 1);
    g = idx(1, cols - 2);
    dir = Dir.right;
    nextDir = Dir.right;
  }

  bool _isWall(int i) => map[i] == 0;

  int _step(int i, Dir d) {
    int r = rOf(i), c = cOf(i);
    switch (d) {
      case Dir.left:
        c = (c - 1 + cols) % cols;
        break;
      case Dir.right:
        c = (c + 1) % cols;
        break;
      case Dir.up:
        r = (r - 1 + rows) % rows;
        break;
      case Dir.down:
        r = (r + 1) % rows;
        break;
      case Dir.none:
        break;
    }
    return idx(r, c);
  }

  bool _canMove(int i, Dir d) => !_isWall(_step(i, d));

  void _tick() {
    setState(() {
      // Try turn if requested
      if (_canMove(p, nextDir)) {
        dir = nextDir;
      }
      // Move Pac-Man if possible
      if (_canMove(p, dir)) {
        p = _step(p, dir);
      }

      // Eat pellet
      if (map[p] == 1) {
        score += 10;
        map[p] = 2;
      } else if (map[p] == 3) {
        score += 50;
        map[p] = 2;
      } // (no power mode for simplicity)

      // Move ghost (greedy chase with random tie-break)
      final options = <Dir>[Dir.up, Dir.down, Dir.left, Dir.right].where((d) => _canMove(g, d)).toList();
      if (options.isNotEmpty) {
        Dir best = options.first;
        int bestDist = 1 << 30;
        options.shuffle(_rng);
        for (final d in options) {
          final ni = _step(g, d);
          final dist = (rOf(ni) - rOf(p)).abs() + (cOf(ni) - cOf(p)).abs();
          if (dist < bestDist) {
            bestDist = dist;
            best = d;
          }
        }
        g = _step(g, best);
      }

      // Check collision
      if (g == p) {
        lives -= 1;
        if (lives <= 0) {
          paused = true;
          _showGameOver();
        } else {
          // Reset positions for new life
          p = idx(rows - 2, 1);
          g = idx(1, cols - 2);
          dir = Dir.right;
          nextDir = Dir.right;
        }
      }

      // Win condition: all pellets eaten
      if (!map.any((v) => v == 1 || v == 3)) {
        paused = true;
        _showWin();
      }
    });
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
              _restartAll();
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  void _showWin() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('You Win!'),
        content: Text('Score: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetLevel();
              setState(() {
                paused = false;
              });
            },
            child: const Text('Next Level'),
          ),
        ],
      ),
    );
  }

  void _setDir(Dir d) {
    setState(() => nextDir = d);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0c0f16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Flutter Pac-Man', style: TextStyle(color: cs.onBackground)),
        actions: [
          IconButton(
            onPressed: _pause,
            icon: Icon(paused ? Icons.play_arrow : Icons.pause, color: cs.onBackground),
            tooltip: paused ? 'Resume' : 'Pause',
          ),
          IconButton(
            onPressed: _restartAll,
            icon: Icon(Icons.restart_alt, color: cs.onBackground),
            tooltip: 'Restart',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onPanUpdate: (details) {
            if (details.delta.dx.abs() > details.delta.dy.abs()) {
              if (details.delta.dx > 0)
                _setDir(Dir.right);
              else
                _setDir(Dir.left);
            } else {
              if (details.delta.dy > 0)
                _setDir(Dir.down);
              else
                _setDir(Dir.up);
            }
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Score: $score',
                      style: TextStyle(color: cs.onBackground, fontWeight: FontWeight.w700),
                    ),
                    Row(children: List.generate(lives, (_) => const _LifeDot())),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: cols / rows,
                    child: CustomPaint(
                      painter: _MazePainter(map: map, cols: cols, rows: rows),
                      foregroundPainter: _ActorsPainter(cols: cols, rows: rows, pac: p, dir: dir, mouth: mouthCtrl.value, ghost: g),
                    ),
                  ),
                ),
              ),
              // On-screen controls (optional)
              Padding(
                padding: const EdgeInsets.only(bottom: 12, top: 6),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _CtlButton(icon: Icons.keyboard_arrow_up, onTap: () => _setDir(Dir.up)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _CtlButton(icon: Icons.keyboard_arrow_left, onTap: () => _setDir(Dir.left)),
                        const SizedBox(width: 6),
                        _CtlButton(icon: Icons.keyboard_arrow_right, onTap: () => _setDir(Dir.right)),
                      ],
                    ),
                    _CtlButton(icon: Icons.keyboard_arrow_down, onTap: () => _setDir(Dir.down)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- UI pieces ----
class _CtlButton extends StatelessWidget {
  const _CtlButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}

class _LifeDot extends StatelessWidget {
  const _LifeDot();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 12,
      height: 12,
      decoration: const BoxDecoration(color: Color(0xFFFFEB3B), shape: BoxShape.circle),
    );
  }
}

// ---- Painters ----
class _MazePainter extends CustomPainter {
  _MazePainter({required this.map, required this.cols, required this.rows});
  final List<int> map;
  final int cols, rows;

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / cols;
    final cellH = size.height / rows;
    final wall = Paint()
      ..color = const Color(0xFF0F2A7A)
      ..style = PaintingStyle.fill;
    final pellet = Paint()..color = const Color(0xFFFFEE58);
    final bg = Paint()..color = const Color(0xFF101428);

    // background
    canvas.drawRect(Offset.zero & size, bg);

    // draw cells
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final i = r * cols + c;
        final rect = Rect.fromLTWH(c * cellW, r * cellH, cellW, cellH);

        if (map[i] == 0) {
          canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(1.5), const Radius.circular(4)), wall);
        } else if (map[i] == 1) {
          canvas.drawCircle(rect.center, min(cellW, cellH) * .08, pellet);
        } else if (map[i] == 3) {
          canvas.drawCircle(rect.center, min(cellW, cellH) * .16, pellet);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MazePainter old) => old.map != map;
}

class _ActorsPainter extends CustomPainter {
  _ActorsPainter({required this.cols, required this.rows, required this.pac, required this.dir, required this.mouth, required this.ghost});

  final int cols, rows;
  final int pac;
  final Dir dir;
  final double mouth; // 0..1
  final int ghost;

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / cols;
    final cellH = size.height / rows;

    // Pac-Man
    final pacCenter = Offset((pac % cols + .5) * cellW, (pac ~/ cols + .5) * cellH);
    final pacR = min(cellW, cellH) * .42;
    final baseAngle = switch (dir) {
      Dir.right => 0.0,
      Dir.left => pi,
      Dir.up => -pi / 2,
      Dir.down => pi / 2,
      Dir.none => 0.0,
    };
    final open = 0.2 + 0.2 * (mouth); // animate
    final pacPaint = Paint()..color = const Color(0xFFFFEB3B);
    final mouthStart = baseAngle + open;
    final mouthSweep = 2 * pi - 2 * open;
    canvas.drawArc(Rect.fromCircle(center: pacCenter, radius: pacR), mouthStart, mouthSweep, true, pacPaint);

    // Ghost
    final gCenter = Offset((ghost % cols + .5) * cellW, (ghost ~/ cols + .5) * cellH);
    final gw = min(cellW, cellH) * .9;
    final gh = gw * .9;
    final body = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: gCenter.translate(0, -gh * 0.05), width: gw, height: gh * 0.9), Radius.circular(gw * .4)),
      )
      ..addRect(Rect.fromCenter(center: gCenter.translate(0, gh * 0.15), width: gw, height: gh * 0.4));
    final ghostPaint = Paint()..color = const Color(0xFFE53935);
    canvas.drawPath(body, ghostPaint);
    // eyes
    final eyePaint = Paint()..color = Colors.white;
    final pupil = Paint()..color = Colors.blue.shade900;
    final eOffX = gw * .18, eOffY = gh * -.12;
    canvas.drawCircle(gCenter.translate(-eOffX, eOffY), gw * .10, eyePaint);
    canvas.drawCircle(gCenter.translate(eOffX, eOffY), gw * .10, eyePaint);
    canvas.drawCircle(gCenter.translate(-eOffX, eOffY), gw * .05, pupil);
    canvas.drawCircle(gCenter.translate(eOffX, eOffY), gw * .05, pupil);
  }

  @override
  bool shouldRepaint(covariant _ActorsPainter old) => old.pac != pac || old.dir != dir || old.mouth != mouth || old.ghost != ghost;
}
