import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Widget para exibir valores em formato de moeda
///
/// Exemplo: R$ 1.500,00
class MoedaWidget extends StatelessWidget {
  final double valor;
  final TextStyle? style;
  final bool destacar;

  const MoedaWidget({
    required this.valor,
    this.style,
    this.destacar = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatted = _formatarMoeda(valor);
    final textStyle = style ?? _getDefaultStyle(context, destacar);

    return Text(formatted, style: textStyle);
  }

  /// Formata um valor em moeda brasileira
  String _formatarMoeda(double valor) {
    final absValor = valor.abs();
    final inteira = absValor.toStringAsFixed(0).padLeft(1, '0');
    final decimal = (absValor % 1 * 100).toStringAsFixed(0).padLeft(2, '0');

    final formatter = StringBuffer(AppConstants.currencySymbol);
    formatter.write(' ');

    // Adiciona separador de milhares
    String inteiraParte = inteira;
    for (int i = inteiraParte.length - 3; i > 0; i -= 3) {
      inteiraParte =
          inteiraParte.substring(0, i) + '.' + inteiraParte.substring(i);
    }

    formatter.write(inteiraParte);
    formatter.write(',');
    formatter.write(decimal);

    // Adiciona sinal negativo se necessário
    if (valor < 0) {
      return '-${formatter.toString()}';
    }

    return formatter.toString();
  }

  /// Retorna o estilo padrão baseado no contexto
  TextStyle _getDefaultStyle(BuildContext context, bool destacar) {
    final baseStyle =
        Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

    if (destacar) {
      return baseStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 16);
    }

    return baseStyle;
  }
}

/// Widget para exibir transações com cor baseada no tipo
class TransacaoItemWidget extends StatelessWidget {
  final String descricao;
  final double valor;
  final bool isEntrada;
  final String? categoriaNome;
  final Function()? onTap;

  const TransacaoItemWidget({
    required this.descricao,
    required this.valor,
    required this.isEntrada,
    this.categoriaNome,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cor = isEntrada ? Colors.green : Colors.red;

    return ListTile(
      leading: Icon(
        isEntrada ? Icons.arrow_downward : Icons.arrow_upward,
        color: cor,
      ),
      title: Text(descricao),
      subtitle: categoriaNome != null ? Text(categoriaNome!) : null,
      trailing: MoedaWidget(
        valor: isEntrada ? valor : -valor,
        style: TextStyle(fontWeight: FontWeight.bold, color: cor),
      ),
      onTap: onTap,
    );
  }
}

/// Widget para exibir saldo da conta
class SaldoWidget extends StatelessWidget {
  final double valor;
  final String titulo;

  const SaldoWidget({required this.valor, this.titulo = 'Saldo', Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            MoedaWidget(
              valor: valor,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: valor >= 0 ? Colors.green : Colors.red,
              ),
              destacar: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para exibir erro
class ErroWidget extends StatelessWidget {
  final String mensagem;
  final Function()? onRetry;

  const ErroWidget({required this.mensagem, this.onRetry, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            mensagem,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (onRetry != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton(
                onPressed: onRetry,
                child: const Text('Tentar Novamente'),
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget para carregamento
class LoadingWidget extends StatelessWidget {
  final String? mensagem;

  const LoadingWidget({this.mensagem, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (mensagem != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                mensagem!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}
