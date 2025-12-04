import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importamos o DateFormat
import '../../models/prontuario_model.dart';
import '../../models/usuario_model.dart';
import '../../service/auth_service.dart';
import '../../service/firestore_service.dart';
import '../comum/tela_editar_perfil.dart';

class TelaListaTarefasPaciente extends StatefulWidget {
  final Usuario paciente;
  const TelaListaTarefasPaciente({super.key, required this.paciente});

  @override
  State<TelaListaTarefasPaciente> createState() =>
      _TelaListaTarefasPacienteState();
}

class _TelaListaTarefasPacienteState extends State<TelaListaTarefasPaciente> {
  // Trocamos o repositório falso pelo serviço real do Firestore
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  // Não precisamos mais de _futureTarefas ou _carregarTarefas

  // --- MÉTODO PARA NAVEGAR PARA O PERFIL ---
  void _navegarParaPerfil(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaEditarPerfil(usuario: widget.paciente),
      ),
    );
  }

  // --- NOVO MÉTODO PARA ATUALIZAR A TAREFA (O 'UPDATE' DO CRUD) ---
  void _atualizarTarefa(String prontuarioId, String tarefaId, bool novoStatus) {
    // Chama o serviço do Firestore para salvar a mudança
    _firestoreService.atualizarStatusTarefa(prontuarioId, tarefaId, novoStatus);

    // Não precisamos de setState(), pois o StreamBuilder
    // vai reconstruir a tela automaticamente quando o banco de dados mudar.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minhas Tarefas - ${widget.paciente.nome}'),
        // Os botões de Perfil e Logout já estavam corretos
        actions: [
          IconButton(
            icon: const Icon(Icons.person_rounded),
            tooltip: 'Editar Perfil',
            onPressed: () => _navegarParaPerfil(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await _authService.signOut();
            },
          ),
        ],
      ),
      // --- FutureBuilder -> StreamBuilder ---
      // Agora ele "escuta" os prontuários em tempo real
      body: StreamBuilder<List<Prontuario>>(
        stream: _firestoreService.getProntuariosStream(widget.paciente.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar tarefas.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma tarefa designada.'));
          }

          // Agora temos a lista de prontuários
          final prontuarios = snapshot.data!;

          // Vamos usar um ListView para exibir os *prontuários*
          // E dentro de cada um, as *tarefas*
          return ListView.builder(
            itemCount: prontuarios.length,
            itemBuilder: (context, index) {
              final prontuario = prontuarios[index];

              // Não mostra o prontuário se não houver tarefas nele
              if (prontuario.tarefas.isEmpty) {
                return Container(); // Retorna um widget vazio
              }

              // Usamos um ExpansionTile (igual à tela do médico)
              // para organizar as tarefas por data de consulta
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  title: Text(
                    'Consulta - ${DateFormat('dd/MM/yyyy').format(prontuario.dataConsulta)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${prontuario.tarefas.length} tarefa(s) pendente(s)',
                  ),
                  initiallyExpanded: true, // Começa aberto
                  children: [
                    // Lista as tarefas dentro do prontuário
                    ...prontuario.tarefas.map((tarefa) {
                      return ListTile(
                        title: Text(tarefa.titulo),
                        subtitle: Text(tarefa.descricao),
                        leading: Checkbox(
                          value: tarefa.concluida,
                          // --- (U)PDATE: LÓGICA DO CHECKBOX ---
                          onChanged: (value) {
                            if (value == null) return;
                            // Chama o método para salvar no Firestore
                            _atualizarTarefa(prontuario.id, tarefa.id, value);
                          },
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
