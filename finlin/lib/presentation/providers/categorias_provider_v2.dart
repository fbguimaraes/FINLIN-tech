import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/api_client_v2.dart';
import '../../data/models/categoria_model.dart';
import '../../domain/entities/categoria.dart';
import 'login_provider.dart';

/// Provider do cliente API (singleton)
final apiClientProvider = Provider<ApiClientV2>((ref) {
  return ApiClientV2();
});

/// Provider que busca categorias da API em tempo real
final categoriasProvider = FutureProvider<List<Categoria>>((ref) async {
  // Observar estado de login
  final loginState = ref.watch(loginProvider);

  if (!loginState.isAuthenticated) {
    throw Exception('Usuário não autenticado');
  }

  // Obter cliente de API
  final apiClient = ref.watch(apiClientProvider);

  try {
    print('📁 Iniciando busca de categorias...');
    final categoriasData = await apiClient.getCategorias();
    print('✅ ${categoriasData.length} categorias recebidas');

    final categorias = categoriasData
        .map((json) => CategoriaModel.fromJson(json as Map<String, dynamic>))
        .toList();

    // Ordenar por tipo e nome
    categorias.sort((a, b) {
      final tipoCompare = a.tipo.toString().compareTo(b.tipo.toString());
      if (tipoCompare != 0) return tipoCompare;
      return a.nome.compareTo(b.nome);
    });

    return categorias;
  } catch (e) {
    print('❌ Erro ao carregar categorias: $e');
    throw Exception('Erro ao carregar categorias: $e');
  }
});
