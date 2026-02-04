/// Entidade que representa uma Conta bancária do usuário
///
/// A Conta agrega transações e possui um saldo que é calculado
/// a partir do somatório das transações.
class Conta {
  final String id;
  final String nome;
  final double saldo;
  final String usuarioId;
  final String tipo;

  /// Construtor da entidade Conta
  ///
  /// Parâmetros:
  /// - [id]: Identificador único da conta
  /// - [nome]: Nome descritivo da conta (ex: "Conta Corrente", "Poupança")
  /// - [saldo]: Saldo atual da conta em reais
  /// - [usuarioId]: ID do usuário proprietário da conta
  /// - [tipo]: Tipo de conta (ex: "corrente", "poupança")
  Conta({
    required this.id,
    required this.nome,
    required this.saldo,
    required this.usuarioId,
    this.tipo = 'corrente',
  });

  /// Cria uma cópia da Conta com valores opcionais substituídos
  Conta copyWith({
    String? id,
    String? nome,
    double? saldo,
    String? usuarioId,
    String? tipo,
  }) {
    return Conta(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      saldo: saldo ?? this.saldo,
      usuarioId: usuarioId ?? this.usuarioId,
      tipo: tipo ?? this.tipo,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Conta &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nome == other.nome &&
          saldo == other.saldo &&
          usuarioId == other.usuarioId &&
          tipo == other.tipo;

  @override
  int get hashCode =>
      id.hashCode ^
      nome.hashCode ^
      saldo.hashCode ^
      usuarioId.hashCode ^
      tipo.hashCode;

  @override
  String toString() =>
      'Conta(id: $id, nome: $nome, saldo: $saldo, usuarioId: $usuarioId, tipo: $tipo)';
}

