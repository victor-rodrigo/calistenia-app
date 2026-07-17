import 'package:flutter/material.dart';

class EmptyMessage extends StatelessWidget {
  const EmptyMessage({
    super.key,
    required this.icon,
    required this.titulo,
    this.subtitulo,
  });

  final IconData icon;
  final String titulo;
  final String? subtitulo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56),
            const SizedBox(height: 12),
            Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            if (subtitulo != null) ...[
              const SizedBox(height: 4),
              Text(subtitulo!, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}

Future<String?> promptText(
  BuildContext context, {
  required String titulo,
  required String label,
  String? valorInicial,
}) {
  final controller = TextEditingController(text: valorInicial);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: label),
        onSubmitted: (v) => Navigator.pop(context, v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text('Salvar'),
        ),
      ],
    ),
  );
}

Future<bool> confirmDelete(BuildContext context, String titulo) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: const Text('Essa ação não pode ser desfeita.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
  return ok ?? false;
}
