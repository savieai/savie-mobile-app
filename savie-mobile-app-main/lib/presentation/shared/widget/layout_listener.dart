import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class LayoutListener extends SingleChildRenderObjectWidget {
  const LayoutListener({
    required Widget super.child,
    required this.onConstraintsChanged,
    super.key,
  });

  final void Function(BoxConstraints constraints) onConstraintsChanged;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLayoutListener(onConstraintsChanged);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderLayoutListener renderObject,
  ) {
    renderObject.onConstraintsChanged = onConstraintsChanged;
  }
}

class RenderLayoutListener extends RenderProxyBox {
  RenderLayoutListener(this.onConstraintsChanged);

  void Function(BoxConstraints constraints) onConstraintsChanged;
  BoxConstraints? _oldConstraints;

  @override
  void performLayout() {
    super.performLayout();
    if (_oldConstraints != constraints) {
      _oldConstraints = constraints;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onConstraintsChanged(constraints);
      });
    }
  }
}
