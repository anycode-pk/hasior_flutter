import 'dart:convert';

import 'package:hasior_flutter/models/group.dart';
import 'package:hasior_flutter/models/thumbnail.dart';

List<Thred> thredsFromJson(String str) =>
    List<Thred>.from(json.decode(str).map((x) => Thred.fromJson(x)));

Thred thredFromJson(String str) => Thred.fromJson(json.decode(str));

String thredsToJson(List<Thred> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Thred {
  String? text;
  Group? group;
  bool? isPrivate;
  int? amountOfComments;
  int? displayMode;
  List<Thumbnail>? images;
  int? id;

  Thred(
      {this.text,
      this.group,
      this.isPrivate,
      this.amountOfComments,
      this.displayMode,
      this.images,
      this.id});

  Thred.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    group = json['group'] != null ? new Group.fromJson(json['group']) : null;
    isPrivate = json['isPrivate'];
    amountOfComments = json['amountOfComments'];
    displayMode = json['displayMode'];
    if (json['images'] != null) {
      images = <Thumbnail>[];
      json['images'].forEach((v) {
        images!.add(new Thumbnail.fromJson(v));
      });
    }
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
    if (this.group != null) {
      data['group'] = this.group!.toJson();
    }
    data['isPrivate'] = this.isPrivate;
    data['amountOfComments'] = this.amountOfComments;
    data['displayMode'] = this.displayMode;
    if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }
    data['id'] = this.id;
    return data;
  }
}
