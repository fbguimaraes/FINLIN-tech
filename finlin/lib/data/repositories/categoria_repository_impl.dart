import '../../domain/entities/categoria.dart';
import '../../domain/repositories/categoria_repository.dart';
import '../datasources/categoria_remote_datasource.dart';

/// Implementação do CategoriaRepository
///
/// Faz a mediação entre o datasource e o domínio.
class CategoriaRepositoryImpl implements CategoriaRepository {
  final CategoriaRemoteDataSource remoteDataSource;

  CategoriaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Categoria>> getCategorias() async {
    try {
      // TODO: Recuperar token armazenado localmente
      return await remoteDataSource.getCategorias('dummy_token');
    } catch (e) {
      throw Exception('Erro ao buscar categorias: $e');
    }
  }

  @override
  Future<List<Categoria>> getCategoriasPorTipo(String tipo) async {
    try {
      return await remoteDataSource.getCategoriasPorTipo(tipo, 'dummy_token');
    } catch (e) {
      throw Exception('Erro ao buscar categorias: $e');
    }
  }
}
