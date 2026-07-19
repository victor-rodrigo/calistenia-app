import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/muscles.dart';
import '../../core/theme.dart';
import '../../core/youtube.dart';
import '../../data/database/database.dart';
import 'exercise_type.dart';
import 'exercises_providers.dart';

class ExerciseFormScreen extends ConsumerStatefulWidget {
  const ExerciseFormScreen({super.key, this.exercise});

  final Exercise? exercise;

  @override
  ConsumerState<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends ConsumerState<ExerciseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _grupo;
  late final TextEditingController _notas;
  late String _tipo;

  bool get _editando => widget.exercise != null;

  @override
  void initState() {
    super.initState();
    final e = widget.exercise;
    _nome = TextEditingController(text: e?.nome ?? '');
    _grupo = TextEditingController(text: e?.grupoMuscular ?? '');
    _notas = TextEditingController(text: e?.notas ?? '');
    _tipo = e?.tipo ?? 'reps';
  }

  @override
  void dispose() {
    _nome.dispose();
    _grupo.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _abrirYoutube() async {
    final nome = _nome.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dê um nome ao exercício primeiro')),
      );
      return;
    }
    final ok = await abrirTutorialYoutube(nome);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não consegui abrir o YouTube')),
      );
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(exerciseRepositoryProvider);
    final grupo = _grupo.text.trim().isEmpty ? null : _grupo.text.trim();
    final notas = _notas.text.trim().isEmpty ? null : _notas.text.trim();

    if (_editando) {
      await repo.update(
        widget.exercise!.copyWith(
          nome: _nome.text.trim(),
          tipo: _tipo,
          grupoMuscular: Value(grupo),
          notas: Value(notas),
        ),
      );
    } else {
      await repo.create(
        nome: _nome.text.trim(),
        tipo: _tipo,
        grupoMuscular: grupo,
        notas: notas,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar exercício' : 'Novo exercício'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (muscleImageFor(_grupo.text.trim()) case final img?)
              Center(
                child: Image.asset(img, height: 150, fit: BoxFit.contain),
              ),
            TextFormField(
              controller: _nome,
              autofocus: !_editando,
              decoration: const InputDecoration(labelText: 'Nome'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe um nome' : null,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _abrirYoutube,
              icon: const Icon(Icons.smart_display_rounded),
              label: const Text('Ver no YouTube'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _tipo,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: [
                for (final t in exerciseTypes)
                  DropdownMenuItem(value: t, child: Text(tipoLabel(t))),
              ],
              onChanged: (v) => setState(() => _tipo = v ?? _tipo),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _grupo,
              decoration:
                  const InputDecoration(labelText: 'Grupo muscular (opcional)'),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notas,
              decoration: const InputDecoration(labelText: 'Notas (opcional)'),
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _salvar, child: const Text('Salvar')),
          ],
        ),
      ),
    );
  }
}
