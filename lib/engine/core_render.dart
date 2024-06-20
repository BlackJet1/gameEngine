import 'dart:developer';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';

import 'package:opengl_es_bindings/opengl_es_bindings.dart';

import 'atoms.dart';
import 'engine.dart';
import 'shaders.dart';

/*
0,1,2 - x,y,z
3,4 - tx, ty
5,6,7,8 - r,g,b,a
9, 10 - center x, center y
11 - angle
 */
class CoreRender {
  final LibOpenGLES gl;
  final JShader shader;
  final GraphicAtoms atoms;

  final Pointer<Float> vertices =
      malloc.allocate(65535 * Engine.vertexBufferSizeBytes);

  final Map<int, int> usingOffsets = {};

  CoreRender({required this.gl, required this.shader, required this.atoms});

  void insertQuad(
      {required int id,
      required int cx,
      required int cy,
      required int x,
      required int y,
      required int z,
      required int len,
      required int hgt,
      required double angle,
      required String atom,
      required Color color}) {
    final currentAtom = atoms.getAtombyName(atom);
    if (currentAtom == null) {
      return;
    }
    final currentOffset = usingOffsets.length * Engine.vertexBufferSize * 4;
    usingOffsets[id] = currentOffset;
    final offset = currentOffset;
    final xl = x - len / 2;
    final xr = x + len / 2;
    final yb = y - hgt / 2;
    final yt = y + hgt / 2;
    final zz = z / 100;
    final ax = (cx * len + x).toDouble();
    final ay = (cy * hgt + y).toDouble();
    final r = color.red / 255;
    final g = color.green / 255;
    final b = color.blue / 255;
    final a = color.alpha / 255;
    final texL = currentAtom.tx1;
    final texR = currentAtom.tx2;
    final texU = currentAtom.ty1;
    final texD = currentAtom.ty2;
    vertices[offset + 0] = xl;
    vertices[offset + 1] = yb;
    vertices[offset + 2] = zz;
    vertices[offset + 3] = texL;
    vertices[offset + 4] = texD;
    vertices[offset + 5] = r;
    vertices[offset + 6] = g;
    vertices[offset + 7] = b;
    vertices[offset + 8] = a;
    vertices[offset + 9] = ax;
    vertices[offset + 10] = ay;
    vertices[offset + 11] = angle;

    vertices[offset + 12] = xl;
    vertices[offset + 13] = yt;
    vertices[offset + 14] = zz;
    vertices[offset + 15] = texL;
    vertices[offset + 16] = texU;
    vertices[offset + 17] = r;
    vertices[offset + 18] = g;
    vertices[offset + 19] = b;
    vertices[offset + 20] = a;
    vertices[offset + 21] = ax;
    vertices[offset + 22] = ay;
    vertices[offset + 23] = angle;

    vertices[offset + 24] = xr;
    vertices[offset + 25] = yt;
    vertices[offset + 26] = zz;
    vertices[offset + 27] = texR;
    vertices[offset + 28] = texU;
    vertices[offset + 29] = r;
    vertices[offset + 30] = g;
    vertices[offset + 31] = b;
    vertices[offset + 32] = a;
    vertices[offset + 33] = ax;
    vertices[offset + 34] = ay;
    vertices[offset + 35] = angle;

    vertices[offset + 36] = xr;
    vertices[offset + 37] = yb;
    vertices[offset + 38] = zz;
    vertices[offset + 39] = texR;
    vertices[offset + 40] = texD;
    vertices[offset + 41] = r;
    vertices[offset + 42] = g;
    vertices[offset + 43] = b;
    vertices[offset + 44] = a;
    vertices[offset + 45] = ax;
    vertices[offset + 46] = ay;
    vertices[offset + 47] = angle;
  }

  int getOffsetByID({required int id}) => usingOffsets[id] ?? -1;

  void updatePosition(int id, int ox, int oy, int z) {
    final offset = getOffsetByID(id: id);
    if (offset == -1) {
      log('No offset for $id');
      return;
    }
    vertices[offset + 2] = z / 100;
    vertices[offset + 14] = z / 100;
    vertices[offset + 26] = z / 100;
    vertices[offset + 38] = z / 100;

    vertices[offset + 0] += ox.toDouble();
    vertices[offset + 1] += oy.toDouble();
    vertices[offset + 12] += ox.toDouble();
    vertices[offset + 13] += oy.toDouble();
    vertices[offset + 24] += ox.toDouble();
    vertices[offset + 25] += oy.toDouble();
    vertices[offset + 36] += ox.toDouble();
    vertices[offset + 37] += oy.toDouble();
  }

