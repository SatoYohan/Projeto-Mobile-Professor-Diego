import 'package:flutter/material.dart';
import '../../models/usuario_model.dart';
import '../../repositories/app_repository.dart';
import '../../service/auth_service.dart'; // <-- IMPORTAR AUTH
import '../comum/tela_editar_perfil.dart'; // <-- IMPORTAR TELA DE PERFIL
import 'tela_detalhes_paciente.dart';

class TelaListaPacientes extends StatefulWidget {
  final Usuario medico;
  const TelaListaPacientes({super.key, required this.medico});

  @override
  State<TelaListaPacientes> createState() => _TelaListaPacientesState();
}

class _TelaListaPacientesState extends State<TelaListaPacientes> {
  final AppRepository _repository = AppRepository();
  final AuthService _authService = AuthService(); // <-- INSTANCIAR AUTH
  late Future<List<Usuario>> _futurePacientes;

  @override
  void initState() {
    super.initState();
    _futurePacientes = _repository.getPacientes();
  }

  // --- MÉTODO PARA NAVEGAR PARA O PERFIL ---
  void _navegarParaPerfil(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // Passa o objeto 'medico' (que é um Usuario) para a tela de edição
        builder: (context) => TelaEditarPerfil(usuario: widget.medico),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Pacientes - ${widget.medico.nome}'),
        // --- BOTÕES ADICIONADOS AQUI ---
        actions: [
          // Botão de Perfil
          IconButton(
            icon: const Icon(Icons.person_rounded),
            tooltip: 'Editar Perfil',
            onPressed: () => _navegarParaPerfil(context),
          ),
          // Botão de Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await _authService.signOut();
              // O AuthGate vai detectar o logout e levar para a TelaLogin
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Usuario>>(
        future: _futurePacientes,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final pacientes = snapshot.data!;
          return ListView.builder(
            itemCount: pacientes.length,
            itemBuilder: (context, index) {
              final paciente = pacientes[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(paciente.nome),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TelaDetalhesPaciente(paciente: paciente),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
