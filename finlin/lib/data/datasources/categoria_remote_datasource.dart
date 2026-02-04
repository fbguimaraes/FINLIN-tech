import '../../domain/entities/categoria.dart';
import '../../core/constants/app_constants.dart';
import '../models/categoria_model.dart';
import 'api_client.dart';

/// DataSource remoto para Categoria
///
/// Faz chamadas HTTP para a API através do ApiClient.
class CategoriaRemoteDataSource {
  final ApiClient apiClient;

  CategoriaRemoteDataSource({required this.apiClient});

  /// Obtém categorias da API
  Future<List<CategoriaModel>> getCategorias(String token) async {
    try {
      final response = await apiClient.getCategorias(token);
      return response.map((e) => CategoriaModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar categorias: $e');
    }
  }

  /// Obtém categorias filtradas por tipo
  Future<List<CategoriaModel>> getCategoriasPorTipo(
    String tipo,
    String token,
  ) async {
    try {
      final todasCategorias = await getCategorias(token);

      final tipoEnum = tipo.toLowerCase() == 'entrada'
          ? TipoCategoria.entrada
          : TipoCategoria.saida;

      return todasCategorias.where((cat) => cat.tipo == tipoEnum).toList();
    } catch (e) {
      throw Exception('Erro ao filtrar categorias: $e');
    }
  }

  /// Cria uma nova categoria
  Future<CategoriaModel> criarCategoria({
    required String nome,
    required String tipo,
    required String token,
  }) async {
    try {
      final response = await apiClient.criarCategoria(
        dadosCategoria: {
          'nome': nome,
          'tipo': tipo,
        },
        token: token,
      );
      return CategoriaModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar categoria: $e');
    }
  }
}
