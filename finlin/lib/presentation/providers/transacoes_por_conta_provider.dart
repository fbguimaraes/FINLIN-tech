import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transacao_model.dart';
import '../../data/datasources/api_client_v2.dart';

/// Provider que busca transações de uma conta específica
final transacoesPorContaProvider = FutureProvider.family<List<TransacaoModel>, String>(
  (ref, idConta) async {
    final apiClient = ApiClientV2();
    
    if (apiClient.authToken == null) {
      throw Exception('Não autenticado');
    }

    try {
      print('📥 Buscando transações da conta $idConta');
      
      final response = await apiClient.getTransacoesPorConta(idConta);
      
      final transacoes = (response as List)
          .map((json) => TransacaoModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      print('✅ ${transacoes.length} transações carregadas');
      return transacoes;
    } catch (e) {
      print('❌ Erro ao carregar transações: $e');
      rethrow;
    }
  },
);
