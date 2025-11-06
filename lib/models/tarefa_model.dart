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

  // --- MÉTODOS ADICIONADOS PARA O FIRESTORE ---

  /// Converte um objeto Tarefa (este) para um Map (JSON)
  /// Usado para salvar a tarefa *dentro* de um documento de Prontuário
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'concluida': concluida,
    };
  }

  /// Converte um Map (JSON) (vindo do Firestore) para um objeto Tarefa
  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'] ?? '',
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      concluida: map['concluida'] ?? false,
    );
  }
}
