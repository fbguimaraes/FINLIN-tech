import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/login_screen_v2.dart';
import 'presentation/screens/home_screen_v2.dart';
import 'presentation/screens/transacoes_screen.dart';
import 'presentation/screens/relatorio_screen.dart';
import 'presentation/screens/conta_detalhes_screen.dart';
import 'presentation/screens/categorias_screen.dart';
import 'presentation/providers/login_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

/// Aplicativo principal FINLIN
///
/// Gerenciamento de estado com Riverpod
/// Arquitetura limpa com separação entre camadas
class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginProvider);
    final isAuthenticated = loginState.isAuthenticated;

    return MaterialApp(
      title: 'FINLIN - Controle Financeiro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(elevation: 2, centerTitle: false),
      ),
      home: isAuthenticated ? const HomeScreenV2() : const LoginScreenV2(),
      routes: {
        '/relatorio': (context) => const RelatorioScreen(),
        '/categorias': (context) => const CategoriasScreen(),
        '/conta-detalhes': (context) {
          final contaId = ModalRoute.of(context)?.settings.arguments as String?;
          return ContaDetalhesScreen(contaId: contaId ?? '');
        },
      },
    );
  }
}
