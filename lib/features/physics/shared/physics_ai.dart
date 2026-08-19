import '../cloud_formation/data/lesson_data.dart';
import '../heat_and_temperature/data/lesson_data.dart';
import '../kinetic_theory/data/lesson_data.dart';

/// Reading context passed to [OpenAIService] when generating new physics
/// worksheet items. Each lesson exposes two contexts — one per passage.
class PhysicsAiContext {
  const PhysicsAiContext({
    required this.topicTitle,
    required this.passageTitle,
    required this.passageBody,
    this.figureCaption,
    required this.maxBeat,
    required this.itemCount,
    this.wordBank = const [],
  });

  final String topicTitle;
  final String passageTitle;
  final String passageBody;
  final String? figureCaption;
  final int maxBeat;
  final int itemCount;
  final List<String> wordBank;

  String get passageBlock {
    final caption =
        figureCaption == null || figureCaption!.isEmpty ? '' : '$figureCaption\n';
    return '$passageTitle\n$caption$passageBody';
  }
}

/// Cloud Formation — Part 1 multiple choice (4 beats in the sky animation).
final kCloudChoiceAi = PhysicsAiContext(
  topicTitle: 'Cloud Formation',
  passageTitle: kCloudLesson.passageOne.title,
  passageBody: kCloudLesson.passageOne.body,
  figureCaption: kCloudLesson.passageOne.figureCaption,
  maxBeat: 4,
  itemCount: 4,
  wordBank: const [
    'convective',
    'condensation',
    'humidity',
    'cumulonimbus',
    'vapour',
    'droplets',
  ],
);

/// Cloud Formation — Part 2 fill-in (circulation passage).
final kCloudBlankAi = PhysicsAiContext(
  topicTitle: 'Cloud Formation',
  passageTitle: kCloudLesson.passageTwo.title,
  passageBody: kCloudLesson.passageTwo.body,
  figureCaption: kCloudLesson.passageTwo.figureCaption,
  maxBeat: 4,
  itemCount: 6,
  wordBank: const [
    'indicator',
    'circulation',
    'cumulus',
    'ascending',
    'merge',
    'rain',
  ],
);

/// Kinetic Theory of Gases — Part 1 multiple choice (vessel beats 1–3).
final kKineticChoiceAi = PhysicsAiContext(
  topicTitle: 'Kinetic Theory of Gases',
  passageTitle: kKineticLesson.passageOne.title,
  passageBody: kKineticLesson.passageOne.body,
  figureCaption: kKineticLesson.passageOne.figureCaption,
  maxBeat: 5,
  itemCount: 4,
  wordBank: const [
    'molecules',
    'pressure',
    'bombardment',
    'volume',
    'temperature',
    'impacts',
  ],
);

/// Kinetic Theory — Part 2 fill-in (Brown apparatus beats 4–5).
final kKineticBlankAi = PhysicsAiContext(
  topicTitle: 'Kinetic Theory of Gases',
  passageTitle: kKineticLesson.passageTwo.title,
  passageBody: kKineticLesson.passageTwo.body,
  figureCaption: kKineticLesson.passageTwo.figureCaption,
  maxBeat: 5,
  itemCount: 6,
  wordBank: const [
    'ping-pong',
    'cogwheel',
    'molecules',
    'kinetic energy',
    'piston',
    'gas',
  ],
);

/// Heat and Temperature — Part 1 multiple choice (cryogenic beats 1–3).
final kHeatChoiceAi = PhysicsAiContext(
  topicTitle: 'Heat and Temperature',
  passageTitle: kCryogenicsLesson.passageOne.title,
  passageBody: kCryogenicsLesson.passageOne.body,
  figureCaption: kCryogenicsLesson.passageOne.figureCaption,
  maxBeat: 5,
  itemCount: 4,
  wordBank: const [
    'compressor',
    'expansion',
    'cryogenic',
    'valve',
    'thermal pump',
    'heat',
  ],
);

/// Heat and Temperature — Part 2 fill-in (plasma / extremes beats 4–5).
final kHeatBlankAi = PhysicsAiContext(
  topicTitle: 'Heat and Temperature',
  passageTitle: kCryogenicsLesson.passageTwo.title,
  passageBody: kCryogenicsLesson.passageTwo.body,
  figureCaption: kCryogenicsLesson.passageTwo.figureCaption,
  maxBeat: 5,
  itemCount: 6,
  wordBank: const [
    'plasma',
    'noble gas',
    'electrons',
    'cryogenic',
    'liquefy',
    'absolute zero',
  ],
);
