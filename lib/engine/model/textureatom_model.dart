class TextureAtom {
  // текстурные координаты
  late final double tx1;
  late final double ty1;
  late final double tx2;
  late final double ty2;
  final int ix1;
  final int iy1;
  final int ix2;
  final int iy2;
  final String textureName;
  final int th;
  final int tl;
  late final int len;
  late final int hgt;

  TextureAtom({
    required this.ix1,
    required this.iy1,
    required this.ix2,
    required this.iy2,
    required this.textureName,
    required this.tl,
    required this.th,
  }) {
    tx1 = ix1 / tl;
    ty1 = iy1 / th;
    tx2 = ix2 / tl;
    ty2 = iy2 / th;
    len = (ix1 - ix2).abs() + 1;
    hgt = (iy1 - iy2).abs() + 1;
  }

  factory TextureAtom.fromJson(Map<String, dynamic> json) {
    final ix1 = int.parse(json['ix1']);
    final iy1 = int.parse(json['iy1']);
    final ix2 = int.parse(json['ix2']);
    final iy2 = int.parse(json['iy2']);
    final tl = int.parse(json['tl']);
    final th = int.parse(json['th']);
    final textureName = json['texname'] as String;
    return TextureAtom(
      ix1: ix1,
      iy1: iy1,
      ix2: ix2,
      iy2: iy2,
      tl: tl,
      th: th,
      textureName: textureName,
    );
  }

  Map<String, dynamic> toJson() => {
        'ix1': ix1,
        'iy1': iy1,
        'ix2': ix2,
        'iy2': iy2,
        'len': len,
        'hgt': hgt,
        'tl': tl,
        'th': th,
        'textureName': textureName,
      };
}
