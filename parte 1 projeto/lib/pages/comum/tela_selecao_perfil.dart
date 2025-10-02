import 'package:flutter/material.dart';
import '../../models/usuario_model.dart';
import '../../repositories/app_repository.dart';
import '../medico/tela_lista_pacientes.dart';
import '../paciente/tela_lista_tarefas_paciente.dart';

class TelaSelecaoPerfil extends StatefulWidget {
  const TelaSelecaoPerfil({super.key});

  @override
  State<TelaSelecaoPerfil> createState() => _TelaSelecaoPerfilState();
}

class _TelaSelecaoPerfilState extends State<TelaSelecaoPerfil> {
  final AppRepository _repository = AppRepository();

  void _entrarComo(Usuario usuario) {
    if (usuario.tipo == TipoUsuario.medico) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TelaListaPacientes(medico: usuario)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TelaListaTarefasPaciente(paciente: usuario)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bem-vindo! Selecione seu perfil')),
      body: FutureBuilder<List<Usuario>>(
        future: _repository.getTodosUsuarios(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final usuarios = snapshot.data!;
          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final usuario = usuarios[index];
              final isMedico = usuario.tipo == TipoUsuario.medico;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Icon(isMedico ? Icons.medical_services : Icons.person, size: 40),
                  title: Text(usuario.nome),
                  subtitle: Text(isMedico ? 'Médico' : 'Paciente'),
                  onTap: () => _entrarComo(usuario),
                ),
              );
            },
          );
        },
      ),
    );
  }
}