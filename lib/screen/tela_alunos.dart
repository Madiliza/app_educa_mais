import 'package:Projeto_Educa_Mais/models/aluno.dart';
import 'package:Projeto_Educa_Mais/providers/app_state.dart';
import 'package:Projeto_Educa_Mais/utils/app_colors.dart';
import 'package:Projeto_Educa_Mais/widgets/alunos/formulario_aluno.dart';
import 'package:Projeto_Educa_Mais/widgets/alunos/lista_alunos.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TelaAlunos extends StatelessWidget {
  const TelaAlunos({super.key});

  void _abrirFormularioAluno(BuildContext context, {Aluno? aluno}) {
    final appState = Provider.of<AppState>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: EdgeInsets.zero,
        backgroundColor: AppColor.fundoCard,
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
            child: FormularioAluno(
              alunoParaEditar: aluno,
              aoSalvar: (alunoSalvo) => appState.salvarAluno(alunoSalvo),
            ),
          ),
        ),
      ),
    );
  }

  void _deletarAluno(BuildContext context, String idAluno) {
    final appState = Provider.of<AppState>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Confirmar Exclusão'),
        content: const Text(
          'Tem certeza de que deseja excluir este aluno e todos os seus dados? Esta ação não pode ser desfeita.',
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              appState.deletarAluno(idAluno);
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.erro,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Excluir'),
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
                    const Text(
                      'Gerenciamento de Alunos',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textoPrincipal,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ListaAlunos(
                      alunos: appState.alunos,
                      pagamentos: appState.pagamentos,
                      aoAdicionarAluno: () => _abrirFormularioAluno(context),
                      aoEditarAluno: (aluno) => _abrirFormularioAluno(context, aluno: aluno),
                      aoDeletarAluno: (idAluno) => _deletarAluno(context, idAluno),
                      aoMarcarComoPago: appState.marcarComoPago, // Passando a função correta
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