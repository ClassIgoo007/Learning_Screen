import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newtons_apple/animation/scene_timeline.dart';
import 'package:newtons_apple/app.dart';
import 'package:newtons_apple/screens/newton_scene_screen.dart';
import 'package:newtons_apple/widgets/formula_bubble.dart';
import 'package:newtons_apple/widgets/scene_stage_view.dart';

/// Wraps the screen so a specific [MediaQueryData] applies *inside* the
/// MaterialApp (an outer MediaQuery would be replaced by WidgetsApp).
Widget harness({bool reduceMotion = false}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: const NewtonSceneScreen(),
    ),
  );
}

/// Leaves the scene paused so no ticker is left running at teardown.
Future<void> pause(WidgetTester tester) async {
  final Finder pauseButton = find.text('Pause');
  if (pauseButton.evaluate().isNotEmpty) {
    await tester.tap(pauseButton);
    await tester.pump();
  }
}

void main() {
  testWidgets('the scene renders and starts playing', (WidgetTester t) async {
    await t.pumpWidget(const NewtonsAppleApp());
    await t.pump(const Duration(milliseconds: 100));

    expect(find.byType(SceneStageView), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);

    await pause(t);
  });

  testWidgets('play and pause toggle playback', (WidgetTester t) async {
    await t.pumpWidget(const NewtonsAppleApp());
    await t.pump(const Duration(milliseconds: 100));

    await t.tap(find.text('Pause'));
    await t.pump();
    expect(find.text('Play'), findsOneWidget);

    await t.tap(find.text('Play'));
    await t.pump();
    expect(find.text('Pause'), findsOneWidget);

    await pause(t);
  });

  testWidgets('narration follows the timeline', (WidgetTester t) async {
    await t.pumpWidget(const NewtonsAppleApp());
    await t.pump(const Duration(milliseconds: 60));
    expect(find.textContaining('Observation'), findsOneWidget);

    await t.pump(SceneTiming.total * 0.5);
    await t.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('Observation'), findsNothing);

    await pause(t);
  });

  testWidgets('scrubbing pauses playback', (WidgetTester t) async {
    await t.pumpWidget(const NewtonsAppleApp());
    await t.pump(const Duration(milliseconds: 100));

    await t.drag(find.byType(Slider), const Offset(200, 0));
    await t.pump();

    expect(find.text('Play'), findsOneWidget);
  });

  testWidgets('reduce motion lands on the final frame without animating',
      (WidgetTester t) async {
    await t.pumpWidget(harness(reduceMotion: true));
    await t.pump();

    expect(find.text('Play'), findsOneWidget);
    expect(find.byType(FormulaBubble), findsOneWidget);
    expect(find.text('F'), findsOneWidget);
    expect(find.textContaining('Universal gravitation'), findsOneWidget);
  });

  testWidgets('the equation is exposed to screen readers',
      (WidgetTester t) async {
    final SemanticsHandle handle = t.ensureSemantics();
    await t.pumpWidget(harness(reduceMotion: true));
    await t.pump();

    expect(
      find.bySemanticsLabel(RegExp('law of universal gravitation')),
      findsOneWidget,
    );
    handle.dispose();
  });
}
