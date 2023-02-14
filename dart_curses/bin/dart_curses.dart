import 'dart:collection';
import 'dart:ffi' as ffi;
import 'dart:io' as io;
import 'dart:math';

import 'package:dart_curses/dart_curses.dart';

void main(List<String> arguments) {
  Program().run();
}

class Program extends InteractiveProgram {
  Program() : super('libncurses.so.6');

  late int maxx = win.ref.maxx;
  late int maxy = win.ref.maxy;

  final Queue<Star> stars = Queue<Star>();

  @override
  void runImpl() {
    Random rand = Random.secure();
    int i = 0;
    final int interval = maxy ~/ 7;

    bool loop() {
      if (i % interval == 0) {
        stars.add(Star(rand.nextInt(maxx + 1), 0));
      }
      i += 1;
      final int nextRand = rand.nextInt(94);
      final int char = nextRand + 33;
      clear();

      final int? gotChar = getch();
      if (gotChar == null) {
        return false;
      }

      bool shouldRemove = false;
      for (final Star star in stars) {
        shouldRemove = star.tick(this, char) ?? shouldRemove;
      }

      if (shouldRemove) {
        stars.removeFirst();
      }

      refresh();
      return true;
    }

    while (loop()) {
      io.sleep(const Duration(milliseconds: 20));
    }
  }
}

class Star {
  Star(this.x, this.y);

  final int x;
  int y;

  static const int tailLength = 5;

  bool? tick(Program program, int char) {
    final int top = (y - tailLength).clamp(0, y);
    for (int tailY = 0; tailY + y >= 0 && tailY + y >= top; tailY -= 1) {
      program.mvaddch(tailY + y, x, char);
    }
    y += 1;
    if (y >= program.maxy) {
      return true;
    }

    return null;
  }
}
