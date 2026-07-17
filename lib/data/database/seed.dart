import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'database.dart';

class ExerciseSeed {
  const ExerciseSeed({
    required this.nome,
    this.nomeOriginal,
    this.grupoMuscular,
    required this.tipo,
    this.imagem,
  });

  final String nome;
  final String? nomeOriginal;
  final String? grupoMuscular;
  final String tipo;
  final String? imagem;
}

List<ExerciseSeed> parseExerciseSeed(String source) {
  final data = (jsonDecode(source) as List<dynamic>).cast<Map<String, dynamic>>();
  return [
    for (final item in data)
      ExerciseSeed(
        nome: item['nome'] as String,
        nomeOriginal: item['nomeOriginal'] as String?,
        grupoMuscular: item['grupoMuscular'] as String?,
        tipo: item['tipo'] as String? ?? 'reps',
        imagem: item['imagem'] as String?,
      ),
  ];
}

Future<void> seedExercises(AppDatabase db, List<ExerciseSeed> items) async {
  final existentes = await db.exercises.count().getSingle();
  if (existentes > 0) return;

  await db.batch(
    (b) => b.insertAll(db.exercises, [
      for (final e in items)
        ExercisesCompanion.insert(
          nome: e.nome,
          tipo: Value(e.tipo),
          grupoMuscular: Value(e.grupoMuscular),
          imagem: Value(e.imagem),
        ),
    ]),
  );
}

Future<void> seedFromAsset(AppDatabase db) async {
  final source =
      await rootBundle.loadString('assets/exercicios_calistenia.json');
  await seedExercises(db, parseExerciseSeed(source));
}
