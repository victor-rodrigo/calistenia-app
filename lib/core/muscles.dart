const _slugs = {
  'Peito': 'peito',
  'Abdômen': 'abdomen',
  'Core': 'abdomen',
  'Costas': 'costas',
  'Quadríceps': 'quadriceps',
  'Pernas': 'pernas',
  'Tríceps': 'triceps',
  'Glúteos': 'gluteos',
  'Posterior de coxa': 'posterior_de_coxa',
  'Pescoço': 'pescoco',
  'Ombros': 'ombros',
  'Lombar': 'lombar',
  'Adutores': 'adutores',
  'Abdutores': 'gluteos',
  'Antebraço': 'antebraco',
  'Panturrilha': 'panturrilha',
};

String? muscleImageFor(String? grupoMuscular) {
  if (grupoMuscular == null) return null;
  final slug = _slugs[grupoMuscular];
  return slug == null ? null : 'assets/muscles/$slug.png';
}
