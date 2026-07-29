import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/common.dart';
import '../models/activity.dart';
import 'activity_screen.dart';

/// Intro/welcome screen for a vowel activity, mirroring the other games'
/// intro pages: a hero illustration, heading, and a play button.
class ActivityIntroScreen extends StatelessWidget {
  const ActivityIntroScreen({super.key, required this.activity});

  final VowelActivity activity;

  void _play(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActivityScreen(activity: activity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.skyGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              children: [
                const Row(
                  children: [
                    CircleBackButton(),
                    SizedBox(width: 14),
                    _Badge(),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        color: AppColors.ink,
                      ),
                      children: [
                        const TextSpan(text: 'Words with\n'),
                        TextSpan(
                            text: activity.name,
                            style: const TextStyle(color: AppColors.blue)),
                        const TextSpan(text: ' Activity'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    activity.tagline,
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.inkSoft),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Image.asset(
                      activity.image,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                AppButton(
                  label: 'Start Activity',
                  icon: Icons.search_rounded,
                  color: AppColors.blue,
                  onTap: () => _play(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: kCardShadow,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_stories_rounded, color: AppColors.green, size: 16),
          SizedBox(width: 6),
          Text('Sentences + Word Search',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}
