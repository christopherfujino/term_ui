import 'dart:ffi' as ffi;
import 'dart:io' as io;
import 'dart:math';

import 'package:dart_curses/dart_curses.dart';
import 'package:dart_curses/bindings.dart' as nc;

void main(List<String> arguments) {
  InteractiveProgram('libncurses.so.6', _callback).run();
}

void _callback(ffi.DynamicLibrary dylib, nc.NativeLibrary lib, ffi.Pointer<nc.WINDOW> win) {
  Random rand = Random.secure();
  final int maxx = win.ref.maxx;
  final int maxy = win.ref.maxy;
  int curx = rand.nextInt(maxx + 1);
  int cury = 0;

  bool loop() {
    cury += 1;
    if (cury > maxy) {
      cury = 0;
      curx = rand.nextInt(maxx + 1);
    }
    lib.werase(win);
    lib.clearok(win, true);

    final int gotChar = lib.wgetch(win);
    if (gotChar != nc.ERR) {
      return false;
    }

    lib.move(cury, curx);
    lib.wechochar(win, avatar);
    return true;
  }

  while (loop()) {
    io.sleep(const Duration(milliseconds: 30));
  }
}


