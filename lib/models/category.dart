import 'dart:convert';

List<Category> categoriesFromJson(String str) =>
    List<Category>.from(json.decode(str).map((x) => Category.fromJson(x)));

Category categoryFromJson(String str) => Category.fromJson(json.decode(str));

String categoryToJson(Category data) => json.encode(data.toJson());

class Category {
  int id;
  String name;
  bool isDisabled;

  Category({
    required this.id,
    required this.name,
    required this.isDisabled,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        isDisabled: json["isDisabled"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "isDisabled": isDisabled,
      };
}
