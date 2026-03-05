import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 笔顺动画组件
/// 支持播放/暂停/速度调节/逐笔播放
class StrokeAnimationWidget extends StatefulWidget {
  /// SVG 字符串（可选，直接传入）
  final String? svgString;

  /// SVG 文件路径（可选，从 assets 加载）
  final String? svgPath;

  /// 汉字（用于显示）
  final String character;

  /// 自动播放
  final bool autoPlay;

  /// 笔画数量（用于显示进度）
  final int? strokeCount;

  const StrokeAnimationWidget({
    super.key,
    this.svgString,
    this.svgPath,
    required this.character,
    this.autoPlay = true,
    this.strokeCount,
  });

  @override
  State<StrokeAnimationWidget> createState() => _StrokeAnimationWidgetState();
}

class _StrokeAnimationWidgetState extends State<StrokeAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  bool _isPlaying = false;
  double _speed = 1.0;
  int _currentStroke = 0;
  int _totalStrokes = 5; // 默认 5 画

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    // 创建动画控制器
    _controller = AnimationController(
      duration: Duration(seconds: (5 * _speed).round()),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isPlaying = false;
        });
      }
    });

    if (widget.autoPlay) {
      _play();
    }
  }

  /// 播放动画
  void _play() {
    setState(() {
      _isPlaying = true;
    });
    _controller.forward(from: 0);
  }

  /// 暂停动画
  void _pause() {
    setState(() {
      _isPlaying = false;
    });
    _controller.stop();
  }

  /// 重置动画
  void _reset() {
    setState(() {
      _isPlaying = false;
      _currentStroke = 0;
    });
    _controller.stop();
    _controller.reset();
  }

  /// 播放下一笔
  void _nextStroke() {
    if (_currentStroke < _totalStrokes) {
      setState(() {
        _currentStroke++;
      });
    }
  }

  /// 播放上一笔
  void _prevStroke() {
    if (_currentStroke > 0) {
      setState(() {
        _currentStroke--;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF8D6E63).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // SVG 显示区域
          Expanded(
            flex: 3,
            child: _buildSvgArea(),
          ),
          // 控制按钮
          _buildControls(),
          // 进度条
          _buildProgress(),
        ],
      ),
    );
  }

  /// SVG 显示区域
  Widget _buildSvgArea() {
    if (widget.svgString != null) {
      return SvgPicture.string(
        widget.svgString!,
        fit: BoxFit.contain,
      );
    }

    if (widget.svgPath != null) {
      return SvgPicture.asset(
        widget.svgPath!,
        fit: BoxFit.contain,
      );
    }

    // 无数据时显示占位符
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.character,
            style: const TextStyle(
              fontSize: 80,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '笔顺动画数据暂缺',
            style: TextStyle(
              fontSize: 12,
              color: Colors.brown[300],
            ),
          ),
        ],
      ),
    );
  }

  /// 控制按钮
  Widget _buildControls() {
    return Expanded(
      flex: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 上一笔
          IconButton(
            icon: const Icon(Icons.skip_previous),
            onPressed: _currentStroke > 0 ? _prevStroke : null,
            tooltip: '上一笔',
            iconSize: 28,
          ),
          // 播放/暂停
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: _isPlaying ? _pause : _play,
            tooltip: _isPlaying ? '暂停' : '播放',
            iconSize: 36,
            color: const Color(0xFFD32F2F),
          ),
          // 下一笔
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed:
                _currentStroke < _totalStrokes ? _nextStroke : null,
            tooltip: '下一笔',
            iconSize: 28,
          ),
          // 重置
          IconButton(
            icon: const Icon(Icons.replay),
            onPressed: _reset,
            tooltip: '重置',
            iconSize: 24,
          ),
          // 速度调节
          PopupMenuButton<double>(
            icon: Text(
              '${_speed}x',
              style: const TextStyle(fontSize: 14),
            ),
            onSelected: (speed) {
              setState(() {
                _speed = speed;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 0.5, child: Text('0.5x 慢速')),
              const PopupMenuItem(value: 1.0, child: Text('1.0x 正常')),
              const PopupMenuItem(value: 1.5, child: Text('1.5x 快速')),
              const PopupMenuItem(value: 2.0, child: Text('2.0x 极速')),
            ],
          ),
        ],
      ),
    );
  }

  /// 进度条
  Widget _buildProgress() {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              '$_currentStroke/$_totalStrokes',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _currentStroke / _totalStrokes,
                  backgroundColor: Colors.brown[100],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFD32F2F),
                  ),
                  minHeight: 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 笔顺数据加载器
class StrokeDataLoader {
  static final Map<String, String> _cache = {};

  /// 从 assets 加载 SVG
  static Future<String?> loadSvg(String character) async {
    if (_cache.containsKey(character)) {
      return _cache[character]!;
    }

    try {
      // 从 assets 加载 SVG 文件
      // 需要在 pubspec.yaml 中配置 assets/strokes/
      final svg = await rootBundle.loadString(
        'assets/strokes/$character.svg',
      );
      _cache[character] = svg;
      return svg;
    } catch (e) {
      // 文件不存在
      return null;
    }
  }

  /// 清除缓存
  static void clearCache() {
    _cache.clear();
  }
}
