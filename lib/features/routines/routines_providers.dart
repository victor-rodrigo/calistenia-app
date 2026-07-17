import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/database/database_provider.dart';
import '../../data/repositories/routine_repository.dart';

final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  return RoutineRepository(ref.watch(databaseProvider));
});

final routinesProvider = StreamProvider<List<Routine>>((ref) {
  return ref.watch(routineRepositoryProvider).watchRoutines();
});

final daysProvider =
    StreamProvider.family<List<RoutineDay>, int>((ref, routineId) {
  return ref.watch(routineRepositoryProvider).watchDays(routineId);
});

final dayExercisesProvider =
    StreamProvider.family<List<RoutineExerciseView>, int>((ref, dayId) {
  return ref.watch(routineRepositoryProvider).watchDayExercises(dayId);
});
