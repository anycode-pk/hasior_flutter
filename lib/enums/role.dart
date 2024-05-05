enum Role {
  USER("USER"),
  ADMIN("ADMIN"),
  OWNER("OWNER");

  final String value;
  const Role(this.value);

  factory Role.fromValue(String value) {
    return values.firstWhere((element) => element.value == value);
  }
}
