import 'dart:async';
import 'package:Projeto_Educa_Mais/models/aluno.dart';
import 'package:Projeto_Educa_Mais/models/despesa.dart';
import 'package:Projeto_Educa_Mais/models/pagamento.dart';
import 'package:Projeto_Educa_Mais/models/status_pagamento.dart';
import 'package:Projeto_Educa_Mais/service/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppState with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Aluno> _alunos = [];
  List<Despesa> _despesas = [];
  List<Pagamento> _pagamentos = [];
  bool _isLoading = true;

  bool _alunosCarregados = false;
  bool _despesasCarregadas = false;
  bool _pagamentosCarregados = false;

  StreamSubscription? _alunosSubscription;
  StreamSubscription? _despesasSubscription;
  StreamSubscription? _pagamentosSubscription;

  AppState() {
    _init();
  }

  void _init() {
    _isLoading = true;
    notifyListeners();

    _alunosSubscription?.cancel();
    _alunosSubscription = _firebaseService.getAlunos().listen(
      (alunos) {
        _alunos = alunos;
        _alunosCarregados = true;
        _checkLoading();
      },
      onError: (error) {
        print('Erro ao carregar alunos: $error');
        _alunosCarregados = true;
        _checkLoading();
      },
    );

    _despesasSubscription?.cancel();
    _despesasSubscription = _firebaseService.getDespesas().listen(
      (despesas) {
        _despesas = despesas;
        _despesasCarregadas = true;
        _checkLoading();
      },
      onError: (error) {
        print('Erro ao carregar despesas: $error');
        _despesasCarregadas = true;
        _checkLoading();
      },
    );

    _pagamentosSubscription?.cancel();
    _pagamentosSubscription = _firebaseService.getPagamentos().listen(
      (pagamentos) {
        _pagamentos = pagamentos;
        _pagamentos.sort((a, b) => b.dataVencimento.compareTo(a.dataVencimento));
        _pagamentosCarregados = true;
        _checkLoading();
      },
      onError: (error) {
        print('Erro ao carregar pagamentos: $error');
        _pagamentosCarregados = true;
        _checkLoading();
      },
    );
  }

  bool _recorrenciasVerificadas = false;

  void _checkLoading() {
    if (_alunosCarregados &&
        _despesasCarregadas &&
        _pagamentosCarregados &&
        !_recorrenciasVerificadas) {
      
      _recorrenciasVerificadas = true;
      
      _verificarECriarRecorrencias().then((_) {
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  // --- GETTERS ---
  List<Aluno> get alunos => _alunos;
  List<Despesa> get despesas => _despesas;
  List<Pagamento> get pagamentos => _pagamentos;
  bool get isLoading => _isLoading;

  // --- MÉTODOS DE CRUD ---
  Future<void> salvarAluno(Aluno aluno) async {
    await _firebaseService.salvarAluno(aluno);
  }

  Future<void> deletarAluno(String alunoId) async {
    await _firebaseService.deletarAluno(alunoId);
  }

  Future<void> salvarDespesa(Despesa despesa) async {
    await _firebaseService.salvarDespesa(despesa);
  }

  Future<void> deletarDespesa(String despesaId) async {
    await _firebaseService.deletarDespesa(despesaId);
  }

  // ✅ CORREÇÃO: A função foi movida para o nível da classe
  Future<void> alternarStatusPaga(Despesa despesa) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return; // Garante que o usuário está logado

      final docRef = _db
          .collection('usuarios') // Ajuste o caminho se necessário
          .doc(user.uid)
          .collection('despesas')
          .doc(despesa.id);

      // Atualiza apenas o campo 'pago', invertendo o valor booleano atual
      await docRef.update({'pago': !despesa.pago});

      // O StreamBuilder que escuta as despesas cuidará de atualizar a UI.
    } catch (e) {
      print("Erro ao alternar status da despesa: $e");
    }
  }

  Future<String> marcarComoPago(String pagamentoId) async {
    try {
      await _firebaseService.marcarComoPago(pagamentoId);
      final index = _pagamentos.indexWhere((p) => p.id == pagamentoId);
      if (index != -1) {
        _pagamentos[index] = _pagamentos[index].copyWith(
          status: StatusPagamento.pago,
          dataPagamento: DateTime.now(),
        );
        notifyListeners();
      }
      return "Pagamento confirmado com sucesso!";
    } catch (e) {
      print("Erro ao marcar como pago no AppState: $e");
      return "Erro ao confirmar pagamento: $e";
    }
  }

  Future<void> salvarPagamento(Pagamento pagamento) async {
    await _firebaseService.salvarPagamento(pagamento);
  }

  // --- LÓGICA DE RECORRÊNCIA ---
  Future<void> _verificarECriarRecorrencias() async {
    print("Iniciando verificação de recorrências...");
    
    await Future.wait([
      _gerarPagamentosRecorrentes(),
      _gerarDespesasRecorrentes(),
    ]);

    print("Verificação de recorrências finalizada.");
  }

  Future<void> _gerarPagamentosRecorrentes() async {
    final agora = DateTime.now();
    const diaVencimento = 10;

    for (final aluno in _alunos) {
      if (!aluno.ativo) continue; // Pula alunos inativos

      final pagamentoExiste = _pagamentos.any((p) =>
          p.alunoId == aluno.id &&
          p.dataVencimento.month == agora.month &&
          p.dataVencimento.year == agora.year);

      if (!pagamentoExiste) {
        print("Criando pagamento para ${aluno.nome} para o mês ${agora.month}/${agora.year}");
        
        final novoPagamento = Pagamento(
          id: '',
          alunoId: aluno.id,
          valor: aluno.mensalidade,
          dataVencimento: DateTime(agora.year, agora.month, diaVencimento),
          status: StatusPagamento.pendente,
        );
        
        await salvarPagamento(novoPagamento);
      }
    }
  }

  Future<void> _gerarDespesasRecorrentes() async {
    final agora = DateTime.now();
    // Filtra apenas as despesas que são a "base" da recorrência.
    // Você pode precisar ajustar essa lógica. Por exemplo, pegar a despesa
    // recorrente do mês passado para gerar a deste mês.
    final despesasBase = _despesas.where((d) => d.isRecorrente).toList();

    for (final despesaBase in despesasBase) {
      final despesaExiste = _despesas.any((d) =>
          d.descricao.toLowerCase() == despesaBase.descricao.toLowerCase() &&
          d.data.month == agora.month &&
          d.data.year == agora.year);

      if (!despesaExiste) {
        print("Criando despesa recorrente '${despesaBase.descricao}' para o mês ${agora.month}/${agora.year}");
        
        final ultimoDiaDoMesAtual = DateTime(agora.year, agora.month + 1, 0).day;
        final diaVencimento = despesaBase.data.day > ultimoDiaDoMesAtual ? ultimoDiaDoMesAtual : despesaBase.data.day;

        final novaDespesa = Despesa(
          id: '',
          descricao: despesaBase.descricao,
          valor: despesaBase.valor,
          categoria: despesaBase.categoria,
          data: DateTime(agora.year, agora.month, diaVencimento),
          isRecorrente: true, 
          pago: false, // Nova despesa recorrente sempre nasce como não paga
        );
        
        await salvarDespesa(novaDespesa);
      }
    } // ✅ CORREÇÃO: Chave do 'for' loop no lugar certo.
  } // ✅ CORREÇÃO: Chave do método no lugar certo.

  @override
  void dispose() {
    _alunosSubscription?.cancel();
    _despesasSubscription?.cancel();
    _pagamentosSubscription?.cancel();
    super.dispose();
  }
}