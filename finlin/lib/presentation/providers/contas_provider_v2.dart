import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/api_client_v2.dart';
import '../../data/models/conta_model.dart';
import '../../domain/entities/conta.dart';
import 'login_provider.dart';
import 'transacoes_provider_v2.dart';

/// Provider do cliente API (singleton)
final apiClientProvider = Provider<ApiClientV2>((ref) {
  return ApiClientV2();
});

/// Provider que busca contas da API sempre que o estado de login muda
/// Depende de transações para manter saldo sempre atualizado
final contasProvider = FutureProvider<List<Conta>>((ref) async {
  // Observar o estado de login
  final loginState = ref.watch(loginProvider);

  // Se não estiver autenticado, lançar erro
  if (!loginState.isAuthenticated) {
    throw Exception('Usuário não autenticado');
  }

  // Obter o cliente de API (singleton)
  final apiClient = ref.watch(apiClientProvider);

  // 🔄 Observar transações para recarregar contas quando transações mudam
  // Isso garante que o saldo está sempre sincronizado
  try {
    await ref.watch(transacoesProvider.future);
  } catch (e) {
    print('⚠️ Aviso ao observar transações: $e');
  }

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

    // Ordenar por nome para melhor UX
    contas.sort((a, b) => a.nome.compareTo(b.nome));

    return contas;
  } catch (e) {
    print('❌ Erro ao carregar contas: $e');
    throw Exception('Erro ao carregar contas: $e');
  }
});
