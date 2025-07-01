import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:Projeto_Educa_Mais/models/aluno.dart';
import 'package:Projeto_Educa_Mais/models/pagamento.dart';
import 'package:Projeto_Educa_Mais/models/status_pagamento.dart';
import 'package:Projeto_Educa_Mais/utils/app_colors.dart';
import 'package:Projeto_Educa_Mais/utils/formatadores.dart';

// Classe auxiliar para representar a combinação de Mês e Ano de forma segura.
class MesAno {
  final int ano;
  final int mes;

  MesAno(this.ano, this.mes);

  // Sobrescreve '==' e 'hashCode' para permitir comparações corretas em listas e conjuntos.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MesAno &&
          runtimeType == other.runtimeType &&
          ano == other.ano &&
          mes == other.mes;

  @override
  int get hashCode => ano.hashCode ^ mes.hashCode;
}


class HistoricoPagamentos extends StatefulWidget {
  final List<Aluno> alunos;
  final List<Pagamento> pagamentos;
  final Future<void> Function(Pagamento pagamento) onConfirmarPagamento;

  const HistoricoPagamentos({
    super.key,
    required this.alunos,
    required this.pagamentos,
    required this.onConfirmarPagamento,
  });

  @override
  State<HistoricoPagamentos> createState() => _HistoricoPagamentosState();
}

class _HistoricoPagamentosState extends State<HistoricoPagamentos> {
  final TextEditingController _nomeController = TextEditingController();
  
  MesAno? _mesAnoSelecionado;
  final List<MesAno> _opcoesMesAno = [];

