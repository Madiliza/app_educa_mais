import 'package:Projeto_Educa_Mais/models/aluno.dart';
import 'package:Projeto_Educa_Mais/models/pagamento.dart';
import 'package:Projeto_Educa_Mais/models/status_pagamento.dart';
import 'package:Projeto_Educa_Mais/utils/app_colors.dart';
import 'package:Projeto_Educa_Mais/utils/formatadores.dart';
import 'package:flutter/material.dart';

class ListaAlunos extends StatefulWidget {
  final List<Aluno> alunos;
  final List<Pagamento> pagamentos;
  final Function() aoAdicionarAluno;
  final Function(Aluno aluno) aoEditarAluno;
  final Function(String idAluno) aoDeletarAluno;
  final Function(String idPagamento) aoMarcarComoPago;

  const ListaAlunos({
    super.key,
    required this.alunos,
    required this.pagamentos,
    required this.aoAdicionarAluno,
    required this.aoEditarAluno,
    required this.aoDeletarAluno,
    required this.aoMarcarComoPago,
  });

  @override
  _ListaAlunosState createState() => _ListaAlunosState();
}

class _ListaAlunosState extends State<ListaAlunos> {
  String? _alunoExpandidoId;

  List<Pagamento> _getPagamentosDoAluno(String idAluno) {
    return widget.pagamentos.where((p) => p.alunoId == idAluno).toList()
      ..sort((a, b) => b.dataVencimento.compareTo(a.dataVencimento));
  }

