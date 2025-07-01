import 'package:Projeto_Educa_Mais/providers/app_state.dart';
import 'package:Projeto_Educa_Mais/screen/tela_alunos.dart' show TelaAlunos;
import 'package:Projeto_Educa_Mais/screen/tela_dashboard.dart';
import 'package:Projeto_Educa_Mais/screen/tela_despesas.dart';
import 'package:Projeto_Educa_Mais/screen/tela_pagamentos.dart';
import 'package:Projeto_Educa_Mais/utils/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  _TelaPrincipalState createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _telas = [
    const TelaDashboard(),
    const TelaAlunos(),
    const TelaPagamentos(),
    const TelaDespesas(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColor.primaria),
            );
          }
          // Layout com menu de navegação lateral
          return Row(
            children: [
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onItemTapped,
                labelType: NavigationRailLabelType.all,
                backgroundColor: AppColor.fundoCard,
                elevation: 2,
                leading: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Icon(Icons.school, color: AppColor.primaria, size: 30),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: Text('Alunos'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.history_outlined),
                    selectedIcon: Icon(Icons.history),
                    label: Text('Pagamentos'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.request_quote_outlined),
                    selectedIcon: Icon(Icons.request_quote),
                    label: Text('Despesas'),
                  ),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() { _selectedIndex = index; });
                  },
                  children: _telas,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}