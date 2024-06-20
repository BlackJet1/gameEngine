import 'dart:ui';
import 'package:opengl_es_bindings/opengl_es_bindings.dart';
import 'engine.dart';

sealed class Background {
  const Background();

  void render();

  void update(double delta) {}

  factory Background.clear({required Color color}) => ClearBackground(color: color, gl: Engine.instance.gl);
}

class ClearBackground extends Background {
  final Color color;
  final LibOpenGLES gl;

  const ClearBackground({required this.color, required this.gl});

  @override
  void render() {
    gl
      ..glClearColor(color.red / 255, color.green / 255, color.blue / 255,
          color.alpha / 255)
      ..glClearDepthf(1)
      ..glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  }
}
