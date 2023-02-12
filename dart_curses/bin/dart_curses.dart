import 'dart:ffi' as ffi;
import 'dart:io' as io;
import 'dart:math';

import 'package:dart_curses/dart_curses.dart';

void main(List<String> arguments) {
  Program().run();
}

class Program extends InteractiveProgram {
  Program() : super('libncurses.so.6');

  @override
  void runImpl() {
    Random rand = Random.secure();
    final int maxx = win.ref.maxx;
    final int maxy = win.ref.maxy;
    int curx = rand.nextInt(maxx + 1);
    int cury = 0;

    bool loop() {
      final int nextRand = rand.nextInt(1 << 32);
      final int char = (nextRand % 94) + 33;
      cury += 1;
      if (cury > maxy) {
        cury = 0;
        curx = nextRand % (maxx + 1);
      }
      clear();

      final int? gotChar = getch();
      if (gotChar == null) {
        return false;
      }

      move(cury, curx);
      echochar(char);
      return true;
    }

    while (loop()) {
      io.sleep(const Duration(milliseconds: 30));
    }
  }
}
