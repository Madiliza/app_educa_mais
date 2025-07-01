class MesAno {
  final int ano;
  final int mes;

  MesAno(this.ano, this.mes);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MesAno &&
          runtimeType == other.runtimeType &&
          ano == other.ano &&
          mes == other.mes;

  @override
  int get hashCode => ano.hashCode ^ mes.hashCode;
}
