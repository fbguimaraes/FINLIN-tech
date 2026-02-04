import '../models/conta_model.dart';
import 'api_client.dart';

/// DataSource remoto para Conta
///
/// Faz chamadas HTTP para a API através do ApiClient.
class ContaRemoteDataSource {
  final ApiClient apiClient;

  ContaRemoteDataSource({required this.apiClient});

  /// Obtém contas da API
  Future<List<ContaModel>> getContas(String token) async {
    try {
      final response = await apiClient.getContas(token);
      return response.map((e) => ContaModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar contas: $e');
    }
  }

  /// Obtém uma conta por ID
  Future<ContaModel?> getContaById(String id, String token) async {
    try {
      final response = await apiClient.getContaById(id, token);
      return ContaModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Cria uma nova conta
  Future<ContaModel> criarConta({
    required String nome,
    required String tipo,
    required double saldoInicial,
    required String token,
  }) async {
    try {
      final response = await apiClient.criarConta(
        dadosConta: {'nome': nome, 'tipo': tipo, 'saldo_inicial': saldoInicial},
        token: token,
      );
      return ContaModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar conta: $e');
    }
  }
}
