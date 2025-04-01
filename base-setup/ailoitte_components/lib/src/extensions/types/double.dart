extension AiloitteDoubleExtensions on double {
  String percentage() {
    return "${toStringAsFixed(1)} %";
  }

  String inAmount() {
    return "\$ ${toStringAsFixed(2)}";
  }
}
