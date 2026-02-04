import '../../domain/entities/transacao.dart';

/// Model de Transacao para mapeamento de dados
///
/// Responsável por converter dados JSON da API em Entidades de Domínio.
class TransacaoModel extends Transacao {
  TransacaoModel({
    required String id,
    required String descricao,
    required double valor,
    required TipoTransacao tipo,
    required DateTime data,
    required String contaId,
    required String categoriaId,
  }) : super(
         id: id,
         descricao: descricao,
         valor: valor,
         tipo: tipo,
         data: data,
         contaId: contaId,
         categoriaId: categoriaId,
       );

  /// Factory para criar TransacaoModel a partir de JSON da API
  factory TransacaoModel.fromJson(Map<String, dynamic> json) {
    final tipoStr = (json['tipo'] as String?)?.toLowerCase() ?? 'despesa';
    final tipo = tipoStr == 'receita' ? TipoTransacao.entrada : TipoTransacao.saida;

    return TransacaoModel(
      id: json['id_transacao']?.toString() ?? json['id'].toString() ?? '',
      descricao: json['descricao'] as String? ?? '',
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      tipo: tipo,
      data: json['data_transacao'] != null
          ? DateTime.parse(json['data_transacao'] as String)
          : DateTime.now(),
      contaId: json['id_conta']?.toString() ?? '',
      categoriaId: json['id_categoria']?.toString() ?? '',
    );
  }

  /// Converte o Model para JSON
  Map<String, dynamic> toJson() {
    return {
      'id_transacao': id,
      'descricao': descricao,
      'valor': valor,
      'tipo': tipo == TipoTransacao.entrada ? 'receita' : 'despesa',
      'data_transacao': data.toIso8601String(),
      'id_conta': contaId,
      'id_categoria': categoriaId,
    };
  }

  /// Cria uma cópia do TransacaoModel com valores opcionais substituídos
  @override
  TransacaoModel copyWith({
    String? id,
    String? descricao,
    double? valor,
    TipoTransacao? tipo,
    DateTime? data,
    String? contaId,
    String? categoriaId,
  }) {
    return TransacaoModel(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      tipo: tipo ?? this.tipo,
      data: data ?? this.data,
      contaId: contaId ?? this.contaId,
      categoriaId: categoriaId ?? this.categoriaId,
    );
  }
}
