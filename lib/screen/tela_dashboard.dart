import 'package:Projeto_Educa_Mais/providers/app_state.dart';
import 'package:Projeto_Educa_Mais/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Projeto_Educa_Mais/widgets/dashboard/dashboard_screen.dart' as screen;

/// A tela principal da aplicação, que exibe o dashboard com métricas chave.
class TelaDashboard extends StatelessWidget {
  const TelaDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Define a cor de fundo padrão para a tela.
      backgroundColor: AppColor.fundo,
      // Corpo da tela, consumindo o estado da aplicação.
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          // Centraliza o conteúdo principal para melhor visualização em telas largas.
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              // Limita a largura máxima do conteúdo.
              constraints: const BoxConstraints(maxWidth: 1200),
              // Esta é a ÚNICA SingleChildScrollView necessária.
              child: SingleChildScrollView(
                // Adiciona um espaçamento interno consistente.
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título da página.
                    const Text(
                      'Visão Geral',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textoPrincipal,
                      ),
                    ),
                    const SizedBox(height: 24),
                    screen.DashboardScreen(
                      alunos: appState.alunos,
                      pagamentos: appState.pagamentos,
                      
                      despesas: appState.despesas,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}