import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/cartoon.dart';
import '../../core/feedback.dart';
import '../../core/theme.dart';
import '../../core/youtube.dart';
import '../../data/database/database.dart';
import '../../data/repositories/routine_repository.dart';
import '../routines/routines_providers.dart';
import 'isometry_timer_screen.dart';
import 'session_providers.dart';
import 'set_log_dialog.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key, required this.sessionId, required this.day});

  final int sessionId;
  final RoutineDay day;

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  Timer? _timer;
  int? _descansoRestante;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _iniciarDescanso(int segundos) {
    _timer?.cancel();
    if (segundos <= 0) return;
    setState(() => _descansoRestante = segundos);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        final restante = (_descansoRestante ?? 1) - 1;
        if (restante <= 0) {
          _descansoRestante = null;
          t.cancel();
          TimerFeedback.alerta();
        } else {
          _descansoRestante = restante;
        }
      });
    });
  }

  void _pularDescanso() {
    _timer?.cancel();
    setState(() => _descansoRestante = null);
  }

  Future<void> _registrar(RoutineExerciseView view, int serie) async {
    if (view.exercise.tipo == 'tempo') {
      await _registrarIsometria(view, serie);
      return;
    }

    final input = await showSetLogDialog(
      context,
      exercise: view.exercise,
      numeroSerie: serie,
      repsAlvo: view.item.repsAlvo,
      duracaoAlvo: view.item.duracaoAlvoSeg,
    );
    if (input == null) return;

    await ref.read(sessionRepositoryProvider).logSet(
          widget.sessionId,
          view.exercise.id,
          numeroSerie: serie,
          repsFeitas: input.repsFeitas,
          duracaoSeg: input.duracaoSeg,
          cargaOuRpe: input.cargaOuRpe,
        );
    _iniciarDescanso(view.item.descansoSeg);
  }

  Future<void> _registrarIsometria(RoutineExerciseView view, int serie) async {
    final alvo = view.item.duracaoAlvoSeg ?? 30;
    final segundos = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) =>
            IsometryTimerScreen(exercise: view.exercise, alvoSeg: alvo),
      ),
    );
    if (segundos == null) return;

    await ref.read(sessionRepositoryProvider).logSet(
          widget.sessionId,
          view.exercise.id,
          numeroSerie: serie,
          duracaoSeg: segundos,
        );
    _iniciarDescanso(view.item.descansoSeg);
  }

  Future<void> _finalizar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar treino?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await ref.read(sessionRepositoryProvider).finishSession(widget.sessionId);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final plano = ref.watch(dayExercisesProvider(widget.day.id));
    final logs = ref.watch(setLogsProvider(widget.sessionId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.day.nome),
        actions: [
          TextButton(
            onPressed: _finalizar,
            child: const Text('Finalizar'),
          ),
        ],
      ),
      bottomNavigationBar: _descansoRestante == null
          ? null
          : _RestBar(segundos: _descansoRestante!, onSkip: _pularDescanso),
      body: plano.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (itens) {
          if (itens.isEmpty) {
            return const Center(child: Text('Este dia não tem exercícios'));
          }
          final feitos = logs.asData?.value ?? const <SetLog>[];
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            children: [
              for (final view in itens)
                _ExerciseCard(
                  view: view,
                  logs: feitos,
                  onRegistrar: (serie) => _registrar(view, serie),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.view,
    required this.logs,
    required this.onRegistrar,
  });

  final RoutineExerciseView view;
  final List<SetLog> logs;
  final void Function(int serie) onRegistrar;

  SetLog? _logDaSerie(int serie) {
    for (final l in logs) {
      if (l.exerciseId == view.exercise.id && l.numeroSerie == serie) return l;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final item = view.item;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: StickerCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(view.exercise.nome,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                IconButton(
                  icon: const Icon(Icons.smart_display_rounded),
                  color: AppColors.teal,
                  tooltip: 'Ver no YouTube',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => abrirTutorialYoutube(view.exercise.nome),
                ),
              ],
            ),
            const SizedBox(height: 2),
            for (var serie = 1; serie <= item.seriesAlvo; serie++)
              _SerieRow(
                serie: serie,
                alvo: item.repsAlvo != null
                    ? '${item.repsAlvo} reps'
                    : item.duracaoAlvoSeg != null
                        ? '${item.duracaoAlvoSeg}s'
                        : '',
                log: _logDaSerie(serie),
                onRegistrar: () => onRegistrar(serie),
              ),
          ],
        ),
      ),
    );
  }
}

class _SerieRow extends StatelessWidget {
  const _SerieRow({
    required this.serie,
    required this.alvo,
    required this.log,
    required this.onRegistrar,
  });

  final int serie;
  final String alvo;
  final SetLog? log;
  final VoidCallback onRegistrar;

  @override
  Widget build(BuildContext context) {
    if (log != null) {
      final feito = log!.repsFeitas != null
          ? '${log!.repsFeitas} reps'
          : log!.duracaoSeg != null
              ? '${log!.duracaoSeg}s'
              : '';
      final carga =
          log!.cargaOuRpe != null ? ' · ${_fmt(log!.cargaOuRpe!)}' : '';
      return ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.check_circle_rounded, color: AppColors.teal),
        title: Text('Série $serie',
            style: Theme.of(context).textTheme.titleSmall),
        trailing: Text('$feito$carga', style: baloo(15, 800)),
      );
    }
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.radio_button_unchecked_rounded,
          color: AppColors.sepia),
      title: Text('Série $serie',
          style: Theme.of(context).textTheme.titleSmall),
      subtitle: alvo.isEmpty ? null : Text('alvo: $alvo'),
      trailing: FilledButton(
        onPressed: onRegistrar,
        child: const Text('Registrar'),
      ),
    );
  }

  String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : '$v';
}

class _RestBar extends StatelessWidget {
  const _RestBar({required this.segundos, required this.onSkip});

  final int segundos;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final min = segundos ~/ 60;
    final sec = (segundos % 60).toString().padLeft(2, '0');
    return Material(
      color: AppColors.mustard,
      shape: const Border(top: BorderSide(color: AppColors.ink, width: 2.5)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.timer_rounded, color: AppColors.ink),
              const SizedBox(width: 10),
              Text('Descanso', style: baloo(16, 700)),
              const Spacer(),
              Text('$min:$sec', style: baloo(24, 800)),
              const SizedBox(width: 12),
              TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(foregroundColor: AppColors.ink),
                child: const Text('Pular'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
