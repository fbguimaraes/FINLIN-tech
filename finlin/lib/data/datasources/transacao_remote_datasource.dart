import '../models/transacao_model.dart';
import 'api_client.dart';

/// DataSource remoto para Transacao
///
/// Faz chamadas HTTP para a API através do ApiClient.
class TransacaoRemoteDataSource {
  final ApiClient apiClient;

  TransacaoRemoteDataSource({required this.apiClient});

  /// Obtém transações da API
  Future<List<TransacaoModel>> getTransacoes(String token) async {
    try {
      final response = await apiClient.getTransacoes(token);
      return response.map((e) => TransacaoModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar transações: $e');
    }
  }

  /// Obtém transações de uma conta específica
  Future<List<TransacaoModel>> getTransacoesPorConta(
    String contaId,
    String token,
  ) async {
    try {
      final response = await apiClient.getTransacoesConta(contaId, token);
      return response.map((e) => TransacaoModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar transações da conta: $e');
    }
  }

  /// Cria uma nova transação
  Future<TransacaoModel> criar({
    required String descricao,
    required double valor,
    required String tipo,
    required String contaId,
    required String categoriaId,
    required DateTime dataTransacao,
    required String token,
  }) async {
    try {
      final response = await apiClient.criarTransacao(
        dadosTransacao: {
          'descricao': descricao,
          'valor': valor,
          'tipo': tipo,
          'id_conta': contaId,
          'id_categoria': categoriaId,
          'data_transacao': dataTransacao.toIso8601String(),
        },
        token: token,
      );
      return TransacaoModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar transação: $e');
    }
  }

  /// Deleta uma transação
  Future<void> deletar(String id, String token) async {
    try {
      // TODO: Implementar DELETE na API
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      throw Exception('Erro ao deletar transação: $e');
    }
  }
}
