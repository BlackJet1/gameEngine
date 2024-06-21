import 'dart:ui';
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

  factory Background.parallax({
    required String imageFar,
    required String imageNear,
    required String imageMid,
    required double farSpeed,
    required double nearSpeed,
    required double midSpeed,
  }) =>
      ParallaxBackground(
        gl: Engine.instance.gl,
        imageFar: imageFar,
        imageNear: imageNear,
        imageMid: imageMid,
        farSpeed: farSpeed,
        nearSpeed: nearSpeed,
        midSpeed: midSpeed,
      );
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

class ParallaxBackground extends Background {
  final LibOpenGLES gl;
  final String imageFar;
  final String imageMid;
  final String imageNear;
  final double farSpeed;
  final double midSpeed;
  final double nearSpeed;
  late final int farSpr;
  late final int midSpr;
  late final int nearSpr;
  late final int farSpr2;
  late final int midSpr2;
  late final int nearSpr2;
  double farX = 0;
  double midX = 0;
  double nearX = 0;
  double farX2 = 0;
  double midX2 = 0;
  double nearX2 = 0;

  ParallaxBackground({
    required this.gl,
    required this.imageFar,
    required this.imageMid,
    required this.imageNear,
    required this.farSpeed,
    required this.midSpeed,
    required this.nearSpeed,
  }) {
    final sprites = Engine.instance.sprites!;
    final len = Engine.engineLen!;
    final hgt = Engine.engineHgt!;
    const x = 0;
    farX = x.toDouble();
    midX = x.toDouble();
    nearX = x.toDouble();
    final y = hgt ~/ 2;
    farX2 = farSpeed < 0 ? len * 1.0 : -len * 1.0;
    midX2 = midSpeed < 0 ? len * 1.0 : -len * 1.0;
    nearX2 = nearSpeed < 0 ? len * 1.0 : -len * 1.0;
    farSpr =
        sprites.add(x: x, y: y, z: 100, len: len, hgt: hgt, atom: imageFar);
    midSpr = sprites.add(
      x: x,
      y: y,
      z: 99,
      len: len,
      hgt: hgt,
      atom: imageMid,
    );
    nearSpr = sprites.add(
      x: x,
      y: y,
      z: 98,
      len: len,
      hgt: hgt,
      atom: imageNear,
    );
    farSpr2 = sprites.add(
        x: farX2.toInt(), y: y, z: 100, len: len, hgt: hgt, atom: imageFar);
    midSpr2 = sprites.add(
      x: midX2.toInt(),
      y: y,
      z: 99,
      len: len,
      hgt: hgt,
      atom: imageMid,
    );
    nearSpr2 = sprites.add(
      x: nearX2.toInt(),
      y: y,
      z: 98,
      len: len,
      hgt: hgt,
      atom: imageNear,
    );
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
    final cx = camera.pos.x.toInt() + camera.viewLen ~/ 2;
    final cy = camera.pos.y.toInt() + camera.viewHgt ~/ 2;
    farX += delta * farSpeed;
    midX += delta * midSpeed;
    nearX += delta * nearSpeed;
    farX2 += delta * farSpeed;
    midX2 += delta * midSpeed;
    nearX2 += delta * nearSpeed;
    if (farSpeed > 0) {
      if (farX > camera.viewLen) {
        farX -= camera.viewLen * 2;
      }
      if (farX2 > camera.viewLen) {
        farX2 -= camera.viewLen * 2;
      }
    } else {
      if (farX < -camera.viewLen) {
        farX += camera.viewLen * 2;
      }
      if (farX2 < -camera.viewLen) {
        farX2 += camera.viewLen * 2;
      }
    }
    if (midSpeed > 0) {
      if (midX > camera.viewLen) {
        midX -= camera.viewLen * 2;
      }
      if (midX2 > camera.viewLen) {
        midX2 -= camera.viewLen * 2;
      }
    } else {
      if (midX < -camera.viewLen) {
        midX += camera.viewLen * 2;
      }
      if (midX2 < -camera.viewLen) {
        midX2 += camera.viewLen * 2;
      }
    }
    if (nearSpeed > 0) {
      if (nearX > camera.viewLen) {
        nearX -= camera.viewLen * 2;
      }
      if (nearX2 > camera.viewLen) {
        nearX2 -= camera.viewLen * 2;
      }
    } else {
      if (nearX < -camera.viewLen) {
        nearX += camera.viewLen * 2;
      }
      if (nearX2 < -camera.viewLen) {
        nearX2 += camera.viewLen * 2;
      }
    }
    sprites
      ..updatePosition(farSpr, farX.toInt() + cx, cy, 100)
      ..updatePosition(midSpr, midX.toInt() + cx, cy, 99)
      ..updatePosition(nearSpr, nearX.toInt() + cx, cy, 98)
      ..updatePosition(farSpr2, farX2.toInt() + cx, cy, 100)
      ..updatePosition(midSpr2, midX2.toInt() + cx, cy, 99)
      ..updatePosition(nearSpr2, nearX2.toInt() + cx, cy, 98);
  }
}
