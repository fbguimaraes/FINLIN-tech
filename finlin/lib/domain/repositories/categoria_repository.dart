import '../entities/categoria.dart';

/// Interface do repositório de Categoria
///
/// Define o contrato para acesso a dados de categorias.
abstract class CategoriaRepository {
  /// Obtém lista de categorias do usuário autenticado
  ///
  /// Retorna:
  /// - Lista de [Categoria] do usuário
  Future<List<Categoria>> getCategorias();

  /// Obtém categorias filtradas por tipo
  ///
  /// Parâmetros:
  /// - [tipo]: Tipo de categoria a filtrar (ENTRADA ou SAIDA)
  ///
  /// Retorna:
  /// - Lista de [Categoria] do tipo especificado
  Future<List<Categoria>> getCategoriasPorTipo(String tipo);
}
