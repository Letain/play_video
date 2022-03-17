// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'videoResourceModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoGroup _$VideoGroupFromJson(Map<String, dynamic> json) => VideoGroup(
      name: json['name'] as String,
      list: (json['list'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$VideoGroupToJson(VideoGroup instance) =>
    <String, dynamic>{
      'name': instance.name,
      'list': instance.list,
    };

VideoItem _$VideoItemFromJson(Map<String, dynamic> json) => VideoItem(
      url: json['url'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$VideoItemToJson(VideoItem instance) => <String, dynamic>{
      'url': instance.url,
      'name': instance.name,
      'address': instance.address,
    };
