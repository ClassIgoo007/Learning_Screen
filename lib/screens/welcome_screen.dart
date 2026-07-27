import 'package:flutter/material.dart';

import '../models/worksheet.dart';
import '../services/openai_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'quiz_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.openAI,
    required this.tts,
  });

  final OpenAIService openAI;
  final TtsService tts;

  void _start(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          worksheet: kDefaultWorksheet,
          openAI: openAI,
          tts: tts,
        ),
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
                const _SafeBadge(),
                const SizedBox(height: 20),
                const _Headline(),
                const SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'assets/mascot_welcome.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                AppButton(
                  label: "Let's Get a Fresh Start",
                  icon: Icons.rocket_launch_rounded,
                  color: AppColors.blue,
                  onTap: () => _start(context),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Resume Journey',
                  outlined: true,
                  onTap: () => _start(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SafeBadge extends StatelessWidget {
  const _SafeBadge();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: kCardShadow,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_user_rounded,
                color: AppColors.green, size: 16),
            SizedBox(width: 6),
            Text('100% Kids Safe',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: const TextSpan(
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.15,
            color: AppColors.ink,
          ),
          children: [
            TextSpan(text: 'Learn '),
            TextSpan(text: 'Phonics', style: TextStyle(color: AppColors.blue)),
            TextSpan(text: ' at\nLightning Speed'),
          ],
        ),
      ),
    );
  }
}
