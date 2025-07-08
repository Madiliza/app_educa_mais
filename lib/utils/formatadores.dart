import 'package:intl/intl.dart';

import 'package:flutter/services.dart';


class Formatadores {
  // Prevenindo instanciação da classe.
  Formatadores._();

  static String formatarMoeda(double valor) {
   
    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatador.format(valor);
  }

  static String formatarData(DateTime data) {
    final formatador = DateFormat('dd/MM/yyyy');
    return formatador.format(data);
  }

  static String formatarDataHora(DateTime data) {
    final formatador = DateFormat('dd/MM/yyyy HH:mm');
    return formatador.format(data);
  }
}

class MascaraTelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final novoTexto = newValue.text;
    if (novoTexto.isEmpty) {
      return newValue.copyWith(text: '');
    }


    String digitos = novoTexto.replaceAll(RegExp(r'\D'), '');

    if (digitos.length > 11) {
      digitos = digitos.substring(0, 11);
    }

    String textoFormatado = '';
    if (digitos.isNotEmpty) {
      textoFormatado = '(';
      if (digitos.length > 2) {
        textoFormatado += '${digitos.substring(0, 2)}) ';
        if (digitos.length > 7) {
          textoFormatado += '${digitos.substring(2, 7)}-';
          textoFormatado += digitos.substring(7);
        } else {
          textoFormatado += digitos.substring(2);
        }
      } else {
        textoFormatado += digitos;
      }
    }

    return TextEditingValue(
      text: textoFormatado,
      selection: TextSelection.collapsed(offset: textoFormatado.length),
    );
  }
}