  Map<String, dynamic> _getStatusInfo(StatusPagamento status) {
    switch (status) {
      case StatusPagamento.pago:
        return {'texto': 'Pago', 'cor': AppColor.sucesso, 'corClara': AppColor.sucessoClaro};
      case StatusPagamento.pendente:
        return {'texto': 'Pendente', 'cor': AppColor.aviso, 'corClara': AppColor.avisoClaro};
      case StatusPagamento.atrasado:
        return {'texto': 'Atrasado', 'cor': AppColor.erro, 'corClara': AppColor.erroClaro};
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
        children: [
          _buildCabecalho(),
          const Divider(height: 1, color: AppColor.borda),
          if (widget.alunos.isEmpty)
            _buildEstadoVazio()
          else
            ListView.separated(
              itemCount: widget.alunos.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const Divider(
                height: 1, color: AppColor.borda, indent: 20, endIndent: 20,
              ),
              itemBuilder: (context, index) {
                final aluno = widget.alunos[index];
                final pagamentosDoAluno = _getPagamentosDoAluno(aluno.id);
                final isExpanded = _alunoExpandidoId == aluno.id;
                return _buildCardAluno(aluno, pagamentosDoAluno, isExpanded);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCabecalho() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Alunos Cadastrados",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColor.textoPrincipal),
          ),
          ElevatedButton.icon(
            onPressed: widget.aoAdicionarAluno,
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Novo Aluno"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaria,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoVazio() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.person_search, size: 48, color: AppColor.textoSecundario),
          SizedBox(height: 16),
          Text(
            "Nenhum aluno encontrado",
            style: TextStyle(fontSize: 18, color: AppColor.textoSecundario, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            "Clique em 'Novo Aluno' para começar a cadastrar.",
            style: TextStyle(color: AppColor.textoSecundario),
          ),
        ],
      ),
    );
  }

  Widget _buildCardAluno(Aluno aluno, List<Pagamento> pagamentosDoAluno, bool isExpanded) {
    final ultimoPagamento = pagamentosDoAluno.isNotEmpty ? pagamentosDoAluno.first : null;

    return InkWell(
      onTap: () => setState(() => _alunoExpandidoId = isExpanded ? null : aluno.id),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColor.primariaClaro,
                      child: Text(
                        aluno.nome.isNotEmpty ? aluno.nome[0].toUpperCase() : 'A',
                        style: const TextStyle(color: AppColor.primaria, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(aluno.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            "Responsável: ${aluno.nomeResponsavel}",
                            style: const TextStyle(color: AppColor.textoSecundario, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    if (ultimoPagamento != null) _buildStatusChip(ultimoPagamento.status),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoLinha(Icons.phone_outlined, aluno.telefoneResponsavel),
                    Text(
                      Formatadores.formatarMoeda(aluno.mensalidade),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.sucesso),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildBotoesAluno(aluno, ultimoPagamento, isExpanded),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isExpanded ? _buildHistoricoExpandido(pagamentosDoAluno) : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoLinha(IconData icone, String texto) {
    return Row(
      children: [
        Icon(icone, size: 16, color: AppColor.textoSecundario),
        const SizedBox(width: 8),
        Text(texto, style: const TextStyle(color: AppColor.textoSecundario, fontSize: 13)),
      ],
    );
  }

  Widget _buildStatusChip(StatusPagamento status) {
    final statusInfo = _getStatusInfo(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusInfo['corClara'],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        statusInfo['texto']!,
        style: TextStyle(color: statusInfo['cor'], fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildBotoesAluno(Aluno aluno, Pagamento? ultimoPagamento, bool isExpanded) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (ultimoPagamento != null && ultimoPagamento.status != StatusPagamento.pago)
          TextButton.icon(
            onPressed: () {
              // Adicionado um diálogo de confirmação também para o botão principal
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirmar Pagamento'),
                  content: Text('Deseja marcar o pagamento mais recente de ${aluno.nome} como pago?'),
                  actions: [
                    TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(ctx).pop()),
                    ElevatedButton(
                      child: const Text('Confirmar'),
                      onPressed: () {
                        widget.aoMarcarComoPago(ultimoPagamento.id);
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.check, size: 16),
            label: const Text("Pagar Última"),
            style: TextButton.styleFrom(foregroundColor: AppColor.sucesso),
          ),
        const Spacer(),
        IconButton(
          onPressed: () => widget.aoEditarAluno(aluno),
          icon: const Icon(Icons.edit_outlined, size: 20, color: AppColor.textoSecundario),
          tooltip: 'Editar Aluno',
        ),
        IconButton(
          onPressed: () {
             // Diálogo de confirmação para exclusão
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Confirmar Exclusão'),
                content: Text('Tem certeza que deseja excluir o aluno ${aluno.nome}? Esta ação não pode ser desfeita.'),
                actions: [
                  TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(ctx).pop()),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColor.erro),
                    child: const Text('Excluir'),
                    onPressed: () {
                      widget.aoDeletarAluno(aluno.id);
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.delete_outline, size: 20, color: AppColor.erro),
          tooltip: 'Excluir Aluno',
        ),
        Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: AppColor.textoSecundario),
      ],
    );
  }

  Widget _buildHistoricoExpandido(List<Pagamento> pagamentosDoAluno) {
    return Container(
      color: AppColor.fundo.withOpacity(0.5), // Leve alteração na cor para diferenciar
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Histórico de Pagamentos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColor.textoPrincipal)),
          const SizedBox(height: 12),
          if (pagamentosDoAluno.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Nenhum histórico de pagamento para este aluno.", style: TextStyle(color: AppColor.textoSecundario)),
              ),
            ),
          ...pagamentosDoAluno.map((pag) => _buildItemHistorico(pag)),
        ],
      ),
    );
  }

  // =======================================================================
  // MÉTODO COM AS ALTERAÇÕES
  // =======================================================================
  Widget _buildItemHistorico(Pagamento pagamento) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Parte Esquerda: Status e Datas
          Row(
            children: [
              _buildStatusChip(pagamento.status),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Venc: ${Formatadores.formatarData(pagamento.dataVencimento)}",
                    style: const TextStyle(fontSize: 13, color: AppColor.textoSecundario),
                  ),
                  if (pagamento.dataPagamento != null)
                    Text(
                      "Pago em: ${Formatadores.formatarData(pagamento.dataPagamento!)}",
                      style: TextStyle(color: AppColor.sucesso.withOpacity(0.9), fontSize: 12),
                    ),
                ],
              ),
            ],
          ),
          // Parte Direita: Valor e Botão de Ação
          Row(
            children: [
              Text(
                Formatadores.formatarMoeda(pagamento.valor),
                style: const TextStyle(fontWeight: FontWeight.w500, color: AppColor.textoPrincipal),
              ),
              // O botão só aparece se o pagamento NÃO estiver pago
              if (pagamento.status != StatusPagamento.pago)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: IconButton(
                    onPressed: () => widget.aoMarcarComoPago(pagamento.id),
                    icon: const Icon(Icons.check_circle_outline),
                    color: AppColor.sucesso,
                    iconSize: 22,
                    tooltip: 'Marcar como Pago',
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}