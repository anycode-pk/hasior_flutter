class TicketOwner {
  String id;
  String email;

  TicketOwner({
    required this.id,
    required this.email,
  });

  factory TicketOwner.fromJson(Map<String, dynamic> json) => TicketOwner(
        id: json["id"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
      };
}
