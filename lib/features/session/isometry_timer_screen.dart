import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/feedback.dart';
import '../../data/database/database.dart';

class IsometryTimerScreen extends StatefulWidget {
  const IsometryTimerScreen({
    super.key,
    required this.exercise,
    required this.alvoSeg,
  });

  final Exercise exercise;
  final int alvoSeg;

  @override
  State<IsometryTimerScreen> createState() => _IsometryTimerScreenState();
}

class _IsometryTimerScreenState extends State<IsometryTimerScreen> {
  Timer? _timer;
  late int _restante;
  bool _rodando = false;

  @override
  void initState() {
    super.initState();
    _restante = widget.alvoSeg;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _alternar() {
    if (_rodando) {
      _timer?.cancel();
      setState(() => _rodando = false);
      return;
    }
    setState(() => _rodando = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _restante--;
        if (_restante <= 0) {
          _restante = 0;
          t.cancel();
          _rodando = false;
          TimerFeedback.alerta();
          Navigator.of(context).pop(widget.alvoSeg);
        }
      });
    });
  }

  void _concluirAgora() {
    _timer?.cancel();
    Navigator.of(context).pop(widget.alvoSeg - _restante);
  }

  @override
  Widget build(BuildContext context) {
    final min = _restante ~/ 60;
    final sec = (_restante % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(title: Text(widget.exercise.nome)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$min:$sec',
                style: const TextStyle(
                    fontSize: 72, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('alvo: ${widget.alvoSeg}s'),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _alternar,
              icon: Icon(_rodando ? Icons.pause : Icons.play_arrow),
              label: Text(_rodando ? 'Pausar' : 'Iniciar'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _concluirAgora,
              child: const Text('Concluir agora'),
            ),
          ],
        ),
      ),
    );
  }
}
