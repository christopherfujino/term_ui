import 'common.dart';

import 'package:dart_curses/dart_curses.dart';

abstract class RenderObject {
  void layout(Constraints constraint);

  void paint(Canvas canvas, Offset offset);
}

abstract class RenderBox extends RenderObject {}

class RenderParagraph extends RenderBox {
  RenderParagraph(this.data);

  final String data;

  @override
  void layout(Constraints constraint) {
    throw UnimplementedError('TODO implement RenderParagraph.layout');
  }

  @override
  void paint(Canvas canvas, Offset offset) {
    canvas.program.move(offset.dy, offset.dx);
  }
}

class Constraints {}

class Canvas {
  const Canvas(this.program);

  final InteractiveProgram program;
}