  List<Pagamento> _pagamentosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _gerarOpcoesMesAno();
    final agora = DateTime.now();
    final mesAtual = MesAno(agora.year, agora.month);
    if (_opcoesMesAno.contains(mesAtual)) {
      _mesAnoSelecionado = mesAtual;
    }
    _atualizarPagamentos();
    _nomeController.addListener(_filtrarPagamentos);
  }

  @override
  void didUpdateWidget(covariant HistoricoPagamentos oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pagamentos != oldWidget.pagamentos) {
      _atualizarPagamentos();
    }
  }

  void _atualizarPagamentos() {
    _pagamentosFiltrados = List<Pagamento>.from(widget.pagamentos);
    _gerarOpcoesMesAno(); 
    _filtrarPagamentos();
  }

  @override
  void dispose() {
    _nomeController.removeListener(_filtrarPagamentos);
    _nomeController.dispose();
    super.dispose();
  }

  void _gerarOpcoesMesAno() {
    _opcoesMesAno.clear();
    final Set<String> chavesUnicas = {};
    for (var pagamento in widget.pagamentos) {
      final chave = "${pagamento.dataVencimento.year}-${pagamento.dataVencimento.month}";
      if (!chavesUnicas.contains(chave)) {
        _opcoesMesAno.add(MesAno(pagamento.dataVencimento.year, pagamento.dataVencimento.month));
        chavesUnicas.add(chave);
      }
    }
    _opcoesMesAno.sort((a, b) => DateTime(b.ano, b.mes).compareTo(DateTime(a.ano, a.mes)));
  }

  void _filtrarPagamentos() {
    List<Pagamento> pagamentosTemp = List.from(widget.pagamentos);

    final nomeQuery = _nomeController.text.toLowerCase();
    if (nomeQuery.isNotEmpty) {
      pagamentosTemp = pagamentosTemp.where((pagamento) {
        final nomeAluno = _getNomeAluno(pagamento.alunoId).toLowerCase();
        return nomeAluno.contains(nomeQuery);
      }).toList();
    }

    if (_mesAnoSelecionado != null) {
      pagamentosTemp = pagamentosTemp.where((pagamento) {
        return pagamento.dataVencimento.month == _mesAnoSelecionado!.mes &&
            pagamento.dataVencimento.year == _mesAnoSelecionado!.ano;
      }).toList();
    }

    pagamentosTemp.sort((a, b) => b.dataVencimento.compareTo(a.dataVencimento));

    setState(() {
      _pagamentosFiltrados = pagamentosTemp;
    });
  }

  void _limparFiltros() {
    setState(() {
      _nomeController.clear();
      _mesAnoSelecionado = null;
    });
    _filtrarPagamentos();
  }

  String _getNomeAluno(String idAluno) {
    try {
      return widget.alunos.firstWhere((aluno) => aluno.id == idAluno).nome;
    } catch (e) {
      return "Aluno Desconhecido";
    }
  }

  Map<String, dynamic> _getStatusInfo(StatusPagamento status) {
    switch (status) {
      case StatusPagamento.pago:
        return {'texto': 'PAGO', 'cor': AppColor.sucesso, 'corClara': AppColor.sucessoClaro, 'icone': Icons.check_circle_outline};
      case StatusPagamento.pendente:
        return {'texto': 'PENDENTE', 'cor': AppColor.aviso, 'corClara': AppColor.avisoClaro, 'icone': Icons.hourglass_bottom_outlined};
      case StatusPagamento.atrasado:
        return {'texto': 'ATRASADO', 'cor': AppColor.erro, 'corClara': AppColor.erroClaro, 'icone': Icons.error_outline};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.fundoCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColor.borda.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              "Histórico de Transações", // Texto alterado para refletir melhor o conteúdo
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColor.textoPrincipal),
            ),
          ),
          _buildControlesFiltro(),
          const Divider(height: 1, color: AppColor.borda),
          if (_pagamentosFiltrados.isEmpty)
            _buildEstadoVazio()
          else
            ListView.separated(
              itemCount: _pagamentosFiltrados.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 20, endIndent: 20, color: AppColor.borda),
              itemBuilder: (context, index) {
                final pagamento = _pagamentosFiltrados[index];
                return _buildItemPagamento(pagamento);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildControlesFiltro() {
    // ... (este método permanece inalterado)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    labelText: 'Filtrar por nome',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<MesAno>(
                  value: _mesAnoSelecionado,
                  hint: const Text('Filtrar por mês'),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _opcoesMesAno.map((opcao) {
                    final data = DateTime(opcao.ano, opcao.mes);
                    final nomeMes = DateFormat.yMMMM('pt_BR').format(data);
                    return DropdownMenuItem<MesAno>(
                      value: opcao,
                      child: Text(nomeMes),
                    );
                  }).toList(),
                  onChanged: (valor) {
                    setState(() {
                      _mesAnoSelecionado = valor;
                    });
                    _filtrarPagamentos();
                  },
                ),
              ),
            ],
          ),
          if (_nomeController.text.isNotEmpty || _mesAnoSelecionado != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _limparFiltros,
                child: const Text('Limpar Filtros', style: TextStyle(color: AppColor.primaria)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEstadoVazio() {
    // ... (este método permanece inalterado)
     return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.receipt_long_outlined, size: 48, color: AppColor.textoSecundario),
          SizedBox(height: 16),
          Text(
            "Nenhum pagamento encontrado",
            style: TextStyle(fontSize: 18, color: AppColor.textoSecundario, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            "Ajuste os filtros ou verifique os registros.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColor.textoSecundario),
          ),
        ],
      ),
    );
  }

  // =======================================================================
  // MÉTODO COM AS ALTERAÇÕES
  // =======================================================================
  Widget _buildItemPagamento(Pagamento pagamento) {
    final statusInfo = _getStatusInfo(pagamento.status);

    void _mostrarDialogoConfirmacao(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Marcar como Pago?'), // <-- MUDANÇA AQUI
            content: Text( // <-- MUDANÇA AQUI
                'Deseja marcar o pagamento de ${_getNomeAluno(pagamento.alunoId)} no valor de ${Formatadores.formatarMoeda(pagamento.valor)} como PAGO?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.sucesso,
                ),
                child: const Text('Sim, Marcar Pago'), // <-- MUDANÇA AQUI
                onPressed: () {
                  widget.onConfirmarPagamento(pagamento);
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(statusInfo['icone'], color: statusInfo['cor'], size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getNomeAluno(pagamento.alunoId),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColor.textoPrincipal),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Vencimento: ${Formatadores.formatarData(pagamento.dataVencimento)}",
                        style: const TextStyle(color: AppColor.textoSecundario, fontSize: 13),
                      ),
                      if (pagamento.dataPagamento != null)
                        Text(
                          "Pago em: ${Formatadores.formatarData(pagamento.dataPagamento!)}",
                          style: TextStyle(color: AppColor.sucesso.withOpacity(0.8), fontSize: 13),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatadores.formatarMoeda(pagamento.valor),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColor.textoPrincipal),
              ),
              if (pagamento.multaAtraso > 0) ...[
                const SizedBox(height: 2),
                Text(
                  "+ ${Formatadores.formatarMoeda(pagamento.multaAtraso)} (multa)",
                  style: const TextStyle(color: AppColor.erro, fontSize: 12),
                ),
              ],
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusInfo['corClara'],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  statusInfo['texto']!,
                  style: TextStyle(color: statusInfo['cor'], fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              if (pagamento.status != StatusPagamento.pago) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 32,
                  child: TextButton.icon(
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Marcar como Pago'), // <-- MUDANÇA AQUI
                    onPressed: () => _mostrarDialogoConfirmacao(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColor.sucesso,
                      backgroundColor: AppColor.sucessoClaro,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}