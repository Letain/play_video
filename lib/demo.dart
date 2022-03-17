import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:http/http.dart' as http;

import 'dto/demoNavigatorParameter.dart';
import 'myFijkplayerSkin/fijkplayer_skin.dart';
import 'myFijkplayerSkin/schema.dart' show VideoSourceFormat;

import 'model/videoResourceModel.dart';

class DemoPlayer extends StatefulWidget {
  DemoPlayer({required this.title, this.parameter});

  final String title;
  final DemoNavigatorParameter? parameter;

  @override
  _DemoPlayerState createState() => _DemoPlayerState();
}


class _DemoPlayerState extends State<DemoPlayer> with TickerProviderStateMixin {
  final FijkPlayer player = FijkPlayer();

  late Map<String, List<Map<String, dynamic>>> videoList;

  VideoSourceFormat? _videoSourceTabs;

  int _curTabIdx = 0;
  int _curActiveIdx = 0;

  ShowConfigAbs vCfg = PlayerShowConfig();

  late TabController _tabController;

  Timer? _autoRefreshTimer;
  String autoMessage = "";
  http.Client client = http.Client();

  Map<String, dynamic> demoList() {
    var video1 = VideoItem(
      // url: "rtsp://root:secom000@192.168.1.86:554/live1s1.sdp", name: "Cam1");
        url: "https://download.samplelib.com/mp4/sample-30s.mp4",
        name: "Cam1");
    var video2 = VideoItem(
      // url: "rtsp://root:secom000@192.168.1.86:554/live1s2.sdp", name: "Cam2");
        url: "https://download.samplelib.com/mp4/sample-5s.mp4", name: "Cam1");
    var videoG = VideoGroup(
        name: "カメラ一覧", list: [video1.toJson(), video2.toJson()]);

    return videoG.toJson();
  }

  @override
  void initState() {
    super.initState();

    if(widget.parameter != null
        && widget.parameter?.cameraListUrl != null) {
      try {
        // todo camera list logic
        // maybe future builder
        // var response = await client.get(
        //     Uri.parse(widget.parameter!.cameraListUrl!));
        // still demo
        videoList = {"video": [demoList()]};
      }
      finally {
        // demo list
        videoList = {"video": [demoList()]};
        if (kDebugMode) {
          print('http request failed');
        }
      }
    }
    else {
      videoList = {"video": [demoList()]};
    }
    player.setOption(FijkOption.formatCategory, "rtsp_transport", "tcp");
    _videoSourceTabs = VideoSourceFormat.fromJson(videoList);

    _tabController = TabController(
      length: _videoSourceTabs!.video!.length,
      vsync: this,
    );

    speed = 1.0;

    _autoRefreshTimer =
        Timer.periodic(const Duration(seconds: 2), (timer) async {
          try {
            var response = await client.get(
                Uri.parse('https://geek-jokes.sameerkumar.website/api'));
            setState(() {
              autoMessage = response.body;
            });
          }
          finally {
            if (kDebugMode) {
              print('http request failed');
            }
          }
        });
  }

  @override
  void dispose() {
    super.dispose();
    player.release();
    _tabController.dispose();

    _autoRefreshTimer?.cancel();
    client.close();
  }

  void onChangeVideo(int curTabIdx, int curActiveIdx) {
    setState(() {
      _curTabIdx = curTabIdx;
      _curActiveIdx = curActiveIdx;
    });
  }

  // build
  Widget buildPlayDrawer() {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          primary: false,
          elevation: 0,
          title: TabBar(
            labelColor: Colors.black54,

            // labelStyle: const TextStyle(height: 25.0, color: Colors.black26),
            // unselectedLabelStyle: const TextStyle(height: 25.0, color: Colors.blue),
            tabs: _videoSourceTabs!.video!
                .map((e) => Tab(text: e!.name!))
                .toList(),
            isScrollable: true,
            controller: _tabController,
          ),
          bottom: PreferredSize(
            child: Container(
              color: Colors.grey[350],
              height: 1.0,
            ),
            preferredSize: const Size.fromHeight(100.0),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: TabBarView(
          controller: _tabController,
          children: createTabConList(),
        ),
      ),
    );
  }

  // camera item
  List<Widget> createTabConList() {
    List<Widget> list = [];
    _videoSourceTabs!.video!.asMap().keys.forEach((int tabIdx) {
      List<Widget> playListBtns = _videoSourceTabs!.video![tabIdx]!.list!
          .asMap()
          .keys
          .map((int activeIdx) {
        return Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              elevation: MaterialStateProperty.all(0),
              backgroundColor: MaterialStateProperty.all(
                  tabIdx == _curTabIdx && activeIdx == _curActiveIdx
                      ? Colors.red
                      : Colors.blue),
            ),
            onPressed: () async {
              setState(() {
                _curTabIdx = tabIdx;
                _curActiveIdx = activeIdx;
              });
              String nextVideoUrl =
              _videoSourceTabs!.video![tabIdx]!.list![activeIdx]!.url!;
              // switch resource
              if (player.value.state == FijkState.completed) {
                await player.stop();
              }
              await player.reset().then((_) async {
                player.setDataSource(nextVideoUrl, autoPlay: true);
              });
            },
            child: Text(
              _videoSourceTabs!.video![tabIdx]!.list![activeIdx]!.name!,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
      }).toList();
      //
      list.add(
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Wrap(
              direction: Axis.horizontal,
              children: playListBtns,
            ),
          ),
        ),
      );
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
          children: [
            FijkView(
              player: player,
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
                  onChangeVideo: onChangeVideo,
                  curTabIdx: _curTabIdx,
                  curActiveIdx: _curActiveIdx,
                  showConfig: vCfg,
                  videoFormat: _videoSourceTabs,
                );
              },
            ),
            Container(
              // alignment: Alignment.center,
              color: Colors.grey[300],
              height: 50,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Text(
                autoMessage,
                style: const TextStyle(color: Colors.blue),

              ),
            ),
            SizedBox(
              height: 200,
              child: buildPlayDrawer(),
            )
          ],
        )
    );
  }
}

class PlayerShowConfig implements ShowConfigAbs {
  @override
  bool drawerBtn = true;
  @override
  bool nextBtn = false;
  @override
  bool speedBtn = true;
  @override
  bool topBar = true;
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