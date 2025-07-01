import 'dart:math';
import 'package:Projeto_Educa_Mais/models/aluno.dart';
import 'package:Projeto_Educa_Mais/models/despesa.dart';
import 'package:Projeto_Educa_Mais/models/pagamento.dart';
import 'package:Projeto_Educa_Mais/models/status_pagamento.dart';
import 'package:Projeto_Educa_Mais/utils/formatadores.dart';
import 'package:Projeto_Educa_Mais/utils/app_colors.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  final List<Aluno> alunos;
  final List<Pagamento> pagamentos;
  final List<Despesa> despesas;

  const DashboardScreen({
    super.key,
    required this.alunos,
    required this.pagamentos,
    required this.despesas,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- VARIÁVEIS DE ESTADO PARA ARMAZENAR OS DADOS CALCULADOS ---
  late double receitaLiquidaMes;
  late double receitaBrutaMes;
  late double totalDespesasMes;
  late List<Map<String, dynamic>> secondaryCardData;

  @override
  void initState() {
    super.initState();
    // A lógica de cálculo permanece a mesma, executada uma vez.
    _calcularDadosDashboard();
    // Exemplo de mensagem ao carregar o dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mostrarMensagem('Dashboard carregado com sucesso!');
    });
  }
  
  // didUpdateWidget é importante se os dados do AppState puderem mudar dinamicamente
  // e você quiser que o dashboard reflita essas mudanças.
  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recalcula se os dados de entrada mudarem.
    if (widget.alunos != oldWidget.alunos || 
        widget.pagamentos != oldWidget.pagamentos || 
        widget.despesas != oldWidget.despesas) {
      _calcularDadosDashboard();
    }
  }

  // --- MÉTODO DE INTERAÇÃO: MOSTRAR MENSAGEM ---
  void mostrarMensagem(String mensagem, {Color? cor}) {
    final snackBar = SnackBar(
      content: Text(mensagem),
      backgroundColor: cor ?? Colors.blueAccent,
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _calcularDadosDashboard() {
    final agora = DateTime.now();

    receitaBrutaMes = widget.pagamentos
        .where((p) =>
            p.status == StatusPagamento.pago &&
            p.dataPagamento != null &&
            p.dataPagamento!.month == agora.month &&
            p.dataPagamento!.year == agora.year)
        .fold<double>(0, (soma, p) => soma + p.valor + p.multaAtraso);

    totalDespesasMes = widget.despesas
        .where((d) => d.data.month == agora.month && d.data.year == agora.year)
        .fold<double>(0, (soma, d) => soma + d.valor);

    receitaLiquidaMes = receitaBrutaMes - totalDespesasMes;

    final pagamentosComVencimentoNoMes = widget.pagamentos
        .where((p) =>
            p.dataVencimento.month == agora.month &&
            p.dataVencimento.year == agora.year)
        .toList();

    final pagamentosPendentes = pagamentosComVencimentoNoMes
        .where((p) => p.status == StatusPagamento.pendente)
        .fold<double>(0, (soma, p) => soma + p.valor);

    final pagamentosAtrasados = pagamentosComVencimentoNoMes
        .where((p) => p.status == StatusPagamento.atrasado)
        .toList();

    final receitaAtrasada = pagamentosAtrasados.fold<double>(
        0, (soma, p) => soma + p.valor + p.multaAtraso);

    secondaryCardData = [
      {
        'titulo': "Total de Alunos",
        'valor': widget.alunos.length.toString(),
        'icone': Icons.people_outline,
        'cor': AppColor.primaria,
      },
      {
        'titulo': "Pagamentos Pendentes",
        'valor': Formatadores.formatarMoeda(pagamentosPendentes),
        'icone': Icons.hourglass_empty_outlined,
        'cor': AppColor.aviso,
      },
      {
        'titulo': "Pagamentos Atrasados",
        'valor': Formatadores.formatarMoeda(receitaAtrasada),
        'icone': Icons.error_outline,
        'cor': AppColor.erro,
        'subtitulo': "${pagamentosAtrasados.length} mensalidade(s)",
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    // CORREÇÃO: Removido o Scaffold, a SingleChildScrollView e o Padding.
    // O widget agora retorna diretamente a Column com o conteúdo, que se encaixará
    // perfeitamente no layout da TelaDashboard.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- CARD PRINCIPAL (KPI) ---
        _MainKpiCard(
          receitaLiquida: receitaLiquidaMes,
          receitaBruta: receitaBrutaMes,
          despesas: totalDespesasMes,
        ),
        const SizedBox(height: 24),

        // --- TÍTULO DA SEÇÃO SECUNDÁRIA ---
        const Text(
          "Detalhes do Mês",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColor.textoPrincipal,
          ),
        ),
        const SizedBox(height: 16),

        // --- GRID DE CARDS SECUNDÁRIOS ---
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount;
            if (constraints.maxWidth > 1200) {
              crossAxisCount = 3;
            } else if (constraints.maxWidth > 700) {
              crossAxisCount = 2;
            } else {
              crossAxisCount = 1;
            }
            
            double childAspectRatio = crossAxisCount == 1 ? 3.0 : 2.2;
            if(constraints.maxWidth > 700 && constraints.maxWidth < 800) {
               childAspectRatio = 1.8;
            }

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: secondaryCardData.length,
              shrinkWrap: true, // Necessário dentro de uma Column/SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(), // A rolagem é controlada pelo pai
              itemBuilder: (context, index) {
                final data = secondaryCardData[index];
                return _InfoCard(
                  titulo: data['titulo'],
                  valor: data['valor'],
                  icone: data['icone'],
                  cor: data['cor'],
                  subtitulo: data['subtitulo'],
                );
              },
            );
          },
        ),
      ],
    );
  }
}

// --- WIDGETS AUXILIARES (copiados como solicitado) ---

class _MainKpiCard extends StatelessWidget {
  final double receitaLiquida;
  final double receitaBruta;
  final double despesas;

  const _MainKpiCard({
    required this.receitaLiquida,
    required this.receitaBruta,
    required this.despesas,
  });

  @override
  Widget build(BuildContext context) {
    final corPrincipal = receitaLiquida >= 0 ? AppColor.sucesso : AppColor.erro;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [corPrincipal.withOpacity(0.8), corPrincipal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: corPrincipal.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Receita Líquida do Mês",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColor.textoContraste,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Formatadores.formatarMoeda(receitaLiquida),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: AppColor.textoContraste,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white54),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildReceitaDespesaItem(
                titulo: "Receita Bruta",
                valor: receitaBruta,
                icone: Icons.arrow_upward,
                cor: AppColor.textoContraste,
              ),
              _buildReceitaDespesaItem(
                titulo: "Despesas",
                valor: despesas,
                icone: Icons.arrow_downward,
                cor: AppColor.textoContraste,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildReceitaDespesaItem({
    required String titulo,
    required double valor,
    required IconData icone,
    required Color cor,
  }) {
    return Row(
      children: [
        Icon(icone, color: cor, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: TextStyle(fontSize: 14, color: cor.withOpacity(0.9)),
            ),
            Text(
              Formatadores.formatarMoeda(valor),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cor,
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final String? subtitulo;
  final IconData icone;
  final Color cor;

  const _InfoCard({
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.cor,
    this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.fundoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borda, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColor.borda.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cor.withOpacity(0.1),
            ),
            child: Icon(icone, color: cor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColor.textoSecundario,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textoPrincipal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitulo != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitulo!,
                    style: TextStyle(
                      fontSize: 12,
                      color: cor,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}