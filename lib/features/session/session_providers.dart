import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/database/database_provider.dart';
import '../../data/repositories/session_repository.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref.watch(databaseProvider));
});

final setLogsProvider =
    StreamProvider.family<List<SetLog>, int>((ref, sessionId) {
  return ref.watch(sessionRepositoryProvider).watchSetLogs(sessionId);
});
