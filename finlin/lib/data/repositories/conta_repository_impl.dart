import '../../domain/entities/conta.dart';
import '../../domain/repositories/conta_repository.dart';
import '../datasources/conta_remote_datasource.dart';

/// Implementação do ContaRepository
///
/// Faz a mediação entre o datasource e o domínio.
class ContaRepositoryImpl implements ContaRepository {
  final ContaRemoteDataSource remoteDataSource;

  ContaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Conta>> getContas() async {
    try {
      // TODO: Recuperar token armazenado localmente
      return await remoteDataSource.getContas('dummy_token');
    } catch (e) {
      throw Exception('Erro ao buscar contas: $e');
    }
  }

  @override
  Future<Conta?> getContaById(String id) async {
    try {
      return await remoteDataSource.getContaById(id, 'dummy_token');
    } catch (e) {
      return null;
    }
  }
}
