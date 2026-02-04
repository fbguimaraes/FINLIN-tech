import '../entities/transacao.dart';

/// Interface do repositório de Transacao
///
/// Define o contrato para acesso a dados de transações.
abstract class TransacaoRepository {
  /// Obtém lista de transações do usuário autenticado
  ///
  /// Retorna:
  /// - Lista de [Transacao] do usuário
  Future<List<Transacao>> getTransacoes();

  /// Obtém transações de uma conta específica
  ///
  /// Parâmetros:
  /// - [contaId]: ID da conta para filtrar transações
  ///
  /// Retorna:
  /// - Lista de [Transacao] da conta
  Future<List<Transacao>> getTransacoesPorConta(String contaId);

  /// Obtém relatório mensal (entradas, saídas e saldo)
  ///
  /// Parâmetros:
  /// - [mes]: Mês (1-12)
  /// - [ano]: Ano em formato YYYY
  ///
  /// Retorna:
  /// - Map com dados do relatório (será expandido conforme necessário)
  Future<Map<String, dynamic>> getRelatorioMensal(int mes, int ano);

  /// Cria uma nova transação
  ///
  /// Parâmetros:
  /// - [transacao]: Transação a ser criada
  ///
  /// Retorna:
  /// - [Transacao] criada com ID gerado
  Future<Transacao> criar(Transacao transacao);

  /// Deleta uma transação
  ///
  /// Parâmetros:
  /// - [id]: ID da transação a deletar
  Future<void> deletar(String id);
}
