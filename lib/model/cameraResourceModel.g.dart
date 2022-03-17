// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cameraResourceModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CameraList _$CameraListFromJson(Map<String, dynamic> json) => CameraList(
      (json['cams'] as List<dynamic>)
          .map((e) => CameraItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CameraListToJson(CameraList instance) =>
    <String, dynamic>{
      'cams': instance.cams,
    };

CameraItem _$CameraItemFromJson(Map<String, dynamic> json) => CameraItem(
      json['camId'] as String,
      json['name'] as String,
      json['address'] as String,
      json['rtspStreamUrl'] as String,
    );

Map<String, dynamic> _$CameraItemToJson(CameraItem instance) =>
    <String, dynamic>{
      'camId': instance.camId,
      'name': instance.name,
      'address': instance.address,
      'rtspStreamUrl': instance.rtspStreamUrl,
    };
