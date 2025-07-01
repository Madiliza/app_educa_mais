import 'dart:ui';
import 'package:flutter/material.dart';


class AppColor {

  // Usadas para elementos principais de interação, como botões, links ativos e cabeçalhos.
  static const Color primaria = Color.fromARGB(255, 235, 143, 37); 
  static const Color primariaClaro = Color(0xFFDBEAFE); 

  // Cores de Feedback Semântico
  static const Color sucesso = Color(0xFF16A34A); // Verde para indicar sucesso.
  static const Color sucessoClaro = Color(0xFFDCFCE7); // Fundo para alertas de sucesso.
  static const Color aviso = Color(0xFFFBBF24); // Amarelo para alertas e avisos.
  static const Color avisoClaro = Color(0xFFFEF9C3); // Fundo para alertas de aviso.
  static const Color erro = Color(0xFFDC2626); // Vermelho para indicar erros e ações destrutivas.
  static const Color erroClaro = Color(0xFFFEE2E2); // Fundo para alertas de erro.

  // Cores de Texto
  static const Color textoPrincipal = Color(0xFF1F2937); 
  static const Color textoSecundario = Color(0xFF6B7280); 
  static const Color textoDesabilitado = Color(0xFF9CA3AF); 
  static const Color textoContraste = Colors.white; 

  // Cores de Fundo e UI
  static const Color fundo = Color(0xFFF9FAFB); 
  static const Color fundoCard = Colors.white; 
  static const Color borda = Color(0xFFE5E7EB); 
  static const Color bordaFoco = Color(0xFFD1D5DB); 

  // Prevenindo instanciação da classe.
  AppColor._();
}