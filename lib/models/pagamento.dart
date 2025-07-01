// Em: models/pagamento.dart

import 'package:Projeto_Educa_Mais/models/status_pagamento.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Pagamento {
  final String id;
  final String alunoId;
  final double valor;
  final DateTime dataVencimento;
  final DateTime? dataPagamento;
  final StatusPagamento status;
  final double multaAtraso;

  Pagamento({
    this.id = '',
    required this.alunoId,
    required this.valor,
    required this.dataVencimento,
    this.dataPagamento,
    StatusPagamento? status,
    this.multaAtraso = 0.0,
  }) : status = status ?? _calcularStatus(dataVencimento, dataPagamento);

  static StatusPagamento _calcularStatus(
      DateTime dataVencimento, DateTime? dataPagamento) {
    if (dataPagamento != null) {
      return StatusPagamento.pago;
    }
    final hoje = DateUtils.dateOnly(DateTime.now());
    final vencimento = DateUtils.dateOnly(dataVencimento);

    if (hoje.isAfter(vencimento)) {
      return StatusPagamento.atrasado;
    }
    return StatusPagamento.pendente;
  }

  Pagamento copyWith({
    String? id,
    String? alunoId,
    double? valor,
    DateTime? dataVencimento,
    StatusPagamento? status,
    DateTime? dataPagamento,
    double? multaAtraso,
  }) {
    return Pagamento(
      id: id ?? this.id,
      alunoId: alunoId ?? this.alunoId,
      valor: valor ?? this.valor,
      dataVencimento: dataVencimento ?? this.dataVencimento,
      status: status ?? this.status,
      // Se dataPagamento for fornecido, o construtor já recalcula o status
      dataPagamento: dataPagamento ?? this.dataPagamento,
      multaAtraso: multaAtraso ?? this.multaAtraso,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'alunoId': alunoId,
      'valor': valor,
      'dataVencimento': Timestamp.fromDate(dataVencimento),
      'dataPagamento':
          dataPagamento != null ? Timestamp.fromDate(dataPagamento!) : null,
      'status': status.name,
      'multaAtraso': multaAtraso,
    };
  }
  
  // ✅ REFINAMENTO: O `fromFirestore` agora usa o `fromMap`.
  factory Pagamento.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Pagamento.fromMap(doc.data()!, doc.id);
  }

  // ✅ REFINAMENTO: Um construtor que apenas lida com o Map. Torna o código mais testável.
  factory Pagamento.fromMap(Map<String, dynamic> map, String id) {
    final dataVencimento = (map['dataVencimento'] as Timestamp? ?? Timestamp.now()).toDate();
    final dataPagamento = (map['dataPagamento'] as Timestamp?)?.toDate();
    
    return Pagamento(
      id: id,
      alunoId: map['alunoId'] ?? '',
      valor: (map['valor'] as num?)?.toDouble() ?? 0.0,
      dataVencimento: dataVencimento,
      dataPagamento: dataPagamento,
      // Passa o status do banco para o construtor. Se for nulo, o construtor calcula.
      status: statusFromString(map['status']),
      multaAtraso: (map['multaAtraso'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// Função auxiliar para converter String para Enum (coloque fora da classe)
StatusPagamento statusFromString(String? statusName) {
  if (statusName == null) return StatusPagamento.pendente;
  try {
    return StatusPagamento.values.firstWhere((e) => e.name.toLowerCase() == statusName.toLowerCase());
  } catch (e) {
    return StatusPagamento.pendente; // Valor padrão em caso de erro
  }
}