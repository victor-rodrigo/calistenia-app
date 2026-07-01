import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/database/database_provider.dart';
import '../../data/repositories/exercise_repository.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository(ref.watch(databaseProvider));
});

final exercisesProvider = StreamProvider<List<Exercise>>((ref) {
  return ref.watch(exerciseRepositoryProvider).watchAll();
});
