import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'package:archive/archive.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';

import 'package:opengl_es_bindings/opengl_es_bindings.dart';

import 'model/texture_model.dart';
import 'shaders.dart';

class JTexture {
  Map<String, Uint8List> imageData = {};
  Map<String, TextureModel> textures = {};
  final LibOpenGLES gl;
  final JShader shader;
  String currentTexture = '';

  JTexture({required this.gl, required this.shader});

  void bind(String name) {
    if (currentTexture == name) {
      return;
    }
    if (textures[name] == null) {
      throw Exception('texture $name not found');
    }
    final textureID = textures[name]!.textureID[0];

    gl
      ..glActiveTexture(GL_TEXTURE0)
      ..glBindTexture(GL_TEXTURE_2D, textureID)
      ..glUniform1i(shader.bindtexture, 0);
    currentTexture = name;
  }

  void release(String name) {
    if (textures[name] == null) {
      throw Exception('texture $name not found');
    }
    final texture = textures[name];
    gl.glDeleteTextures(1, texture!.textureID);
    malloc.free(texture.textureID);
  }

  Future<bool> loadImageAsset(String name) async {
    late ByteData data;
    try {
      final img = AssetImage('assets/images/$name');
      const config = ImageConfiguration.empty;
      final key = await img.obtainKey(config);
      data = await key.bundle.load(key.name);
    } on Exception catch (e) {
      if (kDebugMode) {
        log('$e\nimage $name not found in asset');
        return false;
      }
    }
    if (data.buffer.asUint8List().isEmpty) {
      if (kDebugMode) {
        log('image date $name not found in asset');
      }
      return false;
    }

    imageData.addAll({name: data.buffer.asUint8List()});
    if (kDebugMode) {
      log('loaded assets $name');
    }
    return true;
  }

  Future<bool> loadImageZip(String name, Archive archive) async {
    final zipname = 'textures/$name';
    if (archive.files.where((element) => element.name == zipname).isEmpty) {
      if (kDebugMode) {
        log('image $name not found');
      }
      return false;
    }
    final img = MemoryImage(
        archive.files.firstWhere((element) => element.name == zipname).content);

    final data = img.bytes;
    imageData.addAll({name: data.buffer.asUint8List()});

    if (kDebugMode) {
      log('loaded $name');
    }
    return true;
  }

  Future<bool> loadTexture(String name /*, Archive archive*/) async {
    final startTime = DateTime.now();
    if (kDebugMode) {
      log('loading texture $name');
    }

    /*
    if (textures[name] == null) {
      throw Exception('texture $name not found');
    }
    if (await loadImageZip(name, archive) == false) {
      if (kDebugMode) {
        log('PANIC!!! not found. All lost!');
      }
      return false;
    }

     */
    if (imageData[name] != null) {
      final image = decodePng(imageData[name]!);

      final w = image?.width ?? 0;
      final h = image?.height ?? 0;

      final src = image?.data?.buffer.asUint8List() ?? Uint8List(0);
      final allocator = Arena();
      final frameData = allocator
          .allocate<Uint8>(src.length); // Allocate a pointer large enough.
      frameData.asTypedList(src.length).setAll(0, src);
      final type = src.length > w * h * 3 ? 32 : 24;
      final texture = TextureModel(len: w, hgt: h, gl: gl);
      log('image type $type bit');
      gl
        ..glActiveTexture(GL_TEXTURE0)
        ..glBindTexture(GL_TEXTURE_2D, texture.textureID[0])
        ..glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
        ..glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
        ..glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
        ..glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
        ..glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGBA,
            GL_UNSIGNED_BYTE, frameData.cast());

      textures.addAll({name: texture});
      //prepare(name);
        log('loaded and decompressed in ${DateTime.now().difference(startTime).inMilliseconds / 1000}');
      return true;
    }
    return false;
  }

  TextureModel? getTextureByName(String name) => textures[name];

  Future<Archive> openZip() async {
    final data = await rootBundle.load('assets/resource.zip');
    final bytes = data.buffer.asUint8List();
    final archive = ZipDecoder().decodeBytes(bytes);
    return archive;
  }

  Future<List<String>> getZipTextures() async {
    final archive = await openZip();
    if (archive.files
        .where((element) => element.name == 'usingTextures.txt')
        .isEmpty) {
      if (kDebugMode) {
        print('usingTextures.txt not found');
        return [];
      }
    }
    final file = archive.files
        .firstWhere((element) => element.name == 'usingTextures.txt');
    final decomp = utf8.decode(file.content);
    final dynamic json = jsonDecode(decomp);
    final ret = List<String>.empty(growable: true);
    json.forEach((element) {
      ret.add(element.toString());
    });

    return ret;
  }
}
