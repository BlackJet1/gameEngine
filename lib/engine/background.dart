import 'dart:ui';
import 'package:jet_game_engine/engine/camera.dart';
import 'package:opengl_es_bindings/opengl_es_bindings.dart';
import 'engine.dart';

sealed class Background {
  const Background();

  void render();

  void update(double delta) {}

  factory Background.clear({required Color color}) =>
      ClearBackground(color: color, gl: Engine.instance.gl);

  factory Background.image({required String image}) =>
      ImageBackground(image: image, gl: Engine.instance.gl);
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

class ImageBackground extends Background {
  final String image;
  final LibOpenGLES gl;

  late final int spr;

  ImageBackground({
    required this.image,
    required this.gl,
  }) {
    final sprites = Engine.instance.sprites!;
    final len = Engine.engineLen!;
    final hgt = Engine.engineHgt!;
    final x = len ~/ 2;
    final y = hgt ~/ 2;

    spr = sprites.add(x: x, y: y, z: 100, len: len, hgt: hgt, atom: image);
  }

  @override
  void render() {
    gl
      ..glClearDepthf(1)
      ..glClear(GL_DEPTH_BUFFER_BIT);
  }

  @override
  void update(double delta) {
    final sprites = Engine.instance.sprites!;
    final camera = Engine.instance.camera!;
    sprites.updatePosition(spr, camera.pos.x.toInt() + camera.viewLen ~/ 2,
        camera.pos.y.toInt() + camera.viewHgt ~/ 2, 100);
  }
}
