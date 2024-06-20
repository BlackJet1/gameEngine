import 'dart:math';

import 'package:flutter/material.dart';

import '../engine/background.dart';
import '../engine/engine.dart';
import '../engine/model/textureatom_model.dart';

class JGame extends StatefulWidget {
  const JGame({super.key});

  @override
  State<StatefulWidget> createState() => JGameState();
}

class JGameState extends State<JGame> with WidgetsBindingObserver {
  final engine = Engine.instance;
  final sprites = Engine.instance.sprites!;
  final atoms = Engine.instance.atoms!;
  final texture = Engine.instance.texture!;
  final camera = Engine.instance.camera!;
  int spr1 = 0;
  int spr2 = 0;
  int spr3 = 0;
  double angle = 0;
  double cx = 0;
  double cy = 0;
  double cxw = 1;
  double cyw = 1;

  Future<void> init() async {
    atoms
      ..addAtom(
          'test',
          TextureAtom(
              ix1: 0,
              iy1: 0,
              ix2: 2047,
              iy2: 2047,
              textureName: 'atlas.png',
              tl: 2048,
              th: 2048))
      ..addAtom(
          'test1',
          TextureAtom(
              ix1: 0,
              iy1: 0,
              ix2: 127,
              iy2: 127,
              textureName: 'atlas.png',
              tl: 2048,
              th: 2048))
      ..addAtom(
          'bgr',
          TextureAtom(
              ix1: 0,
              iy1: 0,
              ix2: 699,
              iy2: 699,
              textureName: 'bgr.png',
              tl: 700,
              th: 700));
    engine
      ..background = Background.clear(color: Colors.black)
      ..init(update);
    await texture.loadImageAsset('bgr.png');
    await texture.loadImageAsset('atlas.png');
    await engine.shader?.loadProgram(1, '2d.vsh', '2d.fsh');
    await texture.loadTexture('atlas.png');
    await texture.loadTexture('bgr.png');
    for (var i = 0; i < 2000; i++) {
      sprites.add(
          x: i * 8,
          y: i * 8,
          z: 16,
          len: 16 + i,
          hgt: 16 + i,
          atom: i.isEven ? 'bgr' : 'test1');
    }
    spr1 = sprites.add(
        x: 360,
        y: 640,
        z: 10,
        len: 100,
        hgt: 100,
        color: Colors.green,
        atom: 'test');
    spr3 = sprites.add(
        x: 360,
        y: 640,
        z: 100,
        len: 700,
        hgt: 1260,
        color: Colors.white,
        atom: 'bgr');
    sprites
      ..add(x: 0, y: 0, z: 0, len: 200, hgt: 200, atom: 'test1')
      ..add(x: 720, y: 0, z: 0, len: 200, hgt: 200, atom: 'test1')
      ..add(x: 0, y: 1280, z: 0, len: 200, hgt: 200, atom: 'test1')
      ..add(x: 720, y: 1280, z: 0, len: 200, hgt: 200, atom: 'test1');
    spr2 = sprites.add(
        x: 512,
        y: 400,
        z: 50,
        len: 500,
        hgt: 500,
        color: Colors.amber,
        atom: 'test');
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    init();
  }

  Future<void> prepare() async {
    await Future.delayed(const Duration(seconds: 1));
    sprites.clear();
    await init();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (engine.shader?.programsHandle[1] == -1) {
      prepare();
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    final hgt = MediaQuery.of(context).size.height;
    final len = hgt / 16 * 9;

    return engine.draw(len, hgt);
  }

  void update(double delta) {
    cx += delta * 100 * cxw;
    cy += delta * 100 * cyw;
    if (cx > 360) {
      cxw = -1;
    }
    if (cx < -360) {
      cxw = 1;
    }
    if (cy > 640) {
      cyw = -1;
    }
    if (cy < -640) {
      cyw = 1;
    }
    camera.pos.x = cx;
    camera.pos.y = cy;
    angle += 0.01;
    if (angle > 2 * pi) {
      angle -= 2 * pi;
    }
    sprites
      ..updateAngle(spr3, angle * 10)
      ..updateAngle(spr1, angle)
      ..updateAngle(spr2, angle * 5);
  }
}
