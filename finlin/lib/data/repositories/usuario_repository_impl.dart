import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../datasources/usuario_remote_datasource.dart';

/// Implementação do UsuarioRepository
///
/// Faz a mediação entre o datasource e o domínio.
class UsuarioRepositoryImpl implements UsuarioRepository {
  final UsuarioRemoteDataSource remoteDataSource;

  UsuarioRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Usuario> login(String email, String senha) async {
    try {
      return await remoteDataSource.login(email, senha);
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  @override
  Future<Usuario> getUsuarioAtual() async {
    try {
      // TODO: Recuperar token armazenado localmente
      return await remoteDataSource.getUsuarioAtual('dummy_token');
    } catch (e) {
      throw Exception('Erro ao buscar usuário: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      return await remoteDataSource.logout();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }
}
