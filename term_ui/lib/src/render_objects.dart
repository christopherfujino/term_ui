import 'common.dart';

import 'package:dart_curses/dart_curses.dart';

abstract class RenderObject {
  void layout(Constraints constraints);

  void paint(Canvas canvas, Offset offset);
}

/// The root node of the render tree.
class RenderView extends RenderObject {
  RenderView({this.child});

  RenderBox? child;

  @override
  void layout(Constraints constraints) => throw StateError('The root RenderView should never be layed out');

  @override
  void paint(Canvas canvas, Offset offset) {
    if (child != null) {
      canvas.paintChild(child!, offset);
    }
  }
}

abstract class RenderBox extends RenderObject {}

class RenderParagraph extends RenderBox {
  RenderParagraph(this.data);

  final String data;

  @override
  void layout(Constraints constraints) {
    throw UnimplementedError('TODO implement RenderParagraph.layout');
  }

  @override
  void paint(Canvas canvas, Offset offset) {
    canvas.program.move(offset.dy, offset.dx);
    canvas.program.addstr(data);
  }
}

class Constraints {}

class Canvas {
  const Canvas(this.program);

  final InteractiveProgram program;

  void paintChild(RenderObject child, Offset offset) {
    child.paint(this, offset);
  }
}
