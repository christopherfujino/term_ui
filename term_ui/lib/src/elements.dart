import 'build_context.dart';
import 'widgets.dart';
import 'render_objects.dart';

abstract class Element implements BuildContext {
  Element(this.widget);

  final Widget widget;

  RenderObject get renderObject => throw UnimplementedError('Not sure how to handle');

  void mount(Element? parent, Object? newSlot) => throw UnimplementedError('Not sure how to handle');

  void rebuild() => throw UnimplementedError('Should be empty');

}

class RootElement {
  RootElement();
}

class ComponentElement extends Element {
  ComponentElement(super.widget);
}


class RenderObjectElement extends Element {
  RenderObjectElement(super.widget);

  RenderObject? _renderObject;

  void attachRenderObject(Object? newSlot) => throw UnimplementedError('TODO figure out');

  @override
  RenderObject get renderObject => _renderObject!;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _renderObject = (widget as RenderObjectWidget).createRenderObject(this);
    attachRenderObject(newSlot);
  }
}
