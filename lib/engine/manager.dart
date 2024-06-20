import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Manager {
  Map<String, String> textData = {};

  void init() {
    textData.clear();
  }

  Future<String> _loadString(String name) => rootBundle.loadString(name);

  Future<void> loadAssetString(String path, String name) async {
    if (textData[name] != null) {
      log('manager=> already loaded $path$name');
      return;
    }
    final data = await _loadString('$path$name');
    if (data.isNotEmpty) {
      textData.addAll({name: data});
      if (kDebugMode) {
        log('manager=> loaded $path$name');
      }
    } else {
      log('error loading $path$name');
    }
  }

  String getString(String name) {
    if (textData[name] != null) {
      if (kDebugMode) {
        log('manager=> get $name');
      }
      return textData[name]!;
    }
    if (kDebugMode) {
      log('error get string $name');
    }
    return '';
  }
}
