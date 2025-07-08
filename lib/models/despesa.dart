import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Projeto_Educa_Mais/models/categoria_despesa.dart';

class Despesa {
  final String id;
  final String descricao;
  final double valor;
  final DateTime data;
  final CategoriaDespesa categoria;
  final bool isRecorrente;

  Despesa({
    this.id = '',
    required this.descricao,
    required this.valor,
    required this.data,
    required this.categoria,
    this.isRecorrente = false,
  });

  // Construtor para criar uma cópia com valores diferentes
  Despesa copyWith({
    String? id,
    String? descricao,
    double? valor,
    DateTime? data,
    CategoriaDespesa? categoria,
    bool? isRecorrente,
  }) {
    return Despesa(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      data: data ?? this.data,
      categoria: categoria ?? this.categoria,
      isRecorrente: isRecorrente ?? this.isRecorrente,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'descricao': descricao,
      'valor': valor,
      'data': Timestamp.fromDate(data),
      'categoria': categoria.name,
      'isRecorrente': isRecorrente,
    };
  }

  factory Despesa.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Despesa(
      id: doc.id,
      descricao: data['descricao'] ?? '',
      valor: (data['valor'] as num?)?.toDouble() ?? 0.0,
      data: (data['data'] as Timestamp? ?? Timestamp.now()).toDate(),
      categoria: categoriaFromString(data['categoria']),
      isRecorrente: data['isRecorrente'] ?? false,
    );
  }
}

CategoriaDespesa categoriaFromString(String? value) {
  return CategoriaDespesa.values.firstWhere(
    (e) => e.name == value,
    orElse: () => CategoriaDespesa.outros,
  );
}