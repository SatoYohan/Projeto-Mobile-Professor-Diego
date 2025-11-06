// --- MODELO ---
// Define a estrutura de dados para uma Tarefa.
class Tarefa {
  final String id;
  String titulo;
  String descricao;
  bool concluida;

  Tarefa({
    required this.id,
    required this.titulo,
    required this.descricao,
    this.concluida = false,
  });
}
