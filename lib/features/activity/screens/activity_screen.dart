import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/common.dart';
import '../logic/activity_controller.dart';
import '../models/activity.dart';
import '../widgets/panels.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key, required this.activity});

  final VowelActivity activity;

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late final ActivityController _controller =
      ActivityController(widget.activity);
  bool _celebrated = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_maybeCelebrate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _maybeCelebrate() {
    if (_controller.isComplete && !_celebrated) {
      _celebrated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('You did it!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(widget.activity.image, height: 170),
                ),
                const SizedBox(height: 12),
                const Text('Every sentence is right and every word '
                    'is found. Time to celebrate!'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _celebrated = false;
                  _controller.reset();
                },
                child: const Text('Play again'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green),
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      });
    }
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.skyGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _topBar(),
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 800;
                  return wide ? _wideLayout() : _narrowLayout();
                }),
              ),
              _actionBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          const CircleBackButton(),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              widget.activity.title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _controller.reset,
              child: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: kCardShadow,
                ),
                child: const Icon(Icons.refresh_rounded,
                    color: AppColors.blue, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
              color: Color(0x12203A5C),
              blurRadius: 20,
              offset: Offset(0, -6)),
        ],
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Row(
          children: [
            Expanded(
              flex: 3,
              child: AppButton(
                label: 'Check sentences',
                icon: Icons.check_rounded,
                color: AppColors.green,
                onTap: _controller.checkSentences,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: AppButton(
                label: 'Reset',
                icon: Icons.refresh_rounded,
                outlined: true,
                onTap: _controller.reset,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Text(
          widget.activity.subtitle,
          style: const TextStyle(
              fontSize: 14.5, height: 1.35, color: AppColors.inkSoft),
        ),
      );

  Widget _progress() => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.blueSoft,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            'Words found: ${_controller.foundWords.length} / '
            '${widget.activity.words.length}',
            style: const TextStyle(
                fontWeight: FontWeight.w800, color: AppColors.blueDark),
          ),
        ),
      );

  Widget _illustration({double height = 150}) => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(widget.activity.image,
            height: height, fit: BoxFit.contain),
      );

  /// Phones: one scrollable column.
  Widget _narrowLayout() => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            WordBank(controller: _controller),
            const SizedBox(height: 16),
            Center(child: WordSearchGrid(controller: _controller)),
            Center(child: _progress()),
            const SizedBox(height: 4),
            SentenceList(controller: _controller),
            const SizedBox(height: 12),
            Center(child: _illustration(height: 140)),
          ],
        ),
      );

  /// Tablets/desktop: sentences left, puzzle + illustration right.
  Widget _wideLayout() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    WordBank(controller: _controller),
                    const SizedBox(height: 16),
                    SentenceList(controller: _controller),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    WordSearchGrid(controller: _controller),
                    _progress(),
                    _illustration(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
