enum Groups {
  STUDENT_COUNCIL(1),
  PARTNERS(2),
  MAILBOX(3),
  GENERAL(4);

  final int value;
  const Groups(this.value);

  factory Groups.fromValue(int value) {
    return values.firstWhere((element) => element.value == value);
  }
}
