import 'package:flutter/material.dart';
import '../../service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  // NOVOS CONTROLADORES
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _isLogin = true; // Controla se a tela é de Login ou Cadastro
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _alternarModo() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
      _formKey.currentState?.reset();
    });
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });

      try {
        if (_isLogin) {
          // Tenta fazer Login
          await _authService.signInWithEmailAndPassword(
            _emailController.text.trim(),
            _senhaController.text.trim(),
          );
        } else {
          // Tenta Criar Conta
          await _authService.createUserWithEmailAndPassword(
            _emailController.text.trim(),
            _senhaController.text.trim(),
            _nomeController.text.trim(), // Passa o nome
          );
        }
        // Se chegar aqui, o AuthGate vai lidar com a navegação
      } on FirebaseAuthException catch (e) {
        setState(() {
          // Mapeia erros comuns do Firebase para mensagens amigáveis
          if (e.code == 'user-not-found' || e.code == 'INVALID_credential') {
            _errorMessage = 'E-mail ou senha incorretos.';
          } else if (e.code == 'wrong-password') {
            _errorMessage = 'E-mail ou senha incorretos.';
          } else if (e.code == 'email-already-in-use') {
            _errorMessage = 'Este e-mail já está em uso.';
          } else if (e.code == 'weak-password') {
            _errorMessage = 'A senha deve ter pelo menos 6 caracteres.';
          } else {
            _errorMessage = 'Ocorreu um erro: ${e.message}';
          }
        });
      } finally {
        // mounted check is good practice
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Criar Conta'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Bem-vindo(a) à Clínica App',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 32),

                // --- NOVO CAMPO DE NOME (só aparece no cadastro) ---
                if (!_isLogin)
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu nome.';
                      }
                      return null;
                    },
                  ),
                if (!_isLogin) const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Por favor, insira um e-mail válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _senhaController,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 8),
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: Text(_isLogin ? 'Entrar' : 'Criar Conta'),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _alternarModo,
                  child: Text(
                    _isLogin
                        ? 'Não tem uma conta? Cadastre-se'
                        : 'Já tem uma conta? Faça login',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