  void updateColor(int id, Color color) {
    final offset = getOffsetByID(id: id);
    if (offset == -1) {
      log('No offset for $id');
      return;
    }
    vertices[offset + 5] = color.red / 255;
    vertices[offset + 6] = color.green / 255;
    vertices[offset + 7] = color.blue / 255;
    vertices[offset + 8] = color.alpha / 255;

    vertices[offset + 17] = color.red / 255;
    vertices[offset + 18] = color.green / 255;
    vertices[offset + 19] = color.blue / 255;
    vertices[offset + 20] = color.alpha / 255;

    vertices[offset + 29] = color.red / 255;
    vertices[offset + 30] = color.green / 255;
    vertices[offset + 31] = color.blue / 255;
    vertices[offset + 32] = color.alpha / 255;

    vertices[offset + 41] = color.red / 255;
    vertices[offset + 42] = color.green / 255;
    vertices[offset + 43] = color.blue / 255;
    vertices[offset + 44] = color.alpha / 255;
  }

  void updateAlpha(int id, int alpha) {
    final a = alpha / 255;
    final offset = getOffsetByID(id: id);
    if (offset == -1) {
      log('No offset for $id');
      return;
    }
    vertices[offset + 8] = a;
    vertices[offset + 20] = a;
    vertices[offset + 32] = a;
    vertices[offset + 44] = a;
  }

  void updateCenter(int id, int cx, int cy) {
    final offset = getOffsetByID(id: id);
    if (offset == -1) {
      log('No offset for $id');
      return;
    }
    vertices[offset + 9] = cx.toDouble();
    vertices[offset + 21] = cx.toDouble();
    vertices[offset + 33] = cx.toDouble();
    vertices[offset + 45] = cx.toDouble();
    vertices[offset + 10] = cy.toDouble();
    vertices[offset + 22] = cy.toDouble();
    vertices[offset + 34] = cy.toDouble();
    vertices[offset + 46] = cy.toDouble();
  }

  void updateAngle(int id, double angle) {
    final offset = getOffsetByID(id: id);
    if (offset == -1) {
      log('No offset for $id');
      return;
    }
    vertices[offset + 11] = angle;
    vertices[offset + 23] = angle;
    vertices[offset + 35] = angle;
    vertices[offset + 47] = angle;
  }

  void render() {
    gl
      ..glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, Engine.ibo[0])
      ..glBufferData(GL_ELEMENT_ARRAY_BUFFER, 65535,
          Engine.index as Pointer<Void>, GL_STATIC_DRAW)
      ..glBufferSubData(
          GL_ELEMENT_ARRAY_BUFFER, 0, 65535, Engine.index as Pointer<Void>)
      ..glEnableVertexAttribArray(shader.positionSlot)
      ..glEnableVertexAttribArray(shader.textureSlot)
      ..glEnableVertexAttribArray(shader.colorSlot)
      ..glEnableVertexAttribArray(shader.angle)
      ..glEnableVertexAttribArray(shader.cx)
      ..glEnableVertexAttribArray(shader.cy)
      ..glVertexAttribPointer(shader.angle, 1, GL_FLOAT, GL_FALSE,
          Engine.vertexBufferSizeBytes, (vertices + 11).cast<Void>())
      ..glVertexAttribPointer(shader.cx, 1, GL_FLOAT, GL_FALSE,
          Engine.vertexBufferSizeBytes, (vertices + 9).cast<Void>())
      ..glVertexAttribPointer(shader.cy, 1, GL_FLOAT, GL_FALSE,
          Engine.vertexBufferSizeBytes, (vertices + 10).cast<Void>())
      ..glVertexAttribPointer(shader.positionSlot, 3, GL_FLOAT, GL_FALSE,
          Engine.vertexBufferSizeBytes, vertices.cast<Void>())
      ..glVertexAttribPointer(shader.textureSlot, 2, GL_FLOAT, GL_FALSE,
          Engine.vertexBufferSizeBytes, (vertices + 3).cast<Void>())
      ..glVertexAttribPointer(shader.colorSlot, 4, GL_FLOAT, GL_FALSE,
          Engine.vertexBufferSizeBytes, (vertices + 5).cast<Void>())
      //..glDrawElements(GL_TRIANGLE_FAN, filteredScene.length * 5, GL_UNSIGNED_SHORT, nullptr)
      ..glDrawElementsInstanced(GL_TRIANGLE_FAN, usingOffsets.length * 5,
          GL_UNSIGNED_SHORT, nullptr, 1)
      ..glDisableVertexAttribArray(shader.angle)
      ..glDisableVertexAttribArray(shader.cx)
      ..glDisableVertexAttribArray(shader.cy)
      ..glDisableVertexAttribArray(shader.positionSlot)
      ..glDisableVertexAttribArray(shader.colorSlot)
      ..glDisableVertexAttribArray(shader.textureSlot);
  }
}
