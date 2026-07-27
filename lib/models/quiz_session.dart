import 'worksheet.dart';

/// Holds the progress of a single play-through so it can be resumed after
/// the user navigates away from the quiz screen.
class QuizSession {
  QuizSession({required this.worksheet});

  final Worksheet worksheet;

  int index = 0;
  int lives = maxLives;
  int correct = 0;

  static const int maxLives = 5;

  int get total => worksheet.questions.length;

  /// True once the player has run out of lives or answered the last question.
  bool get isComplete => index >= total || lives <= 0;
}

/// A tiny in-memory holder for the currently active session so that the
/// Welcome screen can decide whether to resume or start fresh.
class SessionStore {
  QuizSession? current;

  /// Whether there is an in-progress session worth resuming.
  bool get canResume => current != null && !current!.isComplete;

  QuizSession startNew(Worksheet worksheet) {
    return current = QuizSession(worksheet: worksheet);
  }

  void clear() => current = null;
}
