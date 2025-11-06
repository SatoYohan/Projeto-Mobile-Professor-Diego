import 'package:flutter/material.dart';
import '../../models/usuario_model.dart';
import '../../service/firestore_service.dart';

class TelaSelecaoPerfil extends StatelessWidget {
  // Recebe o usuário que acabou de logar
  final Usuario usuario;

  TelaSelecaoPerfil({super.key, required this.usuario});

  final FirestoreService _firestoreService = FirestoreService();

  // Função para definir o tipo de perfil e navegar
  void _selecionarPerfil(BuildContext context, String tipo) async {
    // Atualiza o perfil no Firestore
    await _firestoreService.setUserProfileType(usuario.id, tipo);

    // O AuthGate (que está ouvindo) vai detectar a mudança e
    // navegar para a tela correta automaticamente.
    // Não precisamos de Navigator.push aqui.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Último Passo!'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Olá, ${usuario.nome}!', // Mostra o nome do usuário
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Para continuar, selecione o seu tipo de perfil. (Esta ação é permanente)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                icon: const Icon(Icons.medical_services_rounded),
                label: const Text('Sou Médico'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () => _selecionarPerfil(context, 'medico'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_rounded),
                label: const Text('Sou Paciente'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _selecionarPerfil(context, 'paciente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
