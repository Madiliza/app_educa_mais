import 'package:intl/intl.dart';

import 'package:flutter/services.dart';

/// Uma classe de utilitários para formatação de dados comuns na aplicação.
///
/// Fornece métodos estáticos para garantir que valores como moeda, datas e
/// números de telefone sejam exibidos de forma consistente e localizada em
/// todo o aplicativo.
class Formatadores {
  // Prevenindo instanciação da classe.
  Formatadores._();

  /// Formata um valor numérico [valor] para uma string de moeda no formato brasileiro (R$).
  ///
  /// Exemplo: `1250.75` se torna `"R$ 1.250,75"`.
  static String formatarMoeda(double valor) {
    // Utiliza o NumberFormat da biblioteca intl para uma formatação de moeda
    // que respeita as convenções locais (locale 'pt_BR').
    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatador.format(valor);
  }

  /// Formata um objeto [DateTime] para uma string de data no formato "dd/MM/yyyy".
  ///
  /// Exemplo: `DateTime(2023, 10, 27)` se torna `"27/10/2023"`.
  static String formatarData(DateTime data) {
    // Utiliza o DateFormat para garantir uma representação de data padronizada.
    final formatador = DateFormat('dd/MM/yyyy');
    return formatador.format(data);
  }

  /// Formata um objeto [DateTime] para uma string de data e hora no formato "dd/MM/yyyy HH:mm".
  ///
  /// Exemplo: `DateTime(2023, 10, 27, 14, 30)` se torna `"27/10/2023 14:30"`.
  static String formatarDataHora(DateTime data) {
    final formatador = DateFormat('dd/MM/yyyy HH:mm');
    return formatador.format(data);
  }
}

/// Um [TextInputFormatter] para aplicar uma máscara de telefone (XX) XXXXX-XXXX.
///
/// Facilita a entrada de números de telefone pelos usuários, garantindo um formato consistente.
class MascaraTelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final novoTexto = newValue.text;
    if (novoTexto.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove todos os caracteres não numéricos.
    String digitos = novoTexto.replaceAll(RegExp(r'\D'), '');

    // Limita o número de dígitos a 11 (DDD + 9 dígitos).
    if (digitos.length > 11) {
      digitos = digitos.substring(0, 11);
    }

    // Aplica a formatação (XX) XXXXX-XXXX.
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
