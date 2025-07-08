import 'package:Projeto_Educa_Mais/models/categoria_despesa.dart';
import 'package:Projeto_Educa_Mais/models/despesa.dart';
import 'package:Projeto_Educa_Mais/utils/app_colors.dart';
import 'package:Projeto_Educa_Mais/utils/formatadores.dart';
import 'package:flutter/material.dart';

class ListaDespesas extends StatelessWidget {
  final List<Despesa> despesas;
  final Function(Despesa) aoEditarDespesa;
  final Function(String) aoDeletarDespesa;

  const ListaDespesas({
    super.key,
    required this.despesas,
    required this.aoEditarDespesa,
    required this.aoDeletarDespesa,
  });

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
          )
        ],
      ),
      child: despesas.isEmpty
          ? _buildEstadoVazio()
          : ListView.separated(
              itemCount: despesas.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                indent: 20,
                endIndent: 20,
                color: AppColor.borda,
              ),
              itemBuilder: (context, index) {
                final despesa = despesas[index];
                return _buildItemDespesa(context, despesa);
              },
            ),
    );
  }

  Widget _buildEstadoVazio() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 64.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.money_off, size: 48, color: AppColor.textoSecundario),
            SizedBox(height: 16),
            Text(
              "Nenhuma despesa registrada",
              style: TextStyle(fontSize: 18, color: AppColor.textoSecundario),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDespesa(BuildContext context, Despesa despesa) {
    final infoCategoria = toMapCategoriaDespesa(despesa.categoria);

    final Color corPrincipal = (infoCategoria['cor'] as Color);
    final Color corTexto = AppColor.textoPrincipal;
    final Color corValor = AppColor.erro;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: corPrincipal.withOpacity(0.15),
        child: Icon(infoCategoria['icone'], color: corPrincipal),
      ),
      title: Text(
        despesa.descricao,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: corTexto,
        ),
      ),
      subtitle: Text(Formatadores.formatarData(despesa.data)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Formatadores.formatarMoeda(despesa.valor),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: corValor,
            ),
          ),
          const SizedBox(width: 8), // Espaçamento para o botão de apagar
          IconButton(
            icon: const Icon(Icons.delete, color: AppColor.erro),
            onPressed: () => aoDeletarDespesa(despesa.id),
          ),
        ],
      ),
      onTap: () => aoEditarDespesa(despesa), 
    );
  }
}