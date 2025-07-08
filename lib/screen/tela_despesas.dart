import 'package:Projeto_Educa_Mais/models/despesa.dart';
import 'package:Projeto_Educa_Mais/providers/app_state.dart';
import 'package:Projeto_Educa_Mais/utils/app_colors.dart';
import 'package:Projeto_Educa_Mais/widgets/despesas/formulario_despesa.dart';
import 'package:Projeto_Educa_Mais/widgets/despesas/lista_despesas.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TelaDespesas extends StatelessWidget {
  const TelaDespesas({super.key});

  void _abrirFormularioDespesa(BuildContext context, {Despesa? despesa}) {
    final appState = Provider.of<AppState>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: EdgeInsets.zero,
        backgroundColor: AppColor.fundoCard,
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: FormularioDespesa(
            despesaParaEditar: despesa,
            aoSalvar: (despesaSalva) => appState.salvarDespesa(despesaSalva),
          ),
        ),
      ),
    );
  }

  void _deletarDespesa(BuildContext context, String idDespesa) {
    final appState = Provider.of<AppState>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir esta despesa?'),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              appState.deletarDespesa(idDespesa);
              Navigator.of(ctx).pop();
            },
            child: const Text('Excluir', style: TextStyle(color: AppColor.erro)),
          ),
        ],
      ),
    );
  }

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Controle de Despesas',
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _abrirFormularioDespesa(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Nova Despesa'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primaria,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ListaDespesas(
                      despesas: appState.despesas,
                      aoEditarDespesa: (despesa) =>
                          _abrirFormularioDespesa(context, despesa: despesa),
                      aoDeletarDespesa: (id) => _deletarDespesa(context, id),
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