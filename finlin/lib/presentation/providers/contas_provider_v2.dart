import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/api_client_v2.dart';
import '../../data/models/conta_model.dart';
import '../../domain/entities/conta.dart';
import 'login_provider.dart';

/// Provider que busca contas da API sempre que o estado de login muda
/// Usa Family para aceitar parâmetros
final contasProvider = FutureProvider<List<Conta>>((ref) async {
  // Observar o estado de login
  final loginState = ref.watch(loginProvider);
  
  // Se não estiver autenticado, lançar erro
  if (!loginState.isAuthenticated) {
    throw Exception('Usuário não autenticado');
  }

  // Obter o cliente de API (singleton)
  final apiClient = ref.watch(apiClientProvider);
  
  try {
    print('📊 Iniciando busca de contas...');
    print('🔓 Token presente: ${apiClient.isAuthenticated}');
    
    // Buscar contas da API
    final contasData = await apiClient.getContas();
    print('✅ ${contasData.length} contas recebidas da API');
    
    // Converter para entities
    final contas = contasData
        .map((json) => ContaModel.fromJson(json as Map<String, dynamic>))
        .toList();
    
    print('✅ Contas convertidas com sucesso');
    return contas;
  } catch (e) {
    print('❌ Erro ao carregar contas: $e');
    throw Exception('Erro ao carregar contas: $e');
  }
});

