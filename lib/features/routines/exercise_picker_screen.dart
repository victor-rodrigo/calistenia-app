import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/muscles.dart';
import '../../data/database/database.dart';
import '../exercises/exercises_providers.dart';

class ExercisePickerScreen extends ConsumerStatefulWidget {
  const ExercisePickerScreen({super.key});

  @override
  ConsumerState<ExercisePickerScreen> createState() =>
      _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends ConsumerState<ExercisePickerScreen> {
  String _busca = '';

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exercisesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Escolher exercício')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _busca = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: exercises.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (list) {
                final filtrados = _busca.isEmpty
                    ? list
                    : list
                        .where((e) => e.nome.toLowerCase().contains(_busca))
                        .toList();
                return ListView.builder(
                  itemCount: filtrados.length,
                  itemBuilder: (context, i) {
                    final e = filtrados[i];
                    return ListTile(
                      leading: _thumb(muscleImageFor(e.grupoMuscular)),
                      title: Text(e.nome),
                      subtitle:
                          e.grupoMuscular == null ? null : Text(e.grupoMuscular!),
                      onTap: () => Navigator.of(context).pop<Exercise>(e),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumb(String? imagem) {
    const size = 44.0;
    if (imagem == null) {
      return const SizedBox(
          width: size,
          height: size,
          child: Icon(Icons.fitness_center_rounded));
    }
    return Image.asset(imagem, width: size, height: size, fit: BoxFit.contain);
  }
}
