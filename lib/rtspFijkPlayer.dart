import 'package:flutter/material.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'myFijkplayerSkin/fijkplayer_skin.dart';
import 'myFijkplayerSkin/schema.dart' show VideoSourceFormat;

class RtspFijkPlayer extends StatefulWidget {
  RtspFijkPlayer({required this.title});

  final String title;

  @override
  _RtspFijkPlayerState createState() => _RtspFijkPlayerState();
}


class _RtspFijkPlayerState extends State<RtspFijkPlayer> {
  final FijkPlayer player = FijkPlayer();

  final streamTextController = TextEditingController();

  Map<String, List<Map<String, dynamic>>> videoList = {
    "video": [
      {
        "name": "Resource1",
        "list": [
          {
            "url": "rtsp://root:secom000@192.168.1.86:554/live1s1.sdp",
            "name": "Video1"
          }
        ]
      }
    ]
  };

  VideoSourceFormat? _videoSourceTabs;

  int _curTabIdx = 0;
  int _curActiveIdx = 0;

  ShowConfigAbs vCfg = PlayerShowConfig();

  @override
  void initState() {
    super.initState();
    // player.setDataSource(
    //     "https://sample-videos.com/video123/flv/240/big_buck_bunny_240p_10mb.flv",
    //     autoPlay: true);
    initPlayer();
  }

  void initPlayer(){
    player.setOption(FijkOption.formatCategory, "rtsp_transport", "tcp");
    initResource();
    speed = 1.0;
  }

  void initResource(){
    _videoSourceTabs = VideoSourceFormat.fromJson(videoList);
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
    return Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: FijkView(player: player,
                    height: 260,
                    color: Colors.black,
                    fit: FijkFit.cover,
                    panelBuilder: (FijkPlayer player,
                        FijkData data,
                        BuildContext context,
                        Size viewSize,
                        Rect texturePos,) {
                      return CustomFijkPanel(
                        player: player,
                        pageContent: context,
                        viewSize: viewSize,
                        texturePos: texturePos,
                        playerTitle: "",
                        curTabIdx: _curTabIdx,
                        curActiveIdx: _curActiveIdx,
                        onChangeVideo: onChangeVideo,
                        showConfig: vCfg,
                        videoFormat: _videoSourceTabs,
                      );
                    },
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 8.0),
                    child: TextField(
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Input a stream address'
                      ),
                      controller: streamTextController,
                    )
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      videoList = {
                        "video": [
                          {
                            "name": "Resource1",
                            "list": [
                              {
                                "url": streamTextController.text,
                                "name": "Video1"
                              }
                            ]
                          }
                        ]
                      };
                      initResource();
                      _curActiveIdx = 0;
                      _curTabIdx = 0;
                    });
                  },
                  child: const Text('Play the stream'),
                )
              ],
            )
        )
    );
  }
}

class PlayerShowConfig implements ShowConfigAbs {
  @override
  bool drawerBtn = false;
  @override
  bool nextBtn = false;
  @override
  bool speedBtn = true;
  @override
  bool topBar = false;
  @override
  bool lockBtn = true;
  @override
  bool autoNext = false;
  @override
  bool bottomPro = true;
  @override
  bool stateAuto = true;
  @override
  bool isAutoPlay = true;
}