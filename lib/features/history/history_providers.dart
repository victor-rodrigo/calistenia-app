import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/session_repository.dart';
import '../session/session_providers.dart';

final completedSessionsProvider =
    StreamProvider<List<SessionSummary>>((ref) {
  return ref.watch(sessionRepositoryProvider).watchCompletedSessions();
});

final sessionSetLogsProvider =
    FutureProvider.family<List<SetLogView>, int>((ref, sessionId) {
  return ref.watch(sessionRepositoryProvider).getSessionSetLogs(sessionId);
});
