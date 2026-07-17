String formatDataHora(DateTime dt) {
  String d2(int n) => n.toString().padLeft(2, '0');
  return '${d2(dt.day)}/${d2(dt.month)}/${dt.year} ${d2(dt.hour)}:${d2(dt.minute)}';
}
