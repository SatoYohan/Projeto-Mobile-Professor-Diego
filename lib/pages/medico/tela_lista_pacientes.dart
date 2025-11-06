import 'package:flutter/material.dart';
import '../../models/usuario_model.dart';
import '../../service/auth_service.dart';
import '../../service/firestore_service.dart';
import '../comum/tela_editar_perfil.dart';
import 'tela_detalhes_paciente.dart';

class TelaListaPacientes extends StatefulWidget {
  final Usuario medico;
  const TelaListaPacientes({super.key, required this.medico});

  @override
  State<TelaListaPacientes> createState() => _TelaListaPacientesState();
}

class _TelaListaPacientesState extends State<TelaListaPacientes> {
  // --- MUDANÇA DA REQ 2 ---
  // Trocamos o repositório falso pelo serviço real do Firestore
  final FirestoreService _firestoreService =
      FirestoreService(); // <-- ADICIONADO
  final AuthService _authService = AuthService();

  late Future<List<Usuario>> _futurePacientes;

  @override
  void initState() {
    super.initState();
    // --- MUDANÇA DA REQ 2 ---
    // Agora buscamos os pacientes REAIS do Firestore
    _futurePacientes = _firestoreService.getTodosPacientes();
  }

  // --- MÉTODO ADICIONADO PARA NAVEGAR PARA O PERFIL ---
  void _navegarParaPerfil(BuildContext context, Usuario usuario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaEditarPerfil(usuario: usuario),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pacientes - ${widget.medico.nome}'),
        // --- BOTÕES ADICIONADOS (Igual à tela do paciente) ---
        actions: [
          // Botão de Perfil
          IconButton(
            icon: const Icon(Icons.person_rounded),
            tooltip: 'Editar Perfil',
            onPressed: () => _navegarParaPerfil(context, widget.medico),
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar pacientes.'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum paciente encontrado.'));
          }

          final pacientes = snapshot.data!;

          return ListView.builder(
            itemCount: pacientes.length,
            itemBuilder: (context, index) {
              final paciente = pacientes[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(paciente.nome),
                  subtitle: Text(paciente.email), // Mostra o e-mail
                  onTap: () {
                    // A navegação para os detalhes do paciente continua
                    // funcionando da mesma forma
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
