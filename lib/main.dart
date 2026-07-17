import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/database/database_provider.dart';
import 'data/database/mock_seed.dart';
import 'data/database/seed.dart';
import 'data/database/skill_seed.dart';

/// Popula dados de exemplo (treinos e histórico) para desenvolvimento.
/// Desligar antes de uma versão definitiva.
const _seedMockData = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  final db = container.read(databaseProvider);
  await seedFromAsset(db);
  await seedDefaultSkills(db);
  if (_seedMockData) await seedMockData(db);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TreinoApp(),
    ),
  );
}
