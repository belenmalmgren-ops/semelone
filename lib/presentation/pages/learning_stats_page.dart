import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/user_data_repository.dart';
import '../../data/models/user_data.dart';

class LearningStatsPage extends ConsumerStatefulWidget {
  const LearningStatsPage({super.key});

  @override
  ConsumerState<LearningStatsPage> createState() => _LearningStatsPageState();
}

class _LearningStatsPageState extends ConsumerState<LearningStatsPage> {
  final _repo = UserDataRepository.instance;
  List<LearningProgress> _allProgress = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _repo.init();
    final progress = await _repo.getAllLearningProgress();
    setState(() {
      _allProgress = progress;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('学习统计')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildOverviewCard(),
                const SizedBox(height: 16),
                _buildMasteryDistribution(),
                const SizedBox(height: 16),
                _buildReviewList(),
              ],
            ),
    );
  }

  Widget _buildOverviewCard() {
    final total = _allProgress.length;
    final thisWeek = _allProgress.where((p) {
      final diff = DateTime.now().difference(p.lastReview);
      return diff.inDays <= 7;
    }).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('学习概览', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('累计学习', '$total 字'),
              _buildStatItem('本周学习', '$thisWeek 字'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildMasteryDistribution() {
    final distribution = <int, int>{};
    for (var p in _allProgress) {
      distribution[p.masteryLevel] = (distribution[p.masteryLevel] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('掌握程度分布', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...List.generate(6, (level) {
              final count = distribution[level] ?? 0;
              final percent = _allProgress.isEmpty ? 0.0 : count / _allProgress.length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(LearningProgress(
                        character: '',
                        lastReview: DateTime.now(),
                        masteryLevel: level,
                      ).masteryDescription),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('$count'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewList() {
    final needReview = _allProgress.where((p) => p.needsReview).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('待复习 (${needReview.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (needReview.isEmpty)
              const Center(child: Text('暂无待复习内容'))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: needReview.take(20).map((p) => Chip(label: Text(p.character))).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
