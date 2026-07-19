import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../data/repositories/routine_repository.dart';
import '../routines/routines_providers.dart';
import 'session_providers.dart';

class TestScreen extends ConsumerStatefulWidget {
  const TestScreen({super.key, required this.day});

  final RoutineDay day;

  @override
  ConsumerState<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends ConsumerState<TestScreen> {
  final _controllers = <int, TextEditingController>{};

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(int exerciseId) =>
      _controllers.putIfAbsent(exerciseId, TextEditingController.new);

  Future<void> _salvar(List<RoutineExerciseView> itens) async {
    final repo = ref.read(sessionRepositoryProvider);
    final sessionId = await repo.startSession(widget.day.id);

    for (final view in itens) {
      final valor = int.tryParse(_controllers[view.exercise.id]?.text.trim() ?? '');
      if (valor == null) continue;
      await repo.logSet(
        sessionId,
        view.exercise.id,
        numeroSerie: 1,
        repsFeitas: view.exercise.tipo == 'tempo' ? null : valor,
        duracaoSeg: view.exercise.tipo == 'tempo' ? valor : null,
      );
    }

    await repo.finishSession(sessionId);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final plano = ref.watch(dayExercisesProvider(widget.day.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Teste')),
      body: plano.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (itens) {
          if (itens.isEmpty) {
            return const Center(child: Text('Este teste não tem exercícios'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Registre seu máximo em cada exercício.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              for (final view in itens)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextField(
                    controller: _controllerFor(view.exercise.id),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: view.exercise.nome,
                      suffixText:
                          view.exercise.tipo == 'tempo' ? 'seg' : 'reps',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => _salvar(itens),
                child: const Text('Salvar teste'),
              ),
            ],
          );
        },
      ),
    );
  }
}
