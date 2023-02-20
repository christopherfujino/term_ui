import 'dart:collection';
import 'dart:ffi' as ffi;
import 'dart:io' as io;
import 'dart:math';

import 'package:dart_curses/dart_curses.dart';
import 'package:dart_curses/bindings.dart' as nc;

void main(List<String> arguments) {
  Program().run();
}

const int greenIndex = 1; // must be >= 1

class Program extends InteractiveProgram {
  Program._(super.path);

  factory Program() {
    if (io.Platform.isLinux) {
      return Program._('libncurses.so.6');
    }
    if (io.Platform.isMacOS) {
      // path discovery doesn't work?
      return Program._('/opt/local/lib/libncurses.6.dylib');
    }
    throw UnimplementedError('do not know your OS bruh');
  }

  late int maxx = win.ref.maxx;
  late int maxy = win.ref.maxy;
  final Random rand = Random.secure();

  final Queue<Star> stars = Queue<Star>();

  @override
  void runImpl() {
    if (!lib.has_colors()) {
      throw 'foolies';
    }
    if (lib.start_color() != nc.OK) {
      throw 'failed calling start_color';
    }
    init_pair(greenIndex, nc.COLOR_GREEN, nc.COLOR_BLACK);
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
    program.attron(greenIndex);
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
