import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'package:opengl_es_bindings/opengl_es_bindings.dart';

class TextureModel {
  final int len;
  final int hgt;
  late Pointer<Uint32> textureID;
  final LibOpenGLES gl;

  TextureModel({required this.len, required this.hgt, required this.gl}) {
    textureID = malloc.allocate(64);
    gl.glGenTextures(1, textureID.cast());
  }
}
