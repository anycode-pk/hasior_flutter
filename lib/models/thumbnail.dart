import 'dart:convert';

Thumbnail thumbnailFromJson(String str) => Thumbnail.fromJson(json.decode(str));

String thumbnailToJson(Thumbnail data) => json.encode(data.toJson());

class Thumbnail {
  int id;
  String path;

  Thumbnail({
    required this.id,
    required this.path,
  });

  factory Thumbnail.fromJson(Map<String, dynamic> json) => Thumbnail(
        id: json["id"],
        path: json["path"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "path": path,
      };
}
