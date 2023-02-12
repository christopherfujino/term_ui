import 'build_context.dart';
import 'elements.dart';
import 'render_objects.dart';

abstract class Widget {
  const Widget();
}

abstract class RenderObjectWidget extends Widget {
  const RenderObjectWidget();

  RenderObject createRenderObject(BuildContext context);
}

abstract class StatelessWidget extends Widget {
  const StatelessWidget();

  Widget build(BuildContext context);
}

class Center extends Widget {
  const Center({
    required this.child,
  });

  final Widget child;
}

class Column extends Widget {
  const Column({required this.children});

  final List<Widget> children;
}

// Actually more like a RichText from Flutter
class Text extends RenderObjectWidget {
  const Text(this.data);

  final String data;

  @override
  RenderParagraph createRenderObject(BuildContext context) =>
      RenderParagraph(data);
}
