import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:opengl_es_bindings/opengl_es_bindings.dart';

import 'manager.dart';

class JShader {
  final manager = Manager();
  int positionSlot = -1;
  int textureSlot = -1;
  int colorSlot = -1;
  int bindtexture = 0;
  int cameraSlot = -1;
  int angle = -1;
  int cx = -1;
  int cy = -1;
  final LibOpenGLES gl;

  JShader({required this.gl});

  List<int> programsHandle = List.filled(256, -1);

  void release() {
    for (var q = 0; q < 256; q++) {
      if (programsHandle[q] != -1) deleteProgram(q);
    }
    programsHandle = List.filled(256, -1);
  }

  void prepareSlots(dynamic programHandle) {
    var ptr = 'vPosition'.toNativeUtf8();
    positionSlot = gl.glGetAttribLocation(programHandle, ptr.cast<Int8>());
    malloc.free(ptr);
    ptr = 'vTex'.toNativeUtf8();
    textureSlot = gl.glGetAttribLocation(programHandle, ptr.cast<Int8>());
    malloc.free(ptr);
    ptr = 'vColor'.toNativeUtf8();
    colorSlot = gl.glGetAttribLocation(programHandle, ptr.cast<Int8>());
    malloc.free(ptr);
    ptr = 'tTexture'.toNativeUtf8();
    bindtexture = gl.glGetUniformLocation(programHandle, ptr.cast<Int8>());
    malloc.free(ptr);
    ptr = 'camera'.toNativeUtf8();
    cameraSlot = gl.glGetUniformLocation(programHandle, ptr.cast<Int8>());
    malloc.free(ptr);
    ptr = 'angle'.toNativeUtf8();
    angle = gl.glGetAttribLocation(programHandle, ptr.cast<Int8>());
    malloc.free(ptr);
    ptr = 'cx'.toNativeUtf8();
    cx = gl.glGetAttribLocation(programHandle, ptr.cast<Int8>());
    malloc.free(ptr);
    ptr = 'cy'.toNativeUtf8();
    cy = gl.glGetAttribLocation(programHandle, ptr.cast<Int8>());
    malloc.free(ptr);
  }

  int stringShader(int type, String source) {
    final shader = gl.glCreateShader(type);
    if (shader == 0) {
      log('Error: failed to create shader.');
      return 0;
    }

    log('Loaded Shader');
    final shaderPtr = source.toNativeUtf8();
    final thePtr = malloc.allocate(sizeOf<Pointer>()) as Pointer<Pointer<Int8>>
      ..value = shaderPtr.cast<Int8>();
    gl.glShaderSource(shader, 1, thePtr, Pointer.fromAddress(0));
    malloc
      ..free(shaderPtr)
      ..free(thePtr);

    // Compile the shader
    gl.glCompileShader(shader);
    final infoLog = malloc.allocate(16384) as Pointer<Int8>;
    gl.glGetShaderInfoLog(shader, 1024, Pointer.fromAddress(0), infoLog);
    if (infoLog[0] != 0) {
      log(utf8.decode(infoLog.asTypedList(30)));
    }

    return shader;
  }

  int assetShader(int type, String shader) {
    final data = manager.getString(shader);
    return stringShader(type, data);
  }

  int assetProgram(String vertex, String fragment) {
    final vertexShader = assetShader(GL_VERTEX_SHADER, vertex);
    if (vertexShader == 0) {
      if (kDebugMode) {
        log('error vertex shader');
      }
      return 0;
    }

    final fragmentShader = assetShader(GL_FRAGMENT_SHADER, fragment);
    if (fragmentShader == 0) {
      gl.glDeleteShader(vertexShader);
      if (kDebugMode) {
        log('error fragment shader');
      }
      return 0;
    }

    // Create the program object
    final programHandle = gl.glCreateProgram();
    if (programHandle == 0) {
      if (kDebugMode) {
        log('error creating programm');
      }
      return 0;
    }

    gl
      ..glAttachShader(programHandle, vertexShader)
      ..glAttachShader(programHandle, fragmentShader)
      ..glLinkProgram(programHandle)
      ..glDeleteShader(vertexShader)
      ..glDeleteShader(fragmentShader);
    log('create program=$programHandle');
    return programHandle;
  }

  Future<void> loadProgram(int slot, String vertex, String fragment) async {
    await manager.loadAssetString('assets/shaders/', vertex);
    await manager.loadAssetString('assets/shaders/', fragment);
    programsHandle[slot] = assetProgram(vertex, fragment);
  }

  void useProgram(int slot) {
    gl.glUseProgram(programsHandle[slot]);
    prepareSlots(programsHandle[slot]);
    gl.glEnable(GL_PRIMITIVE_RESTART_FIXED_INDEX);
  }

  void deleteProgram(int slot) {
    gl.glDeleteProgram(programsHandle[slot]);
  }
}
