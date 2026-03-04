import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart' as mlkit;

/// 手写识别服务
class HandwritingRecognitionService {
  static final HandwritingRecognitionService _instance = HandwritingRecognitionService._();
  static HandwritingRecognitionService get instance => _instance;

  HandwritingRecognitionService._();

  mlkit.DigitalInkRecognizer? _recognizer;
  bool _isModelDownloaded = false;
  final bool _isSupported = !Platform.isWindows && !Platform.isLinux;

  /// 初始化识别器（中文简体）
  Future<void> initialize() async {
    if (!_isSupported || _recognizer != null) return;

    const languageCode = 'zh';
    final modelManager = mlkit.DigitalInkRecognizerModelManager();

    // 检查模型是否已下载
    _isModelDownloaded = await modelManager.isModelDownloaded(languageCode);

    if (!_isModelDownloaded) {
      // 下载模型
      await modelManager.downloadModel(languageCode);
      _isModelDownloaded = true;
    }

    _recognizer = mlkit.DigitalInkRecognizer(languageCode: languageCode);
  }

  /// 识别笔画
  Future<List<String>> recognize(List<List<Offset>> strokes) async {
    if (!_isSupported) return [];

    if (_recognizer == null) {
      await initialize();
    }

    if (strokes.isEmpty) return [];

    final ink = mlkit.Ink();
    for (final stroke in strokes) {
      final mlkitStroke = mlkit.Stroke();
      for (var i = 0; i < stroke.length; i++) {
        mlkitStroke.points.add(mlkit.StrokePoint(
          x: stroke[i].dx,
          y: stroke[i].dy,
          t: DateTime.now().millisecondsSinceEpoch + i,
        ));
      }
      ink.strokes.add(mlkitStroke);
    }

    final candidates = await _recognizer!.recognize(ink);
    return candidates.map((c) => c.text).toList();
  }

  /// 释放资源
  void dispose() {
    _recognizer?.close();
    _recognizer = null;
  }
}
