const exerciseTypes = ['reps', 'tempo', 'ponderado'];

String tipoLabel(String tipo) => switch (tipo) {
      'reps' => 'Repetições',
      'tempo' => 'Tempo',
      'ponderado' => 'Ponderado',
      _ => tipo,
    };
