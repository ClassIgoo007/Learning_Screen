import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bernoulli_venturi/app.dart';
import 'package:bernoulli_venturi/screens/home_screen.dart';
import 'package:bernoulli_venturi/theme/app_theme.dart';
import 'package:bernoulli_venturi/models/content.dart';
import 'package:bernoulli_venturi/physics/venturi.dart';
import 'package:bernoulli_venturi/screens/quiz_screen.dart';
import 'package:bernoulli_venturi/screens/simulation_screen.dart';
import 'package:bernoulli_venturi/widgets/venturi_figure.dart';

void main() {
  group('app shell', () {
    testWidgets('starts on the home screen and shows the figure',
        (tester) async {
      await tester.pumpWidget(const BernoulliApp());
      await tester.pump();

      expect(find.text("Bernoulli's Principle"), findsOneWidget);
      expect(find.byType(VenturiFigure), findsOneWidget);
      expect(find.textContaining('pressure is lower in the narrow part'),
          findsOneWidget);
    });

    testWidgets('navigates to the simulation and back', (tester) async {
      await tester.pumpWidget(const BernoulliApp());
      await tester.pump();

      await tester.ensureVisible(find.text('Run the experiment'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Run the experiment'));
      await tester.pumpAndSettle();
      expect(find.byType(SimulationScreen), findsOneWidget);
      expect(find.byType(Slider), findsNWidgets(2));

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(SimulationScreen), findsNothing);
    });

    testWidgets('navigates to the questions', (tester) async {
      await tester.pumpWidget(const BernoulliApp());
      await tester.pump();

      await tester.ensureVisible(find.text('Questions & answers'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Questions & answers'));
      await tester.pumpAndSettle();
      expect(find.byType(QuizScreen), findsOneWidget);
      expect(find.text(kQuizQuestions.first.question), findsOneWidget);
    });

    testWidgets('renders in dark mode without throwing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark(), home: const HomeScreen()),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(VenturiFigure), findsOneWidget);
    });
  });

  group('simulation screen', () {
    testWidgets('dragging the flow slider changes the readouts',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SimulationScreen()));
      await tester.pump();

      const startingSpeed = VenturiModel();
      final before =
          '${startingSpeed.throatSpeed.toStringAsFixed(2)} m/s';
      expect(find.text(before), findsWidgets);

      // Drag the flow slider to the far left: everything should slow down.
      await tester.drag(find.byType(Slider).first, const Offset(-500, 0));
      await tester.pump();

      expect(find.text(before), findsNothing);
      expect(find.text('Speed, throat'), findsOneWidget);
    });

    testWidgets('pause button toggles and the figure keeps rendering',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SimulationScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.pause), findsOneWidget);
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump();
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Let the ticker settle and go to sleep; nothing should blow up.
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
      expect(find.byType(VenturiFigure), findsOneWidget);
    });

    testWidgets('reduce-motion disables the play control', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: SimulationScreen(),
          ),
        ),
      );
      await tester.pump();

      final button = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.pause),
          matching: find.byType(IconButton),
        ),
      );
      expect(button.onPressed, isNull);
      expect(find.textContaining('reduce motion'), findsOneWidget);
    });

    testWidgets('the figure carries a spoken description', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(const MaterialApp(home: SimulationScreen()));
      await tester.pump();

      expect(
        find.bySemanticsLabel(RegExp('Venturi tube')),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('quiz screen', () {
    testWidgets('a right answer scores and locks the question',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: QuizScreen()));
      await tester.pump();

      final q = kQuizQuestions.first;
      await tester.ensureVisible(find.text(q.options[q.answerIndex]));
      await tester.pumpAndSettle();
      await tester.tap(find.text(q.options[q.answerIndex]));
      await tester.pump();

      expect(find.textContaining('Correct!'), findsOneWidget);
      expect(find.text('1 of ${kQuizQuestions.length} correct'),
          findsOneWidget);

      // Tapping another option must not change the locked answer.
      final other = q.options[(q.answerIndex + 1) % q.options.length];
      await tester.ensureVisible(find.text(other));
      await tester.pumpAndSettle();
      await tester.tap(find.text(other));
      await tester.pump();
      expect(find.text('1 of ${kQuizQuestions.length} correct'),
          findsOneWidget);
    });

    testWidgets('a wrong answer reveals the right one', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: QuizScreen()));
      await tester.pump();

      final q = kQuizQuestions.first;
      final wrong = q.options[(q.answerIndex + 1) % q.options.length];
      await tester.ensureVisible(find.text(wrong));
      await tester.pumpAndSettle();
      await tester.tap(find.text(wrong));
      await tester.pump();

      expect(find.textContaining('The answer is "${q.answer}"'),
          findsOneWidget);
      expect(find.text('0 of ${kQuizQuestions.length} correct'),
          findsOneWidget);
    });

    testWidgets('reset clears the score', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: QuizScreen()));
      await tester.pump();

      final q = kQuizQuestions.first;
      await tester.ensureVisible(find.text(q.options[q.answerIndex]));
      await tester.pumpAndSettle();
      await tester.tap(find.text(q.options[q.answerIndex]));
      await tester.pump();
      expect(find.text('1 of ${kQuizQuestions.length} correct'),
          findsOneWidget);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(find.text('0 of ${kQuizQuestions.length} correct'),
          findsOneWidget);
    });

    testWidgets('the passage collapses and expands', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: QuizScreen()));
      await tester.pump();

      expect(find.textContaining('two rules at once'), findsOneWidget);
      await tester.tap(find.text('Hide'));
      await tester.pump();
      expect(find.textContaining('two rules at once'), findsNothing);
    });
  });

  group('layout', () {
    testWidgets('lays out on a small phone without overflowing',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const BernoulliApp());
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out on a tablet without overflowing', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const BernoulliApp());
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('survives a large system font setting', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2.5)),
            child: QuizScreen(),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
