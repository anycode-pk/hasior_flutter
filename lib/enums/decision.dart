enum Decision {
  NONE(0),
  REJECT(1),
  ACCEPT(2);

  final int value;
  const Decision(this.value);

  factory Decision.fromValue(int value) {
    return values.firstWhere((element) => element.value == value);
  }
}
