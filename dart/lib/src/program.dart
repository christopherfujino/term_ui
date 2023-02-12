import 'dart:ffi' as ffi;

import 'package:meta/meta.dart';

import 'ncurses.g.dart' as nc;

abstract class NcursesProgram {
  NcursesProgram(String libPath, this.callback) : dylib = ffi.DynamicLibrary.open(libPath) {
    lib = nc.NativeLibrary(dylib);
    win = lib.initscr();
  }

  final ffi.DynamicLibrary dylib;
  late final nc.NativeLibrary lib;
  late final ffi.Pointer<nc.WINDOW> win;
  final void Function(ffi.DynamicLibrary, nc.NativeLibrary, ffi.Pointer<nc.WINDOW>) callback;

  void run() {
    try {
      callback(dylib, lib, win);
    } finally {
      dispose();
    }
  }

  @mustCallSuper
  void dispose() {
    lib.endwin();
  }
}

class InteractiveProgram extends NcursesProgram {
  InteractiveProgram(super.libPath, super.callback) {
    lib
        ..curs_set(0)
        ..nodelay(win, true)
        ..cbreak()
        ..noecho();
  }
}
