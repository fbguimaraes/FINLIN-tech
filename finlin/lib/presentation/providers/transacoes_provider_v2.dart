import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/api_client_v2.dart';
import '../../data/models/transacao_model.dart';
import '../../domain/entities/transacao.dart';
import 'login_provider.dart';

/// Provider que busca transações da API
final transacoesProvider = FutureProvider<List<Transacao>>((ref) async {
  // Observar estado de login
  final loginState = ref.watch(loginProvider);
  
  if (!loginState.isAuthenticated) {
    throw Exception('Usuário não autenticado');
  }

  // Obter cliente de API
  final apiClient = ref.watch(apiClientProvider);
  
  try {
    print('📈 Iniciando busca de transações...');
    final transacoesData = await apiClient.getTransacoes();
    print('✅ ${transacoesData.length} transações recebidas');
    
    final transacoes = transacoesData
        .map((json) => TransacaoModel.fromJson(json as Map<String, dynamic>))
        .toList();
    
    return transacoes;
  } catch (e) {
    print('❌ Erro ao carregar transações: $e');
    throw Exception('Erro ao carregar transações: $e');
  }
});
