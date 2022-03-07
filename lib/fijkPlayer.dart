import 'package:flutter/material.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'myFijkplayerSkin/fijkplayer_skin.dart';
import 'myFijkplayerSkin/schema.dart' show VideoSourceFormat;

class MyHomePage extends StatefulWidget {
  MyHomePage({required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  FijkPlayer player = FijkPlayer();

  int _curTabIdx = 0;
  int _curActiveIdx = 0;
  ShowConfigAbs vCfg = PlayerShowConfig();

  final streamTextController = TextEditingController();

  Map<String, List<Map<String, dynamic>>> videoList = {
    "video": [
      {
        "name": "Resource1",
        "list": [
          {
            "url": "https://download.samplelib.com/mp4/sample-30s.mp4",
            "name": "Video1"
          },
          {
            "url": "https://download.samplelib.com/mp4/sample-30s.mp4",
            "name": "Video2"
          },
          {
            "url": "https://download.samplelib.com/mp4/sample-30s.mp4",
            "name": "Video3"
          }
        ]
      },
      {
        "name": "Resource2",
        "list": [
          {
            "url": "https://download.samplelib.com/mp4/sample-30s.mp4",
            "name": "Video1"
          },
          {
            "url": "https://download.samplelib.com/mp4/sample-30s.mp4",
            "name": "Video2"
          },
          {
            "url": "https://download.samplelib.com/mp4/sample-30s.mp4",
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
                       player.release();
                      player = FijkPlayer();
                      // player.prepareAsync();

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
                      _videoSourceTabs = VideoSourceFormat.fromJson(videoList);
                      _curTabIdx = 0;
                      _curActiveIdx = 0;
                      speed = 1.0;
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