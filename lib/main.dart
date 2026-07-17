import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/database/database_provider.dart';
import 'data/database/seed.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  await seedFromAsset(container.read(databaseProvider));

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TreinoApp(),
    ),
  );
}
