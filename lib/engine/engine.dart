import 'dart:developer';
import 'dart:ffi';
import 'dart:io';


import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gl_canvas/gl_canvas.dart';
import 'package:opengl_es_bindings/opengl_es_bindings.dart';

import 'atoms.dart';
import 'bach.dart';
import 'background.dart';
import 'camera.dart';
import 'shaders.dart';
import 'sprites.dart';
import 'texture.dart';

class Engine {
  static const int vertexBufferSizeBytes = 48;
  static const int vertexBufferSize = 12;

  late final Bach bach;
  late final LibOpenGLES gl;
  late final GLCanvasController controller;

  //index buffer
  static late final Pointer<Uint32> ibo;
  static late final Pointer<Int16> index;
  static bool _preparedIBO = false;

  static int? engineLen;
  static int? engineHgt;
  bool isAnimation = false;
  int _previous = DateTime.timestamp().microsecondsSinceEpoch;
  void Function(double)? updateCallback;

  Background? background;
  JTexture? texture;
  JShader? shader;
  JCamera? camera;
  GraphicAtoms? atoms;
  Sprites? sprites;

  static void setSize(int len, int hgt) {
    log('set size $len $hgt');
    engineLen = len;
    engineHgt = hgt;
  }

  Engine._constructor() {
    if (engineLen == null || engineHgt == null) {
      throw Exception('engine size not set');
    }
    log('create engine with $engineLen x $engineHgt');
    gl = LibOpenGLES(Platform.isAndroid
        ? DynamicLibrary.open('libGLESv3.so')
        : DynamicLibrary.process());
    try {
      controller = GLCanvasController(
          width: engineLen!.toDouble(),
          height: engineHgt!.toDouble(),
          version: GLESVersion.GLES_30);
    } on PlatformException catch (e) {
      log(e as String);
      rethrow;
    }
    log('controller enabled. Engine len: $engineLen. Engine hgt: $engineHgt');
    if (!_preparedIBO) {
      ibo = malloc.allocate(16);
      index = malloc.allocate(65535 * sizeOf<Int16>());
      var iCursor = 0;
      var vCursor = 0;
      for (var i = 0; i < 10500; i++) {
        _pushIndexFace(iCursor, vCursor, vCursor + 1, vCursor + 2, vCursor + 3);
        iCursor += 5;
        vCursor += 4;
      }
      gl
        ..glGenBuffers(1, ibo)
        ..glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo[0])
        ..glBufferData(GL_ELEMENT_ARRAY_BUFFER, 65535, index as Pointer<Void>,
            GL_STATIC_DRAW)
        ..glBufferSubData(
            GL_ELEMENT_ARRAY_BUFFER, 0, 65535, index as Pointer<Void>);
      _preparedIBO = true;
    }
    shader ??= JShader(gl: gl);
    texture ??= JTexture(gl: gl, shader: shader!);
    atoms ??= GraphicAtoms(texture: texture!);
    sprites ??= Sprites(atoms: atoms!);
    camera ??= JCamera(gl: gl, shader: shader!);
    camera?.init();
  }

  static final Engine _instance = Engine._constructor();

  static Engine get instance => _instance;

  void _pushIndexFace(int offset, int i0, int i1, int i2, int i3) {
    index[offset] = i0;
    index[offset + 1] = i1;
    index[offset + 2] = i2;
    index[offset + 3] = i3;
    index[offset + 4] = 65535;
  }

  void release() {}

  void beginRender() {
    if (controller.value.textureId == null) {
      return;
    }
    controller.beginDraw();
    gl
      ..glViewport(0, 0, engineLen ?? 512, engineHgt ?? 512)
      ..glEnable(GL_DEPTH_TEST)
      ..glDepthFunc(GL_LEQUAL)
      ..glEnable(GL_BLEND)
      ..glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    background?.render();
  }

  void render() {
    if (controller.value.textureId == null) {
      return;
    }
    shader?.useProgram(1);
    camera?.prepare();
    if (sprites != null) sprites!.render();
    controller.endDraw();
  }

  void update(double delta) {
    background?.update(delta);
    camera?.update(delta);
  }

  Widget draw(double wdt, double hgt) => Center(
        child: FittedBox(
          child: SizedBox(
            width: wdt,
            height: hgt,
            child: GLCanvas(
              controller: controller,
            ),
          ),
        ),
      );

  void init([void Function(double)? update]) {
    updateCallback = update;

    _previous = 0;
    isAnimation = true;
    animate();
  }

  void animate() {
    if (!isAnimation) return;
    final timestamp = DateTime.timestamp().microsecondsSinceEpoch;
    final durationDelta = timestamp - _previous;
    final dt = durationDelta / Duration.microsecondsPerSecond;
    _previous = timestamp;
    update(dt.clamp(0.0, 1.0));
    updateCallback?.call(dt.clamp(0.0, 1.0));
    beginRender();
    render();

    Future.delayed(const Duration(milliseconds: 17), animate);
  }
}
