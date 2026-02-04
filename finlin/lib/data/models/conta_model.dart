import '../../domain/entities/conta.dart';

/// Model de Conta para mapeamento de dados
///
/// Responsável por converter dados JSON da API em Entidades de Domínio.
class ContaModel extends Conta {
  ContaModel({
    required String id,
    required String nome,
    required double saldo,
    required String usuarioId,
    String tipo = 'corrente',
  }) : super(id: id, nome: nome, saldo: saldo, usuarioId: usuarioId, tipo: tipo);

  /// Factory para criar ContaModel a partir de JSON da API
  factory ContaModel.fromJson(Map<String, dynamic> json) {
    return ContaModel(
      id: json['id_conta']?.toString() ?? json['id'].toString() ?? '',
      nome: json['nome'] as String? ?? '',
      saldo: (json['saldo'] as num?)?.toDouble() ?? 0.0,
      usuarioId: json['id_usuario']?.toString() ?? '',
      tipo: json['tipo'] as String? ?? 'corrente',
    );
  }

  /// Converte o Model para JSON
  Map<String, dynamic> toJson() {
    return {
      'id_conta': id,
      'nome': nome,
      'saldo': saldo,
      'id_usuario': usuarioId,
      'tipo': tipo,
    };
  }

  /// Cria uma cópia do ContaModel com valores opcionais substituídos
  @override
  ContaModel copyWith({
    String? id,
    String? nome,
    double? saldo,
    String? usuarioId,
    String? tipo,
  }) {
    return ContaModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      saldo: saldo ?? this.saldo,
      usuarioId: usuarioId ?? this.usuarioId,
      tipo: tipo ?? this.tipo,
    );
  }
}
