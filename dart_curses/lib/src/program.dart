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

  void mvaddch(int y, int x, int char) {
    final int result = lib.mvaddch(y, x, char);
    if (result == nc.ERR) {
      throw Exception('failed calling mvaddch($y, $x, $char)');
    }
  }

  void attron(int index) {
    final int result = lib.attron(lib.COLOR_PAIR(index));
    if (result == nc.ERR) {
      throw Exception('Foo bar');
    }
  }

  void init_pair(int index, int foreground, int background) {
    final int result = lib.init_pair(index, foreground, background);
    if (result == nc.ERR) {
      throw Exception('failed calling init_pair($index, $foreground, $background)');
    }
  }

  void echochar(int char) {
    final int result = lib.echochar(char);
    if (result == nc.ERR) {
      throw Exception('failed calling echochar($char)');
    }
  }

  void refresh() {
    final int result = lib.refresh();
    if (result == nc.ERR) {
      throw Exception('failed calling refresh()');
    }
  }

  void addstr(String str) {
    final ptr = str.toNativeUtf8();
    try {
      final int result = lib.addstr(ptr.cast<ffi.Char>());
      if (result == nc.ERR) {
        throw Exception('failed calling addstr($str)');
      }
    } finally {
      pffi.malloc.free(ptr);
    }
  }
}

abstract class InteractiveProgram extends NcursesProgram {
  InteractiveProgram(super.libPath) {
    lib
        ..curs_set(0)
        ..nodelay(win, true)
        ..cbreak()
        ..noecho()
        ..scrollok(win, false);
  }
}
