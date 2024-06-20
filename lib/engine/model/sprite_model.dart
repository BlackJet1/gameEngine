import 'dart:ui';

import 'package:flutter/material.dart';

class SpriteModel {
  final int id;
  final int x;
  final int y;
  final int z;
  final int len;
  final int hgt;
  final double angle;
  final Color color;
  final int cx;
  final int cy;

  final String atom;

  SpriteModel({
    required this.id,
    required this.x,
    required this.y,
    required this.z,
    required this.len,
    required this.hgt,
    required this.atom,
    this.cx = 0,
    this.cy = 0,
    this.angle = 0,
    this.color = const Color(0xFFFFFFFF),
  });

  factory SpriteModel.copyWith(SpriteModel source, {
    int? x,
    int? y,
    int? z,
    int? len,
    int? hgt,
    int? cx,
    int? cy,
    double? angle,
    Color? color,
    String? atom
  }) =>
      SpriteModel(
        id: source.id,
        x: x ?? source.x,
        y: y ?? source.y,
        z: z ?? source.z,
        len: len ?? source.len,
        hgt: hgt ?? source.hgt,
        atom: atom ?? source.atom,
        cx: cx ?? source.cx,
        cy: cy ?? source.cy,
        angle: angle ?? source.angle,
        color: color ?? source.color,
      );
}
