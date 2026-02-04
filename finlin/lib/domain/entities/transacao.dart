/// Enum que define os tipos de transação
///
/// ENTRADA: Transação que aumenta o saldo (ex: salário, bônus)
/// SAIDA: Transação que diminui o saldo (ex: despesa, transferência)
enum TipoTransacao { entrada, saida }

/// Entidade que representa uma Transação financeira
///
/// Uma Transação registra uma movimentação de valor em uma Conta
/// e deve ser classificada com uma Categoria do mesmo tipo.
class Transacao {
  final String id;
  final String descricao;
  final double valor;
  final TipoTransacao tipo;
  final DateTime data;
  final String contaId;
  final String categoriaId;

  /// Construtor da entidade Transacao
  ///
  /// Parâmetros:
  /// - [id]: Identificador único da transação
  /// - [descricao]: Descrição da transação (ex: "Compra no supermercado")
  /// - [valor]: Valor da transação em reais (sempre positivo)
  /// - [tipo]: Tipo da transação (ENTRADA ou SAIDA)
  /// - [data]: Data e hora da transação
  /// - [contaId]: ID da conta afetada pela transação
  /// - [categoriaId]: ID da categoria de classificação
  Transacao({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.tipo,
    required this.data,
    required this.contaId,
    required this.categoriaId,
  });

  /// Cria uma cópia da Transacao com valores opcionais substituídos
  Transacao copyWith({
    String? id,
    String? descricao,
    double? valor,
    TipoTransacao? tipo,
    DateTime? data,
    String? contaId,
    String? categoriaId,
  }) {
    return Transacao(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      tipo: tipo ?? this.tipo,
      data: data ?? this.data,
      contaId: contaId ?? this.contaId,
      categoriaId: categoriaId ?? this.categoriaId,
    );
  }

  /// Retorna a data formatada como string
  String get dataTransacao => '${data.day}/${data.month}/${data.year}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transacao &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          descricao == other.descricao &&
          valor == other.valor &&
          tipo == other.tipo &&
          data == other.data &&
          contaId == other.contaId &&
          categoriaId == other.categoriaId;

  @override
  int get hashCode =>
      id.hashCode ^
      descricao.hashCode ^
      valor.hashCode ^
      tipo.hashCode ^
      data.hashCode ^
      contaId.hashCode ^
      categoriaId.hashCode;

  @override
  String toString() =>
      'Transacao(id: $id, descricao: $descricao, valor: $valor, tipo: $tipo, data: $data, contaId: $contaId, categoriaId: $categoriaId)';
}
