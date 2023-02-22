import 'dart:collection';
import 'dart:ffi' as ffi;
import 'dart:io' as io;
import 'dart:math';
import 'dart:typed_data';

import 'package:dart_curses/dart_curses.dart';
import 'package:dart_curses/bindings.dart' as nc;

void main(List<String> arguments) {
  Program().run();
}

const int greenIndex = 1; // must be >= 1
const int whiteIndex = 2;

final Random rand = Random.secure();
int get nextChar => rand.nextInt(94) + 33;

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
    init_pair(whiteIndex, nc.COLOR_WHITE, nc.COLOR_BLACK);
    int i = 0;
    // how many rows before a new Stars should be spawned.
    final int interval = maxy ~/ 7;
    final int starsPerRow = maxx ~/ 10 + 1;

    bool loop() {
      if (i % interval == 0) {
        for (int j = 0; j < starsPerRow; j++) {
          stars.add(Star(rand.nextInt(maxx + 1), 0));
        }
      }
      i += 1;
      clear();

      final int? gotChar = getch();
      if (gotChar == null) {
        return false;
      }

      bool shouldRemove = false;
      for (final Star star in stars) {
        shouldRemove = star.tick(this) ?? shouldRemove;
      }

      if (shouldRemove) {
        stars.removeFirst();
      }

      refresh();
      return true;
    }

    while (loop()) {
      io.sleep(const Duration(milliseconds: 40));
    }
  }
}

class Star {
  Star(this.x, this.y) {
    for (int i = 0; i < tailLength; i++) {
      chars[i] = nextChar;
    }
  }

  final int x;
  int y;
  final Uint8List chars = Uint8List(tailLength);

  static const int tailLength = 15;

  bool? tick(Program program) {
    final int top = (y - tailLength).clamp(0, y);
    if (top >= program.maxy) {
      return true;
    }
    final int bottom = min(y, program.maxy - 1);
    final int length = bottom - top;
    program.attron(greenIndex);
    late int i;
    for (i = 0; i < length - 1; i++) {
      program.mvaddch(top + i, x, chars[i]);
    }
    program.attron(whiteIndex);
    program.mvaddch(top + i, x, chars[i]);

    y += 1;
    return null;
  }
}
