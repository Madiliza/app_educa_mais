import 'package:Projeto_Educa_Mais/providers/app_state.dart';
import 'package:Projeto_Educa_Mais/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Projeto_Educa_Mais/widgets/dashboard/dashboard_screen.dart' as screen;

class TelaDashboard extends StatelessWidget {
  const TelaDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.fundo,
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: SingleChildScrollView(
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