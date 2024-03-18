import 'dart:convert';

List<Thumbnail> thumbnailListFromJson(String str) => 
  List<Thumbnail>.from(json.decode(str).map((x) => Thumbnail.fromJson(x)));

Thumbnail thumbnailFromJson(String str) => Thumbnail.fromJson(json.decode(str));

String thumbnailToJson(Thumbnail data) => json.encode(data.toJson());

class Thumbnail {
  int id;
  String path;
  bool isThumbnail;

  Thumbnail({
    required this.id,
    required this.path,
    required this.isThumbnail,
  });

  factory Thumbnail.fromJson(Map<String, dynamic> json) => Thumbnail(
    id: json["id"],
    path: json["path"],
    isThumbnail: json["isThumbnail"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "path": path,
    "isThumbnail": isThumbnail
  };
}
