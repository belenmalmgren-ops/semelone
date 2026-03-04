import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/repositories/dict_repository.dart';
import '../../services/handwriting_recognition_service.dart';
import 'character_detail_page.dart';

/// 手写识别页面
/// 支持手写输入汉字，自动识别后搜索
class HandwritingSearchPage extends StatefulWidget {
  const HandwritingSearchPage({super.key});

  @override
  State<HandwritingSearchPage> createState() => _HandwritingSearchPageState();
}

class _HandwritingSearchPageState extends State<HandwritingSearchPage> {
  final DictRepository _repository = DictRepository.instance;
  final HandwritingRecognitionService _recognitionService = HandwritingRecognitionService.instance;

  // 手写板相关
  List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  Size _canvasSize = Size.zero;

  // 识别结果
  List<String> _candidates = [];
  bool _isRecognizing = false;

  @override
  void initState() {
    super.initState();
    _recognitionService.initialize();
  }

  @override
  void dispose() {
    _recognitionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildCanvas(),
          _buildCandidates(),
          _buildInstructions(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF3E2723),
      title: const Text(
        '手写输入',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _clearCanvas,
          tooltip: '重写',
        ),
        IconButton(
          icon: const Icon(Icons.backspace, color: Colors.white),
          onPressed: _undoStroke,
          tooltip: '撤销上一笔',
        ),
      ],
    );
  }

  /// 手写画布
  Widget _buildCanvas() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3E2723),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '请在下方区域书写汉字',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF3E2723),
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Container(
              width: double.infinity,
              height: 250.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF8D6E63).withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomPaint(
                  painter: HandwritingPainter(_strokes),
                  size: _canvasSize,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _recognize,
                icon: const Icon(Icons.search),
                label: const Text('识别'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              OutlinedButton.icon(
                onPressed: _clearCanvas,
                icon: const Icon(Icons.clear),
                label: const Text('清除'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3E2723),
                  side: const BorderSide(color: Color(0xFF3E2723)),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 候选字区域
  Widget _buildCandidates() {
    if (_candidates.isEmpty && !_isRecognizing) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF8D6E63),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '识别结果',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
          SizedBox(height: 8.h),
          if (_isRecognizing)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _candidates.map((candidate) {
                return GestureDetector(
                  onTap: () => _selectCandidate(candidate),
                  child: Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F1E8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF3E2723),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        candidate,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF3E2723),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  /// 使用说明
  Widget _buildInstructions() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit,
              size: 64.w,
              color: const Color(0xFF8D6E63).withOpacity(0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              '用手指或触控笔书写汉字\n系统将自动识别并显示候选字',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF8D6E63).withOpacity(0.6),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 手写板逻辑 ====================

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _currentStroke = [details.localPosition];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentStroke.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _strokes.add(List.from(_currentStroke));
      _currentStroke = [];
    });
  }

  /// 识别手写内容
  Future<void> _recognize() async {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先书写汉字')),
      );
      return;
    }

    setState(() {
      _isRecognizing = true;
    });

    try {
      final results = await _recognitionService.recognize(_strokes);
      setState(() {
        _candidates = results.take(8).toList();
        _isRecognizing = false;
      });
    } catch (e) {
      setState(() {
        _isRecognizing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('识别失败: $e')),
        );
      }
    }
  }

  /// 选择候选字
  Future<void> _selectCandidate(String character) async {
    // 搜索该汉字
    final result = await _repository.getByChar(character);
    if (result != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CharacterDetailPage(character: result),
        ),
      );
    }
  }

  /// 清除画布
  void _clearCanvas() {
    setState(() {
      _strokes = [];
      _currentStroke = [];
      _candidates = [];
    });
  }

  /// 撤销上一笔
  void _undoStroke() {
    setState(() {
      if (_strokes.isNotEmpty) {
        _strokes.removeLast();
      }
    });
  }
}

/// 手写板绘制器
class HandwritingPainter extends CustomPainter {
  final List<List<Offset>> strokes;

  HandwritingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3E2723)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final stroke in strokes) {
      if (stroke.length > 1) {
        for (int i = 0; i < stroke.length - 1; i++) {
          canvas.drawLine(stroke[i], stroke[i + 1], paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant HandwritingPainter oldDelegate) => true;
}
