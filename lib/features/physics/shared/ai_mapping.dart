import '../cloud_formation/models/lesson.dart' as generated;

/// Maps AI-generated worksheet items into a lesson's local model types.
List<T> mapGeneratedChoiceQuestions<T>({
  required List<generated.ChoiceQuestion> source,
  required T Function(generated.ChoiceQuestion q) build,
}) {
  return source.map(build).toList();
}

List<T> mapGeneratedClozeSentences<T>({
  required List<generated.ClozeSentence> source,
  required T Function(generated.ClozeSentence b) build,
}) {
  return source.map(build).toList();
}
