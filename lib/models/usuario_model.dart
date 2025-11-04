enum TipoUsuario { medico, paciente }

class Usuario {
  final String id;
  final String nome;
  final TipoUsuario tipo;

  Usuario({required this.id, required this.nome, required this.tipo});
}
