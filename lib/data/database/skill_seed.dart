import 'package:drift/drift.dart';

import 'database.dart';

class SkillSeed {
  const SkillSeed(this.nome, this.passos);

  final String nome;
  final List<String> passos;
}

const defaultSkills = <SkillSeed>[
  SkillSeed('Barra fixa (pull-up)', [
    'Remada australiana',
    'Negativa de barra',
    'Barra assistida com elástico',
    '1 barra completa',
    '8+ barras',
  ]),
  SkillSeed('Muscle-up', [
    'Pull-up x5',
    'Barra explosiva (peito à barra)',
    'Negativa de muscle-up',
    'Muscle-up com impulso (kipping)',
    'Muscle-up estrito',
  ]),
  SkillSeed('Pistol squat', [
    'Agachamento livre x20',
    'Agachamento búlgaro',
    'Pistol assistido (apoio)',
    'Pistol parcial na caixa',
    'Pistol completo',
  ]),
  SkillSeed('Parada de mão', [
    'Prancha 60s',
    'Pike hold',
    'Parede de barriga',
    'Parede de costas',
    'Parada livre 10s',
  ]),
  SkillSeed('Front lever', [
    'Tuck front lever',
    'Advanced tuck',
    'Uma perna (one-leg)',
    'Straddle front lever',
    'Front lever completo',
  ]),
  SkillSeed('L-sit', [
    'Apoio nos pés',
    'Uma perna',
    'Tuck L-sit',
    'L-sit 10s',
    'L-sit 30s',
  ]),
];

Future<void> seedSkills(AppDatabase db, List<SkillSeed> skills) async {
  final existentes = await db.skillProgressions.count().getSingle();
  if (existentes > 0) return;

  for (final skill in skills) {
    final skillId = await db
        .into(db.skillProgressions)
        .insert(SkillProgressionsCompanion.insert(nome: skill.nome));
    var ordem = 0;
    await db.batch(
      (b) => b.insertAll(db.skillSteps, [
        for (final passo in skill.passos)
          SkillStepsCompanion.insert(
            skillId: skillId,
            nome: passo,
            ordem: Value(ordem++),
          ),
      ]),
    );
  }
}

Future<void> seedDefaultSkills(AppDatabase db) => seedSkills(db, defaultSkills);
