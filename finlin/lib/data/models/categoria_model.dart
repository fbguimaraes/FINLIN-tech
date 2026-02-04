import '../../domain/entities/categoria.dart';

/// Model de Categoria para mapeamento de dados
///
/// Responsável por converter dados JSON da API em Entidades de Domínio.
class CategoriaModel extends Categoria {
  CategoriaModel({
    required String id,
    required String nome,
    required TipoCategoria tipo,
    required String usuarioId,
  }) : super(id: id, nome: nome, tipo: tipo, usuarioId: usuarioId);

  /// Factory para criar CategoriaModel a partir de JSON da API
  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    final tipoStr = (json['tipo'] as String?)?.toLowerCase() ?? 'receita';
    // Mapear tanto 'entrada'/'receita' quanto 'saida'/'despesa'
    final tipo = (tipoStr == 'entrada' || tipoStr == 'receita')
        ? TipoCategoria.entrada
        : TipoCategoria.saida;

    return CategoriaModel(
      id: json['id_categoria']?.toString() ?? json['id'].toString() ?? '',
      nome: json['nome'] as String? ?? '',
      tipo: tipo,
      usuarioId: json['id_usuario']?.toString() ?? '',
    );
  }

  /// Converte o Model para JSON
  Map<String, dynamic> toJson() {
    return {
      'id_categoria': id,
      'nome': nome,
      'tipo': tipo == TipoCategoria.entrada ? 'receita' : 'despesa',
      'id_usuario': usuarioId,
    };
  }

  /// Cria uma cópia do CategoriaModel com valores opcionais substituídos
  @override
  CategoriaModel copyWith({
    String? id,
    String? nome,
    TipoCategoria? tipo,
    String? usuarioId,
  }) {
    return CategoriaModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      usuarioId: usuarioId ?? this.usuarioId,
    );
  }
}
