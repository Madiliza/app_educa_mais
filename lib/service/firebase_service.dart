import 'package:Projeto_Educa_Mais/models/aluno.dart';
import 'package:Projeto_Educa_Mais/models/despesa.dart';
import 'package:Projeto_Educa_Mais/models/pagamento.dart';
import 'package:Projeto_Educa_Mais/models/status_pagamento.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- MÉTODOS PARA ALUNOS ---
  Stream<List<Aluno>> getAlunos() {
    return _db.collection('alunos').orderBy('nome').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Aluno.fromFirestore(doc)).toList());
  }

  Future<void> salvarAluno(Aluno aluno) {
    if (aluno.id.isEmpty) {
      // Cria um novo aluno e gera os pagamentos para os próximos 12 meses
      final batch = _db.batch();
      final alunoRef = _db.collection('alunos').doc();
      batch.set(alunoRef, aluno.toMap());
      
      // Gera os próximos 12 pagamentos
      _gerarPagamentosIniciais(batch, alunoRef.id, aluno.mensalidade);

      return batch.commit();
    } else {
      // Apenas atualiza o aluno existente
      return _db.collection('alunos').doc(aluno.id).update(aluno.toMap());
    }
  }

  void _gerarPagamentosIniciais(WriteBatch batch, String alunoId, double mensalidade) {
    final hoje = DateTime.now();
    for (int i = 0; i < 12; i++) {
      final dataVencimento = DateTime(hoje.year, hoje.month + i, 10);
      final pagamento = Pagamento(
        alunoId: alunoId,
        valor: mensalidade,
        dataVencimento: dataVencimento, 
        multaAtraso: 0.0,
        status: StatusPagamento.pendente,
      );
      final pagamentoRef = _db.collection('pagamentos').doc();
      batch.set(pagamentoRef, pagamento.toMap());
    }
  }

  Future<void> deletarAluno(String alunoId) async {
    final batch = _db.batch();
    final alunoRef = _db.collection('alunos').doc(alunoId);
    batch.delete(alunoRef);
    final pagamentosQuery = await _db.collection('pagamentos').where('alunoId', isEqualTo: alunoId).get();
    for (final doc in pagamentosQuery.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // --- MÉTODOS PARA DESPESAS ---
  Stream<List<Despesa>> getDespesas() {
    return _db.collection('despesas').orderBy('data', descending: true).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Despesa.fromFirestore(doc)).toList());
  }

  Future<void> salvarDespesa(Despesa despesa) {
    if (despesa.id.isEmpty) {
      return _db.collection('despesas').add(despesa.toMap());
    } else {
      return _db.collection('despesas').doc(despesa.id).update(despesa.toMap());
    }
  }

  Future<void> deletarDespesa(String despesaId) {
    return _db.collection('despesas').doc(despesaId).delete();
  }

  // --- MÉTODOS PARA PAGAMENTOS ---
  Stream<List<Pagamento>> getPagamentos() {
    return _db.collection('pagamentos').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Pagamento.fromFirestore(doc)).toList());
  }

  Future<void> adicionarPagamento(Pagamento pagamento) {
      return _db.collection('pagamentos').add(pagamento.toMap());
  }
  
  Future<void> salvarPagamento(Pagamento pagamento) async {
    try {
      // Converte o objeto Pagamento para um Map
      final pagamentoMap = pagamento.toMap();

      if (pagamento.id.isEmpty) {
        // Se o ID está vazio, é um novo pagamento. O .add() cria um ID automático.
        await _db.collection('pagamentos').add(pagamentoMap);
        print('Novo pagamento adicionado com sucesso.');
      } else {
        // Se já existe um ID, atualiza o documento existente.
        await _db.collection('pagamentos').doc(pagamento.id).update(pagamentoMap);
        print('Pagamento com ID ${pagamento.id} atualizado com sucesso.');
      }
    } catch (e) {
      print('Erro ao salvar pagamento no Firebase: $e');
      // Re-lança o erro para que a camada superior possa lidar com ele, se necessário.
      throw e;
    }
  }
  
  // Exemplo de como seu método marcarComoPago pode estar
  Future<void> marcarComoPago(String pagamentoId) async {
    await _db.collection('pagamentos').doc(pagamentoId).update({
      'status': 'pago',
      'dataPagamento': Timestamp.now(),
    });
  }
  }

  