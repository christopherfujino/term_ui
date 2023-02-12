import 'dart:ffi' as ffi;
import 'dart:io' as io;
import 'dart:math';

import 'package:ffi/ffi.dart' as pffi;

import 'src/ncurses.g.dart' as nc;

Random rand = Random.secure();

final int avatar = 'X'.codeUnitAt(0);

class Program {
  Program(String libPath) : dylib = ffi.DynamicLibrary.open(libPath) {
    _lib = nc.NativeLibrary(dylib);
    _win = _lib.initscr();
    _maxx = _win.ref.maxx;
    _maxy = _win.ref.maxy;
    _curx = rand.nextInt(_maxx + 1);
    _cury = 0;
    _lib
        ..curs_set(0)
        ..nodelay(_win, true)
        ..cbreak()
        ..noecho();
  }

  final ffi.DynamicLibrary dylib;
  late final nc.NativeLibrary _lib;
  late final ffi.Pointer<nc.WINDOW> _win;
  late final int _maxx;
  late final int _maxy;
  late int _curx;
  late int _cury;

  void run() {
    try {
      while (_loop()) {
        io.sleep(const Duration(milliseconds: 25));
      }
    } finally {
      _cleanUp();
    }
  }

  void _cleanUp() {
    _lib.endwin();
  }

  bool _loop() {
    _cury += 1;
    if (_cury > _maxy) {
      _cury = 0;
      _curx = rand.nextInt(_maxx + 1);
    }
    _lib.werase(_win);
    _lib.clearok(_win, true);

    final int gotChar = _lib.wgetch(_win);
    if (gotChar != nc.ERR) {
      return false;
    }

    _lib.move(_cury, _curx);
    _lib.wechochar(_win, avatar);
    return true;
  }
}
