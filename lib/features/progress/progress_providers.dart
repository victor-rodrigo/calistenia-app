import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/session_repository.dart';
import '../session/session_providers.dart';

final exerciseEvolutionProvider =
    FutureProvider.family<List<ExerciseEvolutionPoint>, int>((ref, exerciseId) {
  return ref.watch(sessionRepositoryProvider).getExerciseEvolution(exerciseId);
});
