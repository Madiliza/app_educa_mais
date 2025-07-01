import 'package:Projeto_Educa_Mais/models/aluno.dart';
import 'package:Projeto_Educa_Mais/utils/app_colors.dart';
import 'package:Projeto_Educa_Mais/utils/formatadores.dart'; // Certifique-se de que este arquivo existe e contém MascaraTelefoneInputFormatter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormularioAluno extends StatefulWidget {
  final Aluno? alunoParaEditar;
  final Function(Aluno aluno) aoSalvar;

  const FormularioAluno({
    super.key,
    this.alunoParaEditar,
    required this.aoSalvar,
  });

  @override
  _FormularioAlunoState createState() => _FormularioAlunoState();
}

class _FormularioAlunoState extends State<FormularioAluno> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _telefoneController;
  late TextEditingController _mensalidadeController;
  late TextEditingController _nomeResponsavelController;
  late TextEditingController _telefoneResponsavelController;
  late List<TextEditingController> _pessoasAutorizadasControllers;

  @override
  void initState() {
    super.initState();
    final aluno = widget.alunoParaEditar;
    _nomeController = TextEditingController(text: aluno?.nome ?? '');
    _emailController = TextEditingController(text: aluno?.email ?? '');
    _telefoneController = TextEditingController(text: aluno?.telefone ?? '');
    _mensalidadeController = TextEditingController(text: aluno != null ? aluno.mensalidade.toStringAsFixed(2) : '');
    _nomeResponsavelController = TextEditingController(text: aluno?.nomeResponsavel ?? '');
    _telefoneResponsavelController = TextEditingController(text: aluno?.telefoneResponsavel ?? '');

    // Garante que haja pelo menos um controller se a lista estiver vazia
    _pessoasAutorizadasControllers = (aluno?.pessoasAutorizadas.isNotEmpty ?? false)
        ? aluno!.pessoasAutorizadas.map((nome) => TextEditingController(text: nome)).toList()
        : [TextEditingController()];
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _mensalidadeController.dispose();
    _nomeResponsavelController.dispose();
    _telefoneResponsavelController.dispose();
    for (var controller in _pessoasAutorizadasControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _adicionarPessoaAutorizada() {
    setState(() => _pessoasAutorizadasControllers.add(TextEditingController()));
  }

  // --- MODIFICAÇÃO AQUI ---
  void _removerPessoaAutorizada(int index) {
    setState(() {
      if (_pessoasAutorizadasControllers.length > 1) {
        // Se houver mais de um campo, remove o controller e o campo
        _pessoasAutorizadasControllers[index].dispose();
        _pessoasAutorizadasControllers.removeAt(index);
      } else {
        // Se for o último campo, apenas limpa o texto
        _pessoasAutorizadasControllers[index].clear();
      }
    });
  }
  // --- FIM DA MODIFICAÇÃO ---

  // ... dentro da classe _FormularioAlunoState ...

void _submeterFormulario() {
  if (_formKey.currentState!.validate()) {
    final novoAluno = Aluno(
      id: widget.alunoParaEditar?.id ?? '',
      dataCriacao: widget.alunoParaEditar?.dataCriacao ?? DateTime.now(),
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      telefone: _telefoneController.text,
      mensalidade: double.tryParse(_mensalidadeController.text.replaceAll(',', '.')) ?? 0.0,
      nomeResponsavel: _nomeResponsavelController.text.trim(),
      telefoneResponsavel: _telefoneResponsavelController.text,
      pessoasAutorizadas: _pessoasAutorizadasControllers
          .map((controller) => controller.text.trim())
          .where((nome) => nome.isNotEmpty)
          .toList(),
      ativo: widget.alunoParaEditar?.ativo ?? true,
    );
    widget.aoSalvar(novoAluno);
    
    // <<-- ALTERAÇÃO: Retorna 'true' para indicar sucesso para a tela anterior.
    Navigator.of(context).pop(true); 
  }
}


  @override
  Widget build(BuildContext context) {
    final titulo = widget.alunoParaEditar == null ? 'Adicionar Novo Aluno' : 'Editar Aluno';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppColor.textoPrincipal)),
          ),
          const Divider(height: 1, color: AppColor.borda),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSecaoTitulo("Informações do Aluno"),
                  _buildCampoTexto(_nomeController, "Nome Completo *", "Digite o nome completo"),
                  _buildCampoTexto(_mensalidadeController, "Valor da Mensalidade (R\$) *", "0,00", keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  const SizedBox(height: 24),
                  _buildSecaoTitulo("Informações do Responsável"),
                  _buildCampoTexto(_nomeResponsavelController, "Nome do Responsável *", "Nome completo do responsável"),
                  _buildCampoTexto(_emailController, "E-mail", "exemplo@email.com", isRequired: false, keyboardType: TextInputType.emailAddress),
                  _buildCampoTexto(_telefoneResponsavelController, "Telefone do Responsável *", "(00) 00000-0000", keyboardType: TextInputType.phone, formatters: [MascaraTelefoneInputFormatter()]),
                  const SizedBox(height: 24),
                  _buildSecaoPessoasAutorizadas(),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppColor.borda),
          _buildBotoesAcao(),
        ],
      ),
    );
  }

  Widget _buildSecaoTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.textoPrincipal)),
    );
  }

  Widget _buildCampoTexto(TextEditingController controller, String label, String placeholder, {bool isRequired = true, TextInputType? keyboardType, List<TextInputFormatter>? formatters}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: formatters,
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          labelStyle: const TextStyle(color: AppColor.textoSecundario),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColor.borda)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColor.borda)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColor.primaria, width: 2)),
        ),
        validator: isRequired
            ? (value) {
                if (value == null || value.trim().isEmpty) return 'Este campo é obrigatório.';
                return null;
              }
            : null,
      ),
    );
  }

  // --- MODIFICAÇÃO AQUI ---
  Widget _buildSecaoPessoasAutorizadas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSecaoTitulo("Pessoas Autorizadas a Retirar o Aluno"),
            TextButton.icon(
              onPressed: _adicionarPessoaAutorizada,
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Adicionar"),
              style: TextButton.styleFrom(foregroundColor: AppColor.primaria),
            )
          ],
        ),
        ..._pessoasAutorizadasControllers.asMap().entries.map((entry) {
          int index = entry.key;
          TextEditingController controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(child: _buildCampoTexto(controller, "Nome da pessoa autorizada ${index + 1}", "", isRequired: false)),
                // O botão de exclusão agora é sempre visível
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColor.erro),
                  onPressed: () => _removerPessoaAutorizada(index),
                )
              ],
            ),
          );
        }),
      ],
    );
  }
  // --- FIM DA MODIFICAÇÃO ---

  Widget _buildBotoesAcao() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Cancelar"),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _submeterFormulario,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaria,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(widget.alunoParaEditar != null ? "Salvar Alterações" : "Adicionar Aluno"),
          ),
        ],
      ),
    );
  }
}