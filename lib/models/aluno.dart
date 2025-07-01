import 'package:cloud_firestore/cloud_firestore.dart';

class Aluno {
  final String id;
  String nome;
  String email;
  String telefone;
  double mensalidade;
  String nomeResponsavel;
  String telefoneResponsavel;
  List<String> pessoasAutorizadas;
  final DateTime dataCriacao;
  final bool ativo;

  Aluno({
    this.id = '',
    required this.nome,
    this.email = '',
    this.telefone = '',
    required this.mensalidade,
    required this.nomeResponsavel,
    required this.telefoneResponsavel,
    required this.pessoasAutorizadas,
    required this.dataCriacao,
    required this.ativo,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'mensalidade': mensalidade,
      'nomeResponsavel': nomeResponsavel,
      'telefoneResponsavel': telefoneResponsavel,
      'pessoasAutorizadas': pessoasAutorizadas,
      'dataCriacao': Timestamp.fromDate(dataCriacao),
      'ativo': ativo,
    };
  }

  factory Aluno.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Aluno(
      id: doc.id,
      nome: data['nome'] ?? '',
      email: data['email'] ?? '',
      telefone: data['telefone'] ?? '',
      mensalidade: (data['mensalidade'] as num?)?.toDouble() ?? 0.0,
      nomeResponsavel: data['nomeResponsavel'] ?? '',
      telefoneResponsavel: data['telefoneResponsavel'] ?? '',
      pessoasAutorizadas: List<String>.from(data['pessoasAutorizadas'] ?? []),
      dataCriacao: (data['dataCriacao'] as Timestamp? ?? Timestamp.now()).toDate(),
      ativo: data['ativo'] ?? true,
    );
  }
  }