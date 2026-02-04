/// Enum que define os tipos de categoria
///
/// ENTRADA: Categoria para transações que aumentam o saldo
/// SAIDA: Categoria para transações que diminuem o saldo
enum TipoCategoria { entrada, saida }

/// Entidade que representa uma Categoria de transação
///
/// Categorias são utilizadas para classificar transações e devem
/// ser do mesmo tipo que a transação (ENTRADA ou SAIDA).
class Categoria {
  final String id;
  final String nome;
  final TipoCategoria tipo;
  final String usuarioId;

  /// Construtor da entidade Categoria
  ///
  /// Parâmetros:
  /// - [id]: Identificador único da categoria
  /// - [nome]: Nome da categoria (ex: "Alimentação", "Salário")
  /// - [tipo]: Tipo da categoria (ENTRADA ou SAIDA)
  /// - [usuarioId]: ID do usuário proprietário da categoria
  Categoria({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.usuarioId,
  });

  /// Cria uma cópia da Categoria com valores opcionais substituídos
  Categoria copyWith({
    String? id,
    String? nome,
    TipoCategoria? tipo,
    String? usuarioId,
  }) {
    return Categoria(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      usuarioId: usuarioId ?? this.usuarioId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Categoria &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nome == other.nome &&
          tipo == other.tipo &&
          usuarioId == other.usuarioId;

  @override
  int get hashCode =>
      id.hashCode ^ nome.hashCode ^ tipo.hashCode ^ usuarioId.hashCode;

  @override
  String toString() =>
      'Categoria(id: $id, nome: $nome, tipo: $tipo, usuarioId: $usuarioId)';
}
