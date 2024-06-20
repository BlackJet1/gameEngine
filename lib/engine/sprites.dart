import 'dart:ui';

import 'atoms.dart';
import 'core_render.dart';
import 'model/sprite_model.dart';
import 'texture.dart';

class Sprites {
  int currentIdCursor = 0;
  int currentOffsetCursor = 0;
  late final JTexture texture;
  final GraphicAtoms atoms;
  List<SpriteModel> sprites = List<SpriteModel>.empty(growable: true);

  SpriteModel? getById(int id) =>
      sprites.where((element) => element.id == id).firstOrNull;

  final Map<String, CoreRender> _renderer = {}; // разделяем по текстурам
  //late final CoreRender _renderer;

  Sprites({required this.atoms}) {
    texture = atoms.texture;
    //_renderer = CoreRender(gl: texture.gl, shader: texture.shader, textureName: texture.textureName);
  }

  void clear() {
    sprites.clear();
    _renderer.forEach((key, value) {
      value.usingOffsets.clear();
    });
    currentIdCursor = 0;
    _renderer.clear();
  }

  void init() {
    clear();
  }

  void render() {
    if (sprites.isEmpty) {
      return;
    }
    for (final r in _renderer.entries) {
      texture.bind(r.key);
      r.value.render();
    }
  }

  void update() {}

  void move(int id, int ox, int oy, int oz) {
    final sprite = sprites.where((element) => element.id == id);
    if (sprite.isEmpty) {
      return;
    }
    final x = sprite.first.x + ox;
    final y = sprite.first.y + oy;
    final z = sprite.first.z + oz;
    final newSprite = SpriteModel.copyWith(sprite.first, x: x, y: y, z: z);
    final textureName = atoms.getTextureName(sprite.first.atom);
    final r = _renderer[textureName];
    if (r == null) {
      return;
    }
    sprites
      ..removeWhere((element) => element.id == id)
      ..add(newSprite);
    r.updatePosition(id, ox, oy, z);
  }

  void updatePosition(int id, int x, int y, int z) {
    final sprite = sprites.where((element) => element.id == id);
    if (sprite.isEmpty) {
      return;
    }
    final newSprite = SpriteModel.copyWith(sprite.first, x: x, y: y);
    final textureName = atoms.getTextureName(sprite.first.atom);
    final r = _renderer[textureName];
    if (r == null) {
      return;
    }
    final ox = x - sprite.first.x;
    final oy = y - sprite.first.y;
    sprites
      ..removeWhere((element) => element.id == id)
      ..add(newSprite);
    r.updatePosition(id, ox, oy, z);
  }

  void updateColor(int id, Color color) {
    final sprite = sprites.where((element) => element.id == id);
    if (sprite.isEmpty) {
      return;
    }
    final newSprite = SpriteModel.copyWith(sprite.first, color: color);
    final textureName = atoms.getTextureName(sprite.first.atom);
    final r = _renderer[textureName];
    if (r == null) {
      return;
    }
    sprites
      ..removeWhere((element) => element.id == id)
      ..add(newSprite);
    r.updateColor(id, color);
  }

  void updateAlpha(int id, int alpha) {
    final sprite = sprites.where((element) => element.id == id);
    if (sprite.isEmpty) {
      return;
    }
    final color = sprite.first.color.withAlpha(alpha);
    final newSprite = SpriteModel.copyWith(sprite.first, color: color);
    final textureName = atoms.getTextureName(sprite.first.atom);
    final r = _renderer[textureName];
    if (r == null) {
      return;
    }
    sprites
      ..removeWhere((element) => element.id == id)
      ..add(newSprite);
    r.updateAlpha(id, alpha);
  }

  void updateAnchor(int id, int cx, int cy) {
    final sprite = sprites.where((element) => element.id == id);
    if (sprite.isEmpty) {
      return;
    }
    final newSprite = SpriteModel.copyWith(sprite.first, cx: cx, cy: cy);
    final textureName = atoms.getTextureName(sprite.first.atom);
    final r = _renderer[textureName];
    if (r == null) {
      return;
    }
    sprites
      ..removeWhere((element) => element.id == id)
      ..add(newSprite);
    r.updateCenter(id, cx, cy);
  }

  void updateAngle(int id, double angle) {
    if (id == -1) {
      return;
    }
    final sprite = sprites.where((element) => element.id == id);
    if (sprite.isEmpty) {
      return;
    }
    final newSprite = SpriteModel.copyWith(sprite.first, angle: angle);
    final textureName = atoms.getTextureName(sprite.first.atom);
    final r = _renderer[textureName];
    if (r == null) {
      return;
    }
    sprites
      ..removeWhere((element) => element.id == id)
      ..add(newSprite);
    r.updateAngle(id, angle);
  }

  int add(
      {required int x,
      required int y,
      required int z,
      required int len,
      required int hgt,
      required String atom,
      int cx = 0,
      int cy = 0,
      double angle = 0,
      Color color = const Color(0xFFFFFFFF)}) {
    final textureName = atoms.getTextureName(atom);
    if (textureName.isEmpty) {
      return -1;
    }
    /*
    1) пролучить id
    2) создать и добавить модель
    3) добавить вершины в рендерер
     */
    final id = currentIdCursor++;
    final sprite = SpriteModel(
        id: id,
        x: x,
        y: y,
        z: z,
        len: len,
        hgt: hgt,
        atom: atom,
        angle: angle,
        color: color);
    sprites.add(sprite);
    _renderer
        .putIfAbsent(
            textureName,
            () => CoreRender(
                  gl: texture.gl,
                  shader: texture.shader,
                  atoms: atoms,
                ))
        .insertQuad(
          id: id,
          x: x,
          y: y,
          z: z,
          len: len,
          hgt: hgt,
          angle: angle,
          color: color,
          cx: cx,
          cy: cy,
          atom: atom,
        );

    return id;
  }
}
