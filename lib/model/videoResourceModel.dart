import 'package:json_annotation/json_annotation.dart';

part 'videoResourceModel.g.dart';

// @JsonSerializable()
// class VideoList {
//   List<VideoGroup> video;
//
//   VideoList({required this.video});
//
//   factory VideoList.fromJson(Map<String, dynamic> srcJson) => _$VideoListFromJson(srcJson);
//   Map<String, dynamic> toJson() => _$VideoListToJson(this);
// }

@JsonSerializable()
class VideoGroup {
  final String name;
  List<Map<String, dynamic>> list;

  VideoGroup({required this.name, required this.list});
  factory VideoGroup.fromJson(Map<String, dynamic> srcJson) => _$VideoGroupFromJson(srcJson);
  Map<String, dynamic> toJson() => _$VideoGroupToJson(this);
}

@JsonSerializable()
class VideoItem {
  final String url;
  final String name;

  VideoItem({required this.url, required this.name});
  factory VideoItem.fromJson(Map<String, dynamic> srcJson) => _$VideoItemFromJson(srcJson);
  Map<String, dynamic> toJson() => _$VideoItemToJson(this);
}