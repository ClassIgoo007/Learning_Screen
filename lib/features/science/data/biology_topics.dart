import '../models/science_content.dart';
import 'cell_structure_topic.dart';
import 'dna_topic.dart';
import 'genetic_code_topic.dart';
import 'glucose_topic.dart';
import 'photosynthesis_topic.dart';
import 'transcription_topic.dart';

/// All biology reading topics, in the order they appear in the Biology catalog.
const List<ScienceTopic> kBiologyTopics = [
  kDnaTopic,
  kPhotosynthesisTopic,
  kTranscriptionTopic,
  kGlucoseTopic,
  kGeneticCodeTopic,
  kCellStructureTopic,
];
