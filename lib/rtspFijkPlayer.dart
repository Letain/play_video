import 'package:flutter/material.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:fijkplayer_skin/fijkplayer_skin.dart';
import 'package:fijkplayer_skin/schema.dart' show VideoSourceFormat;

class RtspFijkPlayer extends StatefulWidget {
  RtspFijkPlayer({required this.title});

  final String title;

  @override
  _RtspFijkPlayerState createState() => _RtspFijkPlayerState();
}


class _RtspFijkPlayerState extends State<RtspFijkPlayer> {
  final FijkPlayer player = FijkPlayer();
  
  int _curTabIdx = 0;
  int _curActiveIdx = 0;
  ShowConfigAbs vCfg = PlayerShowConfig();


  Map<String, List<Map<String, dynamic>>> videoList = {
    "video": [
      {
        "name": "Resource1",
        "list": [
          {
            "url": "rtsp://root:secom000@192.168.1.86:554/live1s1.sdp",
            "name": "Video1"
          },
          {
            "url": "rtsp://root:secom000@192.168.1.86:554/live1s1.sdp",
            "name": "Video2"
          },
          {
            "url": "rtsp://root:secom000@192.168.1.86:554/live1s1.sdp",
            "name": "Video3"
          }
        ]
      },
      {
        "name": "Resource2",
        "list": [
          {
            "url": "rtsp://root:secom000@192.168.1.86:554/live1s1.sdp",
            "name": "Video1"
          },
          {
            "url": "rtsp://root:secom000@192.168.1.86:554/live1s1.sdp",
            "name": "Video2"
          },
          {
            "url": "rtsp://root:secom000@192.168.1.86:554/live1s1.sdp",
            "name": "Video3"
          }
        ]
      },
    ]
  };

  VideoSourceFormat? _videoSourceTabs;

  @override
  void initState() {
    super.initState();
    // player.setDataSource(
    //     "https://sample-videos.com/video123/flv/240/big_buck_bunny_240p_10mb.flv",
    //     autoPlay: true);
    player.setOption(FijkOption.formatCategory, "rtsp_transport", "tcp");
    _videoSourceTabs = VideoSourceFormat.fromJson(videoList);
    speed = 1.0;
  }

  @override
  void dispose() {
    super.dispose();
    player.release();
  }

  void onChangeVideo(int curTabIdx, int curActiveIdx) {
    setState(() {
      _curTabIdx = curTabIdx;
      _curActiveIdx = curActiveIdx;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
        alignment: Alignment.center,
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: FijkView(player: player,
          height: 260,
          color: Colors.black,
          fit: FijkFit.cover,
          panelBuilder: (
              FijkPlayer player,
              FijkData data,
              BuildContext context,
              Size viewSize,
              Rect texturePos,
          ){
            return CustomFijkPanel(
              player: player,
              pageContent: context,
              viewSize: viewSize,
              texturePos: texturePos,
              playerTitle: "Title",
              onChangeVideo: onChangeVideo,
              curTabIdx: _curTabIdx,
              curActiveIdx: _curActiveIdx,
              showConfig: vCfg,
              videoFormat: _videoSourceTabs,
            );
          },
        ),
      ),
    );
  }
}

class PlayerShowConfig implements ShowConfigAbs {
  @override
  bool drawerBtn = true;
  @override
  bool nextBtn = true;
  @override
  bool speedBtn = true;
  @override
  bool topBar = true;
  @override
  bool lockBtn = true;
  @override
  bool autoNext = true;
  @override
  bool bottomPro = true;
  @override
  bool stateAuto = true;
  @override
  bool isAutoPlay = true;
}