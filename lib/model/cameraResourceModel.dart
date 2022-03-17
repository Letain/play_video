import 'package:json_annotation/json_annotation.dart';

part 'cameraResourceModel.g.dart';

@JsonSerializable()
class CameraList {
  List<CameraItem> cams;

  CameraList(this.cams,);

  factory CameraList.fromJson(Map<String, dynamic> srcJson) =>
      _$CameraListFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CameraListToJson(this);

}

@JsonSerializable()
class CameraItem {
  String camId;
  String name;
  String address;
  String rtspStreamUrl;

  CameraItem(this.camId, this.name, this.address, this.rtspStreamUrl);

  factory CameraItem.fromJson(Map<String, dynamic> srcJson) =>
      _$CameraItemFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CameraItemToJson(this);

}