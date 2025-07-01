import 'package:Projeto_Educa_Mais/models/aluno.dart';
import 'package:Projeto_Educa_Mais/providers/app_state.dart';
import 'package:Projeto_Educa_Mais/utils/app_colors.dart';
import 'package:Projeto_Educa_Mais/widgets/alunos/formulario_aluno.dart';
import 'package:Projeto_Educa_Mais/widgets/alunos/lista_alunos.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TelaAlunos extends StatelessWidget {
  const TelaAlunos({super.key});

  // <<-- NOVO: Função auxiliar para exibir o SnackBar de sucesso.
  void _mostrarMensagemSucesso(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: AppColor.sucesso, // Cor verde para sucesso
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // <<-- ALTERAÇÃO: A função agora é assíncrona para aguardar o resultado do formulário.
  Future<void> _abrirFormularioAluno(BuildContext context, {Aluno? aluno}) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final bool isEditing = aluno != null;

    // <<-- ALTERAÇÃO: Aguarda o resultado do showDialog. Ele retornará 'true' se o formulário for salvo.
    final bool? sucesso = await showDialog<bool>(
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
              aoSalvar: (alunoSalvo) async {
                await appState.salvarAluno(alunoSalvo);
              },
            ),
          ),
        ),
      ),
    );

    // <<-- NOVO: Se o resultado for 'true', exibe a mensagem de sucesso.
    if (sucesso == true) {
      final mensagem = isEditing
          ? 'Aluno atualizado com sucesso!'
          : 'Aluno adicionado com sucesso!';
      _mostrarMensagemSucesso(context, mensagem);
    }
  }

  // <<-- ALTERAÇÃO: Adicionada a chamada para a mensagem de sucesso.
  void _deletarAluno(BuildContext context, String idAluno) {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.deletarAluno(idAluno);

    // <<-- NOVO: Exibe a mensagem de sucesso após chamar a função de deletar.
    _mostrarMensagemSucesso(context, 'Aluno excluído com sucesso!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.fundo,
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

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
                      aoMarcarComoPago: appState.marcarComoPago,
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