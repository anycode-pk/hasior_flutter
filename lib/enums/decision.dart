enum Decision { NONE, REJECT, ACCEPT }

final decisionValues =
    EnumValues({0: Decision.NONE, 1: Decision.REJECT, 2: Decision.ACCEPT});

class EnumValues<T> {
  Map<int, T> map;
  late Map<T, int> reverseMap;

  EnumValues(this.map);

  Map<T, int> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
