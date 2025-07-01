enum StatusPagamento {
  pago,
  pendente,
  atrasado,
}

StatusPagamento statusFromString(String? statusStr) {
  return StatusPagamento.values.firstWhere(
    (e) => e.name == statusStr,
    orElse: () => StatusPagamento.pendente,
  );
}