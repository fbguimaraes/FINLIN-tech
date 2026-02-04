import '../entities/conta.dart';

/// Interface do repositório de Conta
///
/// Define o contrato para acesso a dados de contas.
abstract class ContaRepository {
  /// Obtém lista de contas do usuário autenticado
  ///
  /// Retorna:
  /// - Lista de [Conta] do usuário
  Future<List<Conta>> getContas();

  /// Obtém uma conta específica pelo ID
  ///
  /// Parâmetros:
  /// - [id]: ID da conta
  ///
  /// Retorna:
  /// - [Conta] encontrada ou null
  Future<Conta?> getContaById(String id);
}
