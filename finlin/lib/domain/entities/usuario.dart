/// Entidade que representa um Usuário do sistema
///
/// Usuário é a entidade raiz que agrupa contas, categorias e transações.
/// Implementa imutabilidade para garantir previsibilidade do estado.
class Usuario {
  final String id;
  final String nome;
  final String email;

  /// Construtor da entidade Usuario
  ///
  /// Parâmetros:
  /// - [id]: Identificador único do usuário
  /// - [nome]: Nome completo do usuário
  /// - [email]: Email do usuário
  Usuario({required this.id, required this.nome, required this.email});

  /// Cria uma cópia do Usuario com valores opcionais substituídos
  Usuario copyWith({String? id, String? nome, String? email}) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Usuario &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nome == other.nome &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ nome.hashCode ^ email.hashCode;

  @override
  String toString() => 'Usuario(id: $id, nome: $nome, email: $email)';
}
