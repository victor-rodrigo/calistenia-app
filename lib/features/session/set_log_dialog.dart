import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/database/database.dart';

class SetLogInput {
  const SetLogInput({this.repsFeitas, this.duracaoSeg, this.cargaOuRpe});

  final int? repsFeitas;
  final int? duracaoSeg;
  final double? cargaOuRpe;
}

Future<SetLogInput?> showSetLogDialog(
  BuildContext context, {
  required Exercise exercise,
  required int numeroSerie,
  int? repsAlvo,
  int? duracaoAlvo,
}) {
  return showDialog<SetLogInput>(
    context: context,
    builder: (_) => _SetLogDialog(
      exercise: exercise,
      numeroSerie: numeroSerie,
      repsAlvo: repsAlvo,
      duracaoAlvo: duracaoAlvo,
    ),
  );
}

class _SetLogDialog extends StatefulWidget {
  const _SetLogDialog({
    required this.exercise,
    required this.numeroSerie,
    this.repsAlvo,
    this.duracaoAlvo,
  });

  final Exercise exercise;
  final int numeroSerie;
  final int? repsAlvo;
  final int? duracaoAlvo;

  @override
  State<_SetLogDialog> createState() => _SetLogDialogState();
}

class _SetLogDialogState extends State<_SetLogDialog> {
  late final TextEditingController _repsOuTempo;
  final _carga = TextEditingController();

  bool get _porTempo => widget.exercise.tipo == 'tempo';

  @override
  void initState() {
    super.initState();
    final prefill = _porTempo ? widget.duracaoAlvo : widget.repsAlvo;
    _repsOuTempo = TextEditingController(text: prefill?.toString() ?? '');
  }

  @override
  void dispose() {
    _repsOuTempo.dispose();
    _carga.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.exercise.nome} — série ${widget.numeroSerie}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _repsOuTempo,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: _porTempo ? 'Tempo (seg)' : 'Repetições',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _carga,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Carga (kg) ou RPE — opcional',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final valor = int.tryParse(_repsOuTempo.text.trim());
            final carga =
                double.tryParse(_carga.text.trim().replaceAll(',', '.'));
            Navigator.pop(
              context,
              SetLogInput(
                repsFeitas: _porTempo ? null : valor,
                duracaoSeg: _porTempo ? valor : null,
                cargaOuRpe: carga,
              ),
            );
          },
          child: const Text('Concluir série'),
        ),
      ],
    );
  }
}
