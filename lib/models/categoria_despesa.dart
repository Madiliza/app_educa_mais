import 'package:Projeto_Educa_Mais/utils/app_colors.dart';
import 'package:flutter/material.dart';


enum CategoriaDespesa {
  material,
  contas,
  aluguel,
  transporte,
  outros, moradia, alimentacao,
}

/// Converte uma categoria em um mapa com ícone e cor para a UI.
Map<String, dynamic> toMapCategoriaDespesa(CategoriaDespesa categoria) {
  switch (categoria) {
    case CategoriaDespesa.material:
      return {'icone': Icons.construction, 'cor': Colors.orange};
    case CategoriaDespesa.contas:
      return {'icone': Icons.receipt_long, 'cor': Colors.blue};
    case CategoriaDespesa.aluguel:
      return {'icone': Icons.home, 'cor': Colors.green};
    case CategoriaDespesa.transporte:
      return {'icone': Icons.directions_bus, 'cor': Colors.purple};
    case CategoriaDespesa.outros:
    default:
      return {'icone': Icons.category, 'cor': AppColor.textoSecundario};
  }
}

/// Converte uma string para um enum CategoriaDespesa.
CategoriaDespesa categoriaFromString(String? categoriaStr) {
  return CategoriaDespesa.values.firstWhere(
    (e) => e.name == categoriaStr,
    orElse: () => CategoriaDespesa.outros,
  );
}