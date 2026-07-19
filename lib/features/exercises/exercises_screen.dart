import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/cartoon.dart';
import '../../core/muscles.dart';
import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../core/youtube.dart';
import '../../data/database/database.dart';
import 'exercise_form_screen.dart';
import 'exercise_type.dart';
import 'exercises_providers.dart';

class ExercisesScreen extends ConsumerStatefulWidget {
  const ExercisesScreen({super.key});

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  String _busca = '';
  String? _grupo;

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exercisesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Exercícios')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add_rounded),
      ),
      body: exercises.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (todos) {
          if (todos.isEmpty) {
            return const EmptyMessage(
              icon: Icons.fitness_center_rounded,
              titulo: 'Nenhum exercício ainda',
              subtitulo: 'Toque em + para adicionar',
            );
          }
          final grupos = _gruposDisponiveis(todos);
          final filtrados = todos.where((e) {
            final okBusca =
                _busca.isEmpty || e.nome.toLowerCase().contains(_busca);
            final okGrupo = _grupo == null || e.grupoMuscular == _grupo;
            return okBusca && okGrupo;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Buscar exercício',
                  ),
                  onChanged: (v) =>
                      setState(() => _busca = v.trim().toLowerCase()),
                ),
              ),
              _FiltroGrupos(
                grupos: grupos,
                selecionado: _grupo,
                onSelect: (g) => setState(() => _grupo = g),
              ),
              Expanded(
                child: filtrados.isEmpty
                    ? const EmptyMessage(
                        icon: Icons.search_off_rounded,
                        titulo: 'Nada encontrado',
                        subtitulo: 'Tente outro nome ou grupo',
                      )
                    : _ListaAgrupada(exercicios: filtrados),
              ),
            ],
          );
        },
      ),
    );
  }

  List<String> _gruposDisponiveis(List<Exercise> todos) {
    final set = todos
        .map((e) => e.grupoMuscular)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
    return set;
  }
}

class _FiltroGrupos extends StatelessWidget {
  const _FiltroGrupos({
    required this.grupos,
    required this.selecionado,
    required this.onSelect,
  });

  final List<String> grupos;
  final String? selecionado;
  final void Function(String?) onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _Chip(
            label: 'Todos',
            ativo: selecionado == null,
            onTap: () => onSelect(null),
          ),
          for (final g in grupos)
            _Chip(
              label: g,
              ativo: selecionado == g,
              onTap: () => onSelect(g),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.ativo, required this.onTap});

  final String label;
  final bool ativo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: ativo ? AppColors.red : AppColors.card,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.ink, width: 2.5),
            boxShadow: const [BoxShadow(color: AppColors.ink, offset: Offset(2, 2))],
          ),
          child: Text(
            label,
            style: baloo(14, 700,
                color: ativo ? AppColors.card : AppColors.ink),
          ),
        ),
      ),
    );
  }
}

class _ListaAgrupada extends StatelessWidget {
  const _ListaAgrupada({required this.exercicios});

  final List<Exercise> exercicios;

  @override
  Widget build(BuildContext context) {
    final porGrupo = <String, List<Exercise>>{};
    for (final e in exercicios) {
      porGrupo.putIfAbsent(e.grupoMuscular ?? 'Outros', () => []).add(e);
    }
    final grupos = porGrupo.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        for (final g in grupos) ...[
          _CabecalhoGrupo(grupo: g, total: porGrupo[g]!.length),
          for (final e in porGrupo[g]!)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ExerciseTile(exercise: e),
            ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _CabecalhoGrupo extends StatelessWidget {
  const _CabecalhoGrupo({required this.grupo, required this.total});

  final String grupo;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      child: Row(
        children: [
          Text(grupo, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(width: 8),
          Text('($total)', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ExerciseTile extends ConsumerWidget {
  const _ExerciseTile({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StickerCard(
      padding: const EdgeInsets.all(10),
      onTap: () => _openForm(context, exercise),
      child: Row(
        children: [
          _MuscleThumb(grupo: exercise.grupoMuscular),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.nome,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(tipoLabel(exercise.tipo),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.smart_display_rounded),
            color: AppColors.teal,
            tooltip: 'Ver no YouTube',
            onPressed: () => abrirTutorialYoutube(exercise.nome),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmDelete(context, ref, exercise),
          ),
        ],
      ),
    );
  }
}

class _MuscleThumb extends StatelessWidget {
  const _MuscleThumb({this.grupo});

  final String? grupo;

  @override
  Widget build(BuildContext context) {
    const size = 54.0;
    final img = muscleImageFor(grupo);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.paperDeep,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: img == null
          ? const Icon(Icons.fitness_center_rounded, color: AppColors.ink)
          : Padding(
              padding: const EdgeInsets.all(3),
              child: Image.asset(img, fit: BoxFit.contain),
            ),
    );
  }
}

Future<void> _openForm(BuildContext context, [Exercise? exercise]) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => ExerciseFormScreen(exercise: exercise)),
  );
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  Exercise exercise,
) async {
  final ok = await confirmDelete(context, 'Excluir "${exercise.nome}"?');
  if (ok) {
    await ref.read(exerciseRepositoryProvider).delete(exercise.id);
  }
}
