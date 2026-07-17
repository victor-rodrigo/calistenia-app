import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/database/database.dart';

class ExerciseConfig {
  const ExerciseConfig({
    required this.seriesAlvo,
    this.repsAlvo,
    this.duracaoAlvoSeg,
    required this.descansoSeg,
  });

  final int seriesAlvo;
  final int? repsAlvo;
  final int? duracaoAlvoSeg;
  final int descansoSeg;
}

Future<ExerciseConfig?> showExerciseConfigDialog(
  BuildContext context,
  Exercise exercise,
) {
  return showDialog<ExerciseConfig>(
    context: context,
    builder: (_) => _ConfigDialog(exercise: exercise),
  );
}

class _ConfigDialog extends StatefulWidget {
  const _ConfigDialog({required this.exercise});

  final Exercise exercise;

  @override
  State<_ConfigDialog> createState() => _ConfigDialogState();
}

class _ConfigDialogState extends State<_ConfigDialog> {
  final _series = TextEditingController(text: '3');
  final _repsOuTempo = TextEditingController(text: '10');
  final _descanso = TextEditingController(text: '90');

  bool get _porTempo => widget.exercise.tipo == 'tempo';

  @override
  void initState() {
    super.initState();
    if (_porTempo) _repsOuTempo.text = '30';
  }

  @override
  void dispose() {
    _series.dispose();
    _repsOuTempo.dispose();
    _descanso.dispose();
    super.dispose();
  }

  int _int(TextEditingController c, int fallback) =>
      int.tryParse(c.text.trim()) ?? fallback;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.exercise.nome),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NumberField(controller: _series, label: 'Séries'),
          const SizedBox(height: 12),
          _NumberField(
            controller: _repsOuTempo,
            label: _porTempo ? 'Tempo por série (seg)' : 'Repetições',
          ),
          const SizedBox(height: 12),
          _NumberField(controller: _descanso, label: 'Descanso (seg)'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final valor = _int(_repsOuTempo, _porTempo ? 30 : 10);
            Navigator.pop(
              context,
              ExerciseConfig(
                seriesAlvo: _int(_series, 3),
                repsAlvo: _porTempo ? null : valor,
                duracaoAlvoSeg: _porTempo ? valor : null,
                descansoSeg: _int(_descanso, 90),
              ),
            );
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: label),
    );
  }
}
