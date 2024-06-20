import 'package:opengl_es_bindings/opengl_es_bindings.dart';
import 'package:vector_math/vector_math.dart';

import 'engine.dart';
import 'shaders.dart';

class JCamera {
  final JShader shader;
  final LibOpenGLES gl;

  JCamera({required this.gl, required this.shader});

  Vector2 pos = Vector2.zero();
  int viewLen = 1280;
  int viewHgt = 720;
  Vector2 shift = Vector2.zero();

  // смотри куда то, то куда смотрим - в центре экрана
  void lookAt(Vector2 to) {
    shift = to - pos;
  }

  void screen() {
    gl.glUniform4f(shader.cameraSlot, 0, 0, (Engine.engineLen ?? 512) / 2,
        (Engine.engineHgt ?? 512) / 2);
  }

  void prepare() {
    gl.glUniform4f(
        shader.cameraSlot, pos.x, pos.y, viewLen / 2, viewHgt / 2);
  }

  void init() {
    shift = Vector2.zero();
    pos = Vector2.zero();
    viewHgt = Engine.engineHgt??512;
    viewLen = Engine.engineLen??512;
  }

  void update(double delta, {int spd=1}) {
    pos.x += shift.x * delta * spd;
    shift.x -= delta * spd * shift.x;

    final vspd = spd.abs() + (shift.y < 0 ? 50 : 1);
    pos.y += shift.y * delta * vspd;
    shift.y -= delta * vspd;
    if (pos.y < 0) pos.y = 0;
  }
}
