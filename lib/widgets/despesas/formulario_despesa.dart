import 'package:Projeto_Educa_Mais/models/categoria_despesa.dart';
import 'package:Projeto_Educa_Mais/models/despesa.dart';
import 'package:Projeto_Educa_Mais/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormularioDespesa extends StatefulWidget {
  final Despesa? despesaParaEditar;
  final Function(Despesa) aoSalvar;

  const FormularioDespesa({
    super.key,
    this.despesaParaEditar,
    required this.aoSalvar,
  });

  @override
  _FormularioDespesaState createState() => _FormularioDespesaState();
}

class _FormularioDespesaState extends State<FormularioDespesa> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _dataController = TextEditingController();

  DateTime? _dataSelecionada;
  CategoriaDespesa? _categoriaSelecionada;
  bool _isRecorrente = false; // <-- NOVO ESTADO
  bool _pago = false;

  @override
  void initState() {
    super.initState();
    if (widget.despesaParaEditar != null) {
      final d = widget.despesaParaEditar!;
      _descricaoController.text = d.descricao;
      _valorController.text = d.valor.toStringAsFixed(2).replaceAll('.', ',');
      _dataSelecionada = d.data;
      _dataController.text = DateFormat('dd/MM/yyyy').format(d.data);
      _categoriaSelecionada = d.categoria;
      _isRecorrente = d.isRecorrente; 
      _pago = d.pago;
    } else {
      _dataSelecionada = DateTime.now();
      _dataController.text = DateFormat('dd/MM/yyyy').format(_dataSelecionada!);
      _categoriaSelecionada = CategoriaDespesa.outros;
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0;
      final novaDespesa = Despesa(
        id: widget.despesaParaEditar?.id ?? '', // Mantenha o ID se estiver editando
        descricao: _descricaoController.text,
        valor: valor,
        data: _dataSelecionada!,
        categoria: _categoriaSelecionada!,
        isRecorrente: _isRecorrente, // <-- Salva o estado
        pago: _pago,
      );
      widget.aoSalvar(novaDespesa);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.despesaParaEditar == null ? 'Nova Despesa' : 'Editar Despesa',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valorController,
              decoration: const InputDecoration(labelText: 'Valor (R\$)', prefixText: 'R\$ '),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CategoriaDespesa>(
              value: _categoriaSelecionada,
              items: CategoriaDespesa.values.map((categoria) {
                return DropdownMenuItem(
                  value: categoria,
                  child: Text(categoria.name[0].toUpperCase() + categoria.name.substring(1)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _categoriaSelecionada = value);
              },
              decoration: const InputDecoration(labelText: 'Categoria'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dataController,
              decoration: const InputDecoration(labelText: 'Data de vencimento', icon: Icon(Icons.calendar_today)),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _dataSelecionada ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _dataSelecionada = pickedDate;
                    _dataController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            // ✅ NOVO WIDGET CHECKBOX
            CheckboxListTile(
              title: const Text("Despesa Recorrente"),
              subtitle: const Text("Esta despesa se repetirá todo mês."),
              value: _isRecorrente,
              onChanged: (bool? value) {
                setState(() => _isRecorrente = value ?? false);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColor.primaria,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaria,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}