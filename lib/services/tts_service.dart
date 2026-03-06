import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// TTS 语音朗读服务
class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  String? _availableLanguage;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        debugPrint('[TTS] 开始朗读');
      });
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        debugPrint('[TTS] 朗读完成');
      });
      _flutterTts.setErrorHandler((error) {
        _isSpeaking = false;
        debugPrint('[TTS] 错误：$error');
      });
      final languages = await _flutterTts.getLanguages;
      if (languages.contains('zh-CN')) {
        _availableLanguage = 'zh-CN';
      } else if (languages.contains('zh-HK')) {
        _availableLanguage = 'zh-HK';
      } else if (languages.contains('zh-TW')) {
        _availableLanguage = 'zh-TW';
      } else if (languages.isNotEmpty) {
        _availableLanguage = languages.first;
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('[TTS] 初始化失败：$e');
    }
  }

  Future<void> speak(String text, {double? rate, double? pitch}) async {
    if (!_isInitialized) await init();
    try {
      await stop();
      await _flutterTts.setSpeechRate(rate ?? 0.5);
      await _flutterTts.setPitch(pitch ?? 1.0);
      if (_availableLanguage != null) {
        await _flutterTts.setLanguage(_availableLanguage!);
      }
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('[TTS] 朗读失败：$e');
    }
  }

  Future<void> speakPinyin(String pinyin) async {
    if (!_isInitialized) await init();
    try {
      await stop();
      await _flutterTts.setSpeechRate(0.4);
      await _flutterTts.setPitch(1.0);
      final pinyinClean = pinyin.replaceAll(RegExp(r'[1-5]'), '');
      await _flutterTts.speak(pinyinClean);
    } catch (e) {
      debugPrint('[TTS] 拼音朗读失败：$e');
    }
  }

  Future<void> stop() async {
    if (!_isInitialized) return;
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      debugPrint('[TTS] 停止失败：$e');
    }
  }

  bool get isSpeaking => _isSpeaking;
  bool get isAvailable => _isInitialized;

  Future<void> dispose() async {
    try {
      await _flutterTts.stop();
      _isInitialized = false;
      _isSpeaking = false;
    } catch (e) {
      debugPrint('[TTS] 释放失败：$e');
    }
  }
}
