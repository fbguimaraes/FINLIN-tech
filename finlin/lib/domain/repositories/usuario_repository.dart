import '../entities/usuario.dart';

/// Interface do repositório de Usuario
///
/// Define o contrato para acesso a dados de usuários.
/// Implementações podem vir de API REST, banco local, etc.
abstract class UsuarioRepository {
  /// Realiza login do usuário
  ///
  /// Parâmetros:
  /// - [email]: Email do usuário
  /// - [senha]: Senha do usuário (não será de verdade, é mock)
  ///
  /// Retorna:
  /// - [Usuario] se login bem-sucedido
  /// - Exception se falhar
  Future<Usuario> login(String email, String senha);

  /// Obtém os dados do usuário autenticado
  Future<Usuario> getUsuarioAtual();

  /// Realiza logout do usuário
  Future<void> logout();
}
