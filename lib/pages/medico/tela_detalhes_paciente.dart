import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/prontuario_model.dart';
import '../../models/usuario_model.dart';
import '../../repositories/app_repository.dart';
import 'tela_formulario_prontuario.dart'; // <-- IMPORT ADICIONADO

class TelaDetalhesPaciente extends StatefulWidget {
  final Usuario paciente;
  const TelaDetalhesPaciente({super.key, required this.paciente});

  @override
  State<TelaDetalhesPaciente> createState() => _TelaDetalhesPacienteState();
}

class _TelaDetalhesPacienteState extends State<TelaDetalhesPaciente> {
  final AppRepository _repository = AppRepository();
  late Future<List<Prontuario>> _futureProntuarios;

  @override
  void initState() {
    super.initState();
    _carregarProntuarios();
  }

  void _carregarProntuarios() {
    setState(() {
      _futureProntuarios = _repository.getProntuariosPorPaciente(
        widget.paciente.id,
      );
    });
  }

  // --- MÉTODO ADICIONADO PARA NAVEGAÇÃO ---
  void _navegarParaFormulario() async {
    // Navega para o formulário e espera um resultado
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TelaFormularioProntuario(paciente: widget.paciente),
      ),
    );

    // Se o formulário retornou 'true' (indicando sucesso),
    // recarrega a lista de prontuários.
    if (resultado == true && mounted) {
      _carregarProntuarios();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prontuários de ${widget.paciente.nome}')),
      body: FutureBuilder<List<Prontuario>>(
        future: _futureProntuarios,
        builder: (context, snapshot) {
          // --- CORREÇÃO DE LÓGICA DE LOADING ---
          // Verifica o estado da conexão para um loading mais robusto
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar prontuários.'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum prontuário encontrado.'));
          }

          final prontuarios = snapshot.data!;

          return ListView.builder(
            itemCount: prontuarios.length,
            itemBuilder: (context, index) {
              final prontuario = prontuarios[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  leading: const Icon(Icons.folder_copy),
                  title: Text(
                    'Consulta - ${DateFormat('dd/MM/yyyy').format(prontuario.dataConsulta)}',
                  ),
                  subtitle: Text(
                    '${prontuario.tarefas.length} tarefa(s) designada(s)',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notas do Médico:',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium, // Alterado para titleMedium
                          ),
                          Text(prontuario.notasMedico),
                          const Divider(height: 20),
                          Text(
                            'Tarefas para o Paciente:',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium, // Alterado para titleMedium
                          ),
                          // Lista as tarefas dentro do prontuário
                          for (var tarefa in prontuario.tarefas)
                            ListTile(
                              leading: Icon(
                                tarefa.concluida
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                              ),
                              title: Text(tarefa.titulo),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // --- ONPRESSED CORRIGIDO ---
        onPressed: _navegarParaFormulario,
        child: const Icon(Icons.add),
        tooltip: 'Novo Prontuário',
      ),
    );
  }
}
