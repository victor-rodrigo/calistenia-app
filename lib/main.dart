import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/database/database_provider.dart';
import 'data/database/program_seed.dart';
import 'data/database/seed.dart';
import 'data/database/skill_seed.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  final db = container.read(databaseProvider);
  await seedFromAsset(db);
  await seedDefaultSkills(db);
  await seedUserProgram(db);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TreinoApp(),
    ),
  );
}
