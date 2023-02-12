import 'dart:ffi' as ffi;

import 'package:meta/meta.dart';
import 'package:ffi/ffi.dart' as pffi;

import 'ncurses.g.dart' as nc;

abstract class NcursesProgram {
  NcursesProgram(String libPath) : dylib = ffi.DynamicLibrary.open(libPath) {
    lib = nc.NativeLibrary(dylib);
    win = lib.initscr();
  }

  final ffi.DynamicLibrary dylib;
  late final nc.NativeLibrary lib;
  late final ffi.Pointer<nc.WINDOW> win;

  void run() {
    try {
      runImpl();
    } finally {
      dispose();
    }
  }

  void runImpl();

  @mustCallSuper
  void dispose() {
    lib.endwin();
  }

  void clear() {
    lib.erase();
    lib.clearok(win, true);
  }

  int? getch() {
    final int result = lib.getch();
    if (result != nc.ERR) {
      return null;
    }
    return result;
  }

  void move(int y, int x) {
    final int result = lib.move(y, x); // TODO handle return value?
    if (result == nc.ERR) {
      throw Exception('failed calling move($y, $x)');
    }
  }

  void echochar(int char) {
    final int result = lib.echochar(char);
    if (result == nc.ERR) {
      throw Exception('failed calling echochar($char)');
    }
  }
  void addstr(String str) {
    final int result = lib.addstr(str.toNativeUtf8());
    // TODO check result?
  }
}

abstract class InteractiveProgram extends NcursesProgram {
  InteractiveProgram(super.libPath) {
    lib
        ..curs_set(0)
        ..nodelay(win, true)
        ..cbreak()
        ..noecho();
  }
}
