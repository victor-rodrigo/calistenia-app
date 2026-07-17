import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/database/database_provider.dart';
import '../../data/repositories/skill_repository.dart';

final skillRepositoryProvider = Provider<SkillRepository>((ref) {
  return SkillRepository(ref.watch(databaseProvider));
});

final skillsProvider = StreamProvider<List<SkillProgression>>((ref) {
  return ref.watch(skillRepositoryProvider).watchSkills();
});

final skillStepsProvider =
    StreamProvider.family<List<SkillStep>, int>((ref, skillId) {
  return ref.watch(skillRepositoryProvider).watchSteps(skillId);
});
