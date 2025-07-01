import 'package:Projeto_Educa_Mais/providers/app_state.dart';
import 'package:Projeto_Educa_Mais/utils/app_colors.dart';
import 'package:Projeto_Educa_Mais/widgets/historicoPagamento/historico_Pagamento.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


/// A tela que exibe o histórico completo de pagamentos.
///
/// Utiliza um layout centralizado e responsivo para apresentar o widget
/// [HistoricoPagamentos] de forma clara e organizada.
class TelaPagamentos extends StatelessWidget {
  const TelaPagamentos({super.key});

  @override
  Widget build(BuildContext context) {
    // Consome o estado da aplicação para obter os dados necessários.
    final appState = Provider.of<AppState>(context);
    
    return Scaffold(
      backgroundColor: AppColor.fundo,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          // Limita a largura do conteúdo para melhor legibilidade em telas grandes.
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título da página.
                const Text(
                  'Histórico de Pagamentos',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textoPrincipal,
                  ),
                ),
                const SizedBox(height: 24),
                // Widget que exibe a lista de pagamentos.
                HistoricoPagamentos(
                  alunos: appState.alunos,
                  pagamentos: appState.pagamentos,
                  
                  onConfirmarPagamento: (pagamento) async {   
                    final messenger = ScaffoldMessenger.of(context);
                    
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Confirmando pagamento...'))
                    );

                    final resultado = await appState.marcarComoPago(pagamento.id);

                    messenger.hideCurrentSnackBar();
                    messenger.showSnackBar(SnackBar(
                      content: Text(resultado),
                      backgroundColor: resultado.contains('sucesso') ? Colors.green : Colors.red,
                    ));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}