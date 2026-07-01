import 'package:drift/drift.dart' show countAll;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database_provider.dart';

final exerciseCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  final total = countAll();
  final query = db.selectOnly(db.exercises)..addColumns([total]);
  return query.map((row) => row.read(total) ?? 0).watchSingle();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(exerciseCountProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Treino')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fitness_center,
                  size: 72, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text('Treino', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              count.when(
                data: (n) => Text('Exercícios cadastrados: $n'),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Erro ao abrir o banco: $e'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
