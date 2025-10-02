import 'dart:math';
import '../models/prontuario_model.dart';
import '../models/tarefa_model.dart';
import '../models/usuario_model.dart';

// Simula nosso banco de dados e lógica de acesso a dados
class AppRepository {
  static final AppRepository _instancia = AppRepository._interno();
  factory AppRepository() => _instancia;

  // --- DADOS EM MEMÓRIA (BANCO DE DADOS FALSO) ---
  final List<Usuario> _usuarios = [];
  final List<Prontuario> _prontuarios = [];

  AppRepository._interno() {
    _popularDadosIniciais();
  }

  // Popula o app com dados de exemplo
  void _popularDadosIniciais() {
    // Criar Usuários
    var medico1 = Usuario(id: 'med1', nome: 'Dr. House', tipo: TipoUsuario.medico);
    var paciente1 = Usuario(id: 'pac1', nome: 'João da Silva', tipo: TipoUsuario.paciente);
    var paciente2 = Usuario(id: 'pac2', nome: 'Maria Oliveira', tipo: TipoUsuario.paciente);
    _usuarios.addAll([medico1, paciente1, paciente2]);

    // Criar Tarefas e Prontuários para o Paciente 1
    var tarefasP1 = [
      Tarefa(id: 't1', titulo: 'Tomar Vitamina D', descricao: '1 cápsula após o almoço', concluida: true),
      Tarefa(id: 't2', titulo: 'Caminhada leve', descricao: '30 minutos, 3 vezes por semana'),
    ];
    var prontuario1 = Prontuario(
      id: 'pront1',
      pacienteId: 'pac1',
      dataConsulta: DateTime.now().subtract(const Duration(days: 10)),
      notasMedico: 'Paciente apresenta deficiência de vitamina D. Recomendo suplementação e atividade física.',
      tarefas: tarefasP1,
    );

    // Criar Tarefas e Prontuários para o Paciente 2
    var tarefasP2 = [
      Tarefa(id: 't3', titulo: 'Medir pressão', descricao: 'Medir diariamente pela manhã'),
    ];
    var prontuario2 = Prontuario(
      id: 'pront2',
      pacienteId: 'pac2',
      dataConsulta: DateTime.now().subtract(const Duration(days: 5)),
      notasMedico: 'Acompanhar pressão arterial por uma semana. Retornar com anotações.',
      tarefas: tarefasP2,
    );

    _prontuarios.addAll([prontuario1, prontuario2]);
  }
  
  // --- MÉTODOS DE ACESSO ---

  Future<List<Usuario>> getTodosUsuarios() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _usuarios;
  }

  Future<List<Usuario>> getPacientes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _usuarios.where((u) => u.tipo == TipoUsuario.paciente).toList();
  }
  
  Future<List<Prontuario>> getProntuariosPorPaciente(String pacienteId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _prontuarios.where((p) => p.pacienteId == pacienteId).toList();
  }

  Future<List<Tarefa>> getTarefasPorPaciente(String pacienteId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final tarefas = _prontuarios
        .where((p) => p.pacienteId == pacienteId)
        .expand((p) => p.tarefas) // "Achata" a lista de listas de tarefas
        .toList();
    return tarefas;
  }

  Future<void> salvarProntuario(Prontuario prontuario) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _prontuarios.indexWhere((p) => p.id == prontuario.id);
    if(index >= 0) {
      _prontuarios[index] = prontuario;
    } else {
       _prontuarios.add(prontuario);
    }
  }

  // Atualiza o status de uma tarefa específica
  Future<void> atualizarStatusTarefa(String prontuarioId, String tarefaId, bool concluida) async {
      final prontuario = _prontuarios.firstWhere((p) => p.id == prontuarioId);
      final tarefa = prontuario.tarefas.firstWhere((t) => t.id == tarefaId);
      tarefa.concluida = concluida;
  }
}
