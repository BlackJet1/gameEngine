import 'dart:convert';
import 'dart:developer';

import 'package:archive/archive.dart';

import 'model/textureatom_model.dart';
import 'texture.dart';

class GraphicAtoms {
  final JTexture texture;
  final Map<String, TextureAtom> _atoms = {};

  GraphicAtoms({required this.texture});

  String getTextureName(String name) => _atoms[name]?.textureName ?? '';

  Future<bool> loadAtomZip(Archive archive) async {
    const zipname = 'usingAtoms.txt';
    if (archive.files.where((element) => element.name == zipname).isEmpty) {
        log('usingAtoms.txt not found');
      return false;
    }
    final file = archive.files.firstWhere((element) => element.name == zipname);
    final decomp = utf8.decode(file.content);
    final dynamic json = jsonDecode(decomp);
    json.forEach((element) async {
      final name = element['name'];
      final data = element['atom'];
      final x1 = data['ix1'];
      final y1 = data['iy1'];
      final x2 = data['ix2'];
      final y2 = data['iy2'];
      final textureName = data['textureName'];
      final tId = texture.getTextureByName(textureName);
      final atom = TextureAtom(
          ix1: x1,
          iy1: y1,
          ix2: x2,
          iy2: y2,
          textureName: textureName,
          tl: tId?.len ?? 1,
          th: tId?.hgt ?? 1);
      _atoms.addAll({name: atom});
    });
    return true;
  }

  TextureAtom? getAtombyName(String name) => _atoms[name];

  void addAtom(String name, TextureAtom value) {
    if (_atoms.containsKey(name)) {
      _atoms.update(name, (value) => value);
      return;
    }
    _atoms.addAll({name: value});
  }
}
