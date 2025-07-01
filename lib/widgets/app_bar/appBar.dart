
import 'package:Projeto_Educa_Mais/screen/tela_alunos.dart';
import 'package:Projeto_Educa_Mais/screen/tela_dashboard.dart';
import 'package:Projeto_Educa_Mais/screen/tela_despesas.dart';
import 'package:Projeto_Educa_Mais/screen/tela_pagamentos.dart';
import 'package:Projeto_Educa_Mais/utils/app_colors.dart';
import 'package:flutter/material.dart';


class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _PaginaNavegacao {
  final String rota;
  final Widget widget;
  final String label;
  final IconData icon;

  const _PaginaNavegacao({
    required this.rota,
    required this.widget,
    required this.label,
    required this.icon,
  });
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _paginaAtual = 0;

  // Define as rotas e widgets de cada página.
  final List<_PaginaNavegacao> _paginas = [
    _PaginaNavegacao(
      rota: '/dashboard',
      widget: TelaDashboard(), // Substitua por sua página real
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
    ),
    _PaginaNavegacao(
      rota: '/alunos',
      widget: TelaAlunos(), // Substitua por sua página real
      label: 'Alunos',
      icon: Icons.people_outline,
    ),
    _PaginaNavegacao(
      rota: '/pagamentos',
      widget: TelaPagamentos(), // Substitua por sua página real
      label: 'Pagamentos',
      icon: Icons.receipt_long_outlined,
    ),
    _PaginaNavegacao(
      rota: '/despesas',
      widget: TelaDespesas(), // Substitua por sua página real
      label: 'Despesas',
      icon: Icons.wallet_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.school, color: AppColor.primaria,),
            SizedBox(width: 8),
            Text(
              'Espaço Educa+',
              style: TextStyle(
                color: AppColor.textoPrincipal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: AppColor.fundoCard,
        elevation: 0,
      ),
      body: _paginas[_paginaAtual].widget,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaAtual,
        onTap: (index) {
          setState(() {
            _paginaAtual = index;
            // Navega para a rota se preferir usar rotas nomeadas
            // Navigator.pushReplacementNamed(context, _paginas[index].rota);
          });
        },
        backgroundColor: AppColor.fundoCard,
        selectedItemColor: AppColor.primaria,
        unselectedItemColor: AppColor.textoSecundario,
        type: BottomNavigationBarType.fixed,
        items: _paginas.map((pagina) {
          return BottomNavigationBarItem(
            icon: Icon(pagina.icon),
            label: pagina.label,
          );
        }).toList(),
      ),
    );
  }
}
