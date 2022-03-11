// be noticed! The origin resource is [https://github.com/abcd498936590/fijkplayer_skin]
// get the copy with an original MIT license

// ignore_for_file: must_call_super, camel_case_types
import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';
import 'package:http/http.dart' as http;

import 'schema.dart' show VideoSourceFormat;
import 'slider.dart' show NewFijkSliderColors, NewFijkSlider;

double speed = 1.0;
bool lockStuff = false;
bool hideLockStuff = false;
const double barHeight = 50.0;
final double barFillingHeight = MediaQueryData.fromWindow(window).padding.top + barHeight;
final double barGap = barFillingHeight - barHeight;

abstract class ShowConfigAbs {
  late bool nextBtn;
  late bool speedBtn;
  late bool drawerBtn;
  late bool lockBtn;
  late bool topBar;
  late bool autoNext;
  late bool bottomPro;
  late bool stateAuto;
  late bool isAutoPlay;
}

class WithPlayerChangeSource {}

String _duration2String(Duration duration) {
  if (duration.inMilliseconds < 0) return "-: negtive";

  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  int inHours = duration.inHours;
  return inHours > 0
      ? "$inHours:$twoDigitMinutes:$twoDigitSeconds"
      : "$twoDigitMinutes:$twoDigitSeconds";
}

class CustomFijkPanel extends StatefulWidget {
  final FijkPlayer player;
  final Size viewSize;
  final Rect texturePos;
  final BuildContext? pageContent;
  final String playerTitle;
  final Function? onChangeVideo;
  final int curTabIdx;
  final int curActiveIdx;
  final ShowConfigAbs showConfig;
  final VideoSourceFormat? videoFormat;

  CustomFijkPanel({
    required this.player,
    required this.viewSize,
    required this.texturePos,
    this.pageContent,
    this.playerTitle = "",
    required this.showConfig,
    this.onChangeVideo,
    required this.videoFormat,
    required this.curTabIdx,
    required this.curActiveIdx,
  });

  @override
  _CustomFijkPanelState createState() => _CustomFijkPanelState();
}

class _CustomFijkPanelState extends State<CustomFijkPanel>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  FijkPlayer get player => widget.player;
  ShowConfigAbs get showConfig => widget.showConfig;
  VideoSourceFormat get _videoSourceTabs => widget.videoFormat!;

  bool _lockStuff = lockStuff;
  bool _hideLockStuff = hideLockStuff;
  bool _drawerState = false;
  Timer? _hideLockTimer;

  FijkState? _playerState;
  bool _isPlaying = false;

  StreamSubscription? _currentPosSubs;

  AnimationController? _animationController;
  Animation<Offset>? _animation;
  late TabController _tabController;

  void initEvent() {
    _tabController = TabController(
      length: _videoSourceTabs.video!.length,
      vsync: this,
    );
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    // init animation
    _animation = Tween(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(_animationController!);
    // is not null
    if (_videoSourceTabs.video!.isEmpty) return;
    // init player state
    setState(() {
      _playerState = player.value.state;
    });
    if (player.value.duration.inMilliseconds > 0 && !_isPlaying) {
      setState(() {
        _isPlaying = true;
      });
    }
    // is not null
    if (_videoSourceTabs.video!.isEmpty) return;
    // autoplay and exist url
    if (showConfig.isAutoPlay && !_isPlaying) {
      int curTabIdx = widget.curTabIdx;
      int curActiveIdx = widget.curActiveIdx;
      changeCurPlayVideo(curTabIdx, curActiveIdx);
    }
    player.addListener(_playerValueChanged);
    Wakelock.enable();
  }

  @override
  void initState() {
    super.initState();
    initEvent();
  }

  @override
  void dispose() {
    _currentPosSubs?.cancel();
    _hideLockTimer?.cancel();
    player.removeListener(_playerValueChanged);
    _tabController.dispose();
    _animationController!.dispose();
    Wakelock.disable();
    super.dispose();
  }

  // Get the sate of the player
  void _playerValueChanged() {
    if (player.value.duration.inMilliseconds > 0 && !_isPlaying) {
      setState(() {
        _isPlaying = true;
      });
    }
    setState(() {
      _playerState = player.value.state;
    });
  }

  // Switch the UI(the play list state)
  void changeDrawerState(bool state) {
    if (state) {
      setState(() {
        _drawerState = state;
      });
    }
    Future.delayed(const Duration(milliseconds: 100), () {
      _animationController!.forward();
    });
  }

  // Switch the UI(the lock icon state)
  void changeLockState(bool state) {
    setState(() {
      _lockStuff = state;
      if (state == true) {
        _hideLockStuff = true;
        _cancelAndRestartLockTimer();
      }
    });
  }

  // switch the resource
  Future<void> changeCurPlayVideo(int tabIdx, int activeIdx) async {
    // await player.stop();
    await player.reset().then((_) {
      String curTabActiveUrl =
      _videoSourceTabs.video![tabIdx]!.list![activeIdx]!.url!;
      player.setDataSource(
        curTabActiveUrl,
        autoPlay: true,
      );
      // callback
      widget.onChangeVideo!(tabIdx, activeIdx);
    });
  }

  void _cancelAndRestartLockTimer() {
    if (_hideLockStuff == true) {
      _startHideLockTimer();
    }
    setState(() {
      _hideLockStuff = !_hideLockStuff;
    });
  }

  void _startHideLockTimer() {
    _hideLockTimer?.cancel();
    _hideLockTimer = Timer(const Duration(seconds: 5), () {
      setState(() {
        _hideLockStuff = true;
      });
    });
  }

  // the lock
  Widget _buidLockStateDetctor() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _cancelAndRestartLockTimer,
      child: AnimatedOpacity(
        opacity: _hideLockStuff ? 0.0 : 0.7,
        duration: const Duration(milliseconds: 400),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              top: showConfig.stateAuto && !player.value.fullScreen
                  ? barGap
                  : 0,
            ),
            child: IconButton(
              iconSize: 30,
              onPressed: () {
                setState(() {
                  _lockStuff = false;
                  _hideLockStuff = true;
                });
              },
              icon: const Icon(Icons.lock_outline),
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // back icon
  Widget _buildTopBackBtn() {
    return Container(
      height: barHeight,
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        padding: const EdgeInsets.only(
          left: 10.0,
          right: 10.0,
        ),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        color: Colors.white,
        onPressed: () {
          // exit from the full screen
          if (widget.player.value.fullScreen) {
            player.exitFullScreen();
          } else {
            if (widget.pageContent == null) return;
            player.stop();
            Navigator.pop(widget.pageContent!);
          }
        },
      ),
    );
  }

  // the resource group list
  Widget _buildPlayerListDrawer() {
    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                await _animationController!.reverse();
                setState(() {
                  _drawerState = false;
                });
              },
            ),
          ),
          SlideTransition(
            position: _animation!,
            child: SizedBox(
              height: window.physicalSize.height,
              width: 320,
              child: _buildPlayDrawer(),
            ),
          ),
        ],
      ),
    );
  }

  // the resource group
  Widget _buildPlayDrawer() {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 0.4),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5),
        automaticallyImplyLeading: false,
        elevation: 0.1,
        title: TabBar(
          labelColor: Colors.white,
          labelStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          unselectedLabelColor: Colors.white,
          unselectedLabelStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          indicator: BoxDecoration(
            color: Colors.purple[700],
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          tabs:
          _videoSourceTabs.video!.map((e) => Tab(text: e!.name!)).toList(),
          isScrollable: true,
          controller: _tabController,
        ),
      ),
      body: Container(
        color: const Color.fromRGBO(0, 0, 0, 0.5),
        child: TabBarView(
          controller: _tabController,
          children: _createTabConList(),
        ),
      ),
    );
  }

  // the media list
  List<Widget> _createTabConList() {
    List<Widget> list = [];
    _videoSourceTabs.video!.asMap().keys.forEach((int tabIdx) {
      List<Widget> playListBtns = _videoSourceTabs.video![tabIdx]!.list!
          .asMap()
          .keys
          .map((int activeIdx) {
        return Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              elevation: MaterialStateProperty.all(0),
              backgroundColor: MaterialStateProperty.all(
                  tabIdx == widget.curTabIdx && activeIdx == widget.curActiveIdx
                      ? Colors.red
                      : Colors.blue),
            ),
            onPressed: () {
              int newTabIdx = tabIdx;
              int newActiveIdx = activeIdx;
              // switch the resource
              changeCurPlayVideo(newTabIdx, newActiveIdx);
            },
            child: Text(
              _videoSourceTabs.video![tabIdx]!.list![activeIdx]!.name!,
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

  // the common widget for loading/error/idle...
  Widget _buildPublicFrameWidget({
    required Widget slot,
    Color? bgColor,
  }) {
    return Container(
      color: bgColor,
      child: Stack(
        children: [
          showConfig.topBar && widget.player.value.fullScreen
              ? Positioned(
            left: 0,
            top: 0,
            right: 0,
            child: Container(
              height:
              showConfig.stateAuto && !widget.player.value.fullScreen
                  ? barFillingHeight
                  : barHeight,
              alignment: Alignment.bottomLeft,
              child: Container(
                height: barHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    _buildTopBackBtn(),
                    Expanded(
                      child: Container(
                        child: Text(
                          widget.playerTitle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              : Container(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 0,
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(
                    top: showConfig.stateAuto && !widget.player.value.fullScreen
                        ? barGap
                        : 0),
                child: slot,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // error slot
  Widget _buildErrorStateSlotWidget() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: showConfig.stateAuto && !widget.player.value.fullScreen
                ? barGap
                : 0,
          ),
          // error icon
          const Icon(
            Icons.error,
            size: 50,
            color: Colors.white,
          ),
          // error message
          const Text(
            "Play failed，Tap to try again！",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          // retry
          ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              elevation: MaterialStateProperty.all(0),
              backgroundColor: MaterialStateProperty.all(Colors.white),
            ),
            onPressed: () {
              // switch the resource
              changeCurPlayVideo(widget.curTabIdx, widget.curActiveIdx);
            },
            child: const Text(
              "Tap to try again",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // loading slot
  Widget _buildLoadingStateSlotWidget() {
    return const SizedBox(
      width: barHeight * 0.8,
      height: barHeight * 0.8,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.white),
      ),
    );
  }

  // idle slot
  Widget _buildIdleStateSlotWidget() {
    return IconButton(
      iconSize: barHeight * 1.2,
      icon: const Icon(Icons.play_arrow, color: Colors.white),
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      onPressed: () async {
        int newTabIdx = widget.curTabIdx;
        int newActiveIdx = widget.curActiveIdx;
        await changeCurPlayVideo(newTabIdx, newActiveIdx);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Rect rect = player.value.fullScreen
        ? Rect.fromLTWH(
      0,
      0,
      widget.viewSize.width,
      widget.viewSize.height,
    )
        : Rect.fromLTRB(
      max(0.0, widget.texturePos.left),
      max(0.0, widget.texturePos.top),
      min(widget.viewSize.width, widget.texturePos.right),
      min(widget.viewSize.height, widget.texturePos.bottom),
    );

    List<Widget> ws = [];

    if (_playerState == FijkState.error) {
      ws.add(
        _buildPublicFrameWidget(
          slot: _buildErrorStateSlotWidget(),
          bgColor: Colors.black,
        ),
      );
    } else if ((_playerState == FijkState.asyncPreparing ||
        _playerState == FijkState.initialized) &&
        !_isPlaying) {
      ws.add(
        _buildPublicFrameWidget(
          slot: _buildLoadingStateSlotWidget(),
          bgColor: Colors.black,
        ),
      );
    } else if (_playerState == FijkState.idle && !_isPlaying) {
      ws.add(
        _buildPublicFrameWidget(
          slot: _buildIdleStateSlotWidget(),
          bgColor: Colors.black,
        ),
      );
    } else {
      if (_lockStuff == true &&
          showConfig.lockBtn &&
          widget.player.value.fullScreen) {
        ws.add(
          _buidLockStateDetctor(),
        );
      } else if (_drawerState == true && widget.player.value.fullScreen) {
        ws.add(
          _buildPlayerListDrawer(),
        );
      } else {
        ws.add(
          _buildGestureDetector(
            curActiveIdx: widget.curActiveIdx,
            curTabIdx: widget.curTabIdx,
            onChangeVideo: widget.onChangeVideo,
            player: widget.player,
            texturePos: widget.texturePos,
            showConfig: widget.showConfig,
            pageContent: widget.pageContent,
            playerTitle: widget.playerTitle,
            viewSize: widget.viewSize,
            videoFormat: widget.videoFormat,
            changeDrawerState: changeDrawerState,
            changeLockState: changeLockState,
          ),
        );
      }
    }

    return WillPopScope(
      child: Positioned.fromRect(
        rect: rect,
        child: Stack(
          children: ws,
        ),
      ),
      onWillPop: () async {
        if (!widget.player.value.fullScreen) widget.player.stop();
        return true;
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _buildGestureDetector extends StatefulWidget {
  final FijkPlayer player;
  final Size viewSize;
  final Rect texturePos;
  final BuildContext? pageContent;
  final String playerTitle;
  final Function? onChangeVideo;
  final int curTabIdx;
  final int curActiveIdx;
  final Function changeDrawerState;
  final Function changeLockState;
  final ShowConfigAbs showConfig;
  final VideoSourceFormat? videoFormat;
  _buildGestureDetector({
    Key? key,
    required this.player,
    required this.viewSize,
    required this.texturePos,
    this.pageContent,
    this.playerTitle = "",
    required this.showConfig,
    this.onChangeVideo,
    required this.curTabIdx,
    required this.curActiveIdx,
    required this.videoFormat,
    required this.changeDrawerState,
    required this.changeLockState,
  }) : super(key: key);

  @override
  _buildGestureDetectorState createState() => _buildGestureDetectorState();
}

class _buildGestureDetectorState extends State<_buildGestureDetector> {
  FijkPlayer get player => widget.player;

  ShowConfigAbs get showConfig => widget.showConfig;

  VideoSourceFormat get _videoSourceTabs => widget.videoFormat!;

  Duration _duration = Duration();
  Duration _currentPos = Duration();
  Duration _bufferPos = Duration();

  // the value after seeking
  Duration _dargPos = Duration();

  bool _isTouch = false;

  bool _playing = false;
  bool _prepared = false;
  String? _exception;

  double? updatePrevDx;
  double? updatePrevDy;
  int? updatePosX;

  bool? isDargVerLeft;

  double? updateDargVarVal;

  bool varTouchInitSuc = false;

  bool _buffering = false;

  double _seekPos = -1.0;

  StreamSubscription? _currentPosSubs;
  StreamSubscription? _bufferPosSubs;
  StreamSubscription? _bufferingSubs;

  Timer? _hideTimer;
  bool _hideStuff = true;

  bool _hideSpeedStu = true;
  double _speed = speed;

  bool _isHorizontalMove = false;

  Map<String, double> speedList = {
    "2.0": 2.0,
    "1.8": 1.8,
    "1.5": 1.5,
    "1.2": 1.2,
    "1.0": 1.0,
  };

  Timer? _autoRefreshTimer;
  String autoMessage = "";
  http.Client client =  http.Client();

  // constructor
  _buildGestureDetectorState();

  void initEvent() {
    // init, will execute when enter or quit full screen
    setState(() {
      _speed = speed;
      // is playing
      _hideStuff = !_playing ? false : true;
    });
    // timer for hiding the other parts beyond the video screen
    _startHideTimer();

    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) async{
      if (widget.player.value.fullScreen && _hideStuff) {
        try{
          var response = await client.get(Uri.parse('https://geek-jokes.sameerkumar.website/api'));
          setState(() {
            autoMessage = response.body;
          });
        }
        finally{
          if(kDebugMode){
            print('http request failed');
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _hideTimer?.cancel();

    player.removeListener(_playerValueChanged);
    _currentPosSubs?.cancel();
    _bufferPosSubs?.cancel();
    _bufferingSubs?.cancel();
    _autoRefreshTimer?.cancel();
    client.close();
  }

  @override
  void initState() {
    super.initState();

    initEvent();

    _duration = player.value.duration;
    _currentPos = player.currentPos;
    _bufferPos = player.bufferPos;
    _prepared = player.state.index >= FijkState.prepared.index;
    _playing = player.state == FijkState.started;
    _exception = player.value.exception.message;
    _buffering = player.isBuffering;

    player.addListener(_playerValueChanged);

    _currentPosSubs = player.onCurrentPosUpdate.listen((v) {
      setState(() {
        _currentPos = v;
        // reset the state
        _playing = true;
        _prepared = true;
      });
    });

    _bufferPosSubs = player.onBufferPosUpdate.listen((v) {
      setState(() {
        _bufferPos = v;
      });
    });

    _bufferingSubs = player.onBufferStateUpdate.listen((v) {
      setState(() {
        _buffering = v;
      });
    });
  }

  void _playerValueChanged() async {
    FijkValue value = player.value;
    if (value.duration != _duration) {
      setState(() {
        _duration = value.duration;
      });
    }
    if (kDebugMode) {
      print(
          '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
      print('++++++++ Play started? => ${value.state ==
          FijkState.started} ++++++++');
      print('+++++++++++++++++++ The player\'s state => ${value
          .state} ++++++++++++++++++++');
      print(
          '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
    }
    // new state
    bool playing = value.state == FijkState.started;
    bool prepared = value.prepared;
    String? exception = value.exception.message;
    // update the state
    if (playing != _playing ||
        prepared != _prepared ||
        exception != _exception) {
      setState(() {
        _playing = playing;
        _prepared = prepared;
        _exception = exception;
      });
    }
    // when completed
    bool playend = (value.state == FijkState.completed);
    bool isOverFlow = widget.curActiveIdx + 1 >=
        _videoSourceTabs.video![widget.curTabIdx]!.list!.length;
    // completed && resource is available
    if (playend && !isOverFlow && showConfig.autoNext) {
      int newTabIdx = widget.curTabIdx;
      int newActiveIdx = widget.curActiveIdx + 1;
      widget.onChangeVideo!(newTabIdx, newActiveIdx);
      // switch the resource
      changeCurPlayVideo(newTabIdx, newActiveIdx);
    }
  }

  _onHorizontalDragStart(detills) {
    setState(() {
      updatePrevDx = detills.globalPosition.dx;
      updatePosX = _currentPos.inMilliseconds;
    });
  }

  _onHorizontalDragUpdate(detills) {
    double curDragDx = detills.globalPosition.dx;
    // check the drag is left or right
    int cdx = curDragDx.toInt();
    int pdx = updatePrevDx!.toInt();
    bool isBefore = cdx > pdx;

    // calculate the percent of the dragged length of the screen
    int newInterval = pdx - cdx;
    double playerW = MediaQuery
        .of(context)
        .size
        .width;
    int curIntervalAbs = newInterval.abs();
    double movePropCheck = (curIntervalAbs / playerW) * 100;

    // calculate the progress bar's percent
    double durProgCheck = _duration.inMilliseconds.toDouble() / 100;
    int checkTransfrom = (movePropCheck * durProgCheck).toInt();
    int dragRange = isBefore ? updatePosX! + checkTransfrom : updatePosX! -
        checkTransfrom;

    // check if is the destination out of range, when is, set to the end
    int lastSecond = _duration.inMilliseconds;
    if (dragRange >= _duration.inMilliseconds) {
      dragRange = lastSecond;
    }

    // check if is the destination less than 0, when is, set to the begin
    if (dragRange <= 0) {
      dragRange = 0;
    }
    //
    setState(() {
      _isHorizontalMove = true;
      _hideStuff = false;
      _isTouch = true;
      // record the position
      updatePrevDx = curDragDx;
      // update the playing position
      updatePosX = dragRange.toInt();
      _dargPos = Duration(milliseconds: updatePosX!.toInt());
    });
  }

  _onHorizontalDragEnd(detills) {
    player.seekTo(_dargPos.inMilliseconds);
    setState(() {
      _isHorizontalMove = false;
      _isTouch = false;
      _hideStuff = true;
      _currentPos = _dargPos;
    });
  }

  _onVerticalDragStart(detills) async {
    double clientW = widget.viewSize.width;
    double curTouchPosX = detills.globalPosition.dx;

    setState(() {
      // record the vertical position
      updatePrevDy = detills.globalPosition.dy;
      // check if is the drag position in the left screen
      isDargVerLeft = (curTouchPosX > (clientW / 2)) ? false : true;
    });
    // left: brightness; right: volume
    if (!isDargVerLeft!) {
      // volume
      await FijkVolume.getVol().then((double v) {
        varTouchInitSuc = true;
        setState(() {
          updateDargVarVal = v;
        });
      });
    } else {
      // brightness
      await FijkPlugin.screenBrightness().then((double v) {
        varTouchInitSuc = true;
        setState(() {
          updateDargVarVal = v;
        });
      });
    }
  }

  _onVerticalDragUpdate(detills) {
    if (!varTouchInitSuc) return null;
    double curDragDy = detills.globalPosition.dy;
    // check the drag is up or down
    int cdy = curDragDy.toInt();
    int pdy = updatePrevDy!.toInt();
    bool isBefore = cdy < pdy;
    // if the drag value less than 3, nothing happens
    if (isBefore && pdy - cdy < 3 || !isBefore && cdy - pdy < 3) return null;
    // calculate the position
    double dragRange = isBefore ? updateDargVarVal! + 0.03 : updateDargVarVal! -
        0.03;
    // is out of range?
    if (dragRange > 1) {
      dragRange = 1.0;
    }
    if (dragRange < 0) {
      dragRange = 0.0;
    }
    setState(() {
      updatePrevDy = curDragDy;
      varTouchInitSuc = true;
      updateDargVarVal = dragRange;
      // volume
      if (!isDargVerLeft!) {
        FijkVolume.setVol(dragRange);
      } else {
        FijkPlugin.setScreenBrightness(dragRange);
      }
    });
  }

  _onVerticalDragEnd(detills) {
    setState(() {
      varTouchInitSuc = false;
    });
  }

  // switch the resource
  Future<void> changeCurPlayVideo(int tabIdx, int activeIdx) async {
    // await player.seekTo(0);
    await player.stop();
    setState(() {
      _buffering = false;
    });
    player.reset().then((_) {
      _speed = speed = 1.0;
      String curTabActiveUrl =
      _videoSourceTabs.video![tabIdx]!.list![activeIdx]!.url!;
      player.setDataSource(
        curTabActiveUrl,
        autoPlay: true,
      );
      // callback
      widget.onChangeVideo!(tabIdx, activeIdx);
    });
  }

  void _playOrPause() {
    if (_playing == true) {
      player.pause();
    } else {
      player.start();
    }
  }

  void _cancelAndRestartTimer() {
    if (_hideStuff == true) {
      _startHideTimer();
    }

    setState(() {
      _hideStuff = !_hideStuff;
      if (_hideStuff == true) {
        _hideSpeedStu = true;
      }
    });
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      setState(() {
        _hideStuff = true;
        _hideSpeedStu = true;
      });
    });
  }

  // bottom controller - play button
  Widget _buildPlayStateBtn(IconData iconData, Function cb) {
    return Ink(
      child: InkWell(
        onTap: () => cb(),
        child: SizedBox(
          height: 30,
          child: Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Icon(
              iconData,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // Bottom bar
  Widget _buildBottomBar(BuildContext context) {
    // calculate the time has been played
    double duration = _duration.inMilliseconds.toDouble();
    double currentValue = _seekPos > 0
        ? _seekPos
        : (_isHorizontalMove
        ? _dargPos.inMilliseconds.toDouble()
        : _currentPos.inMilliseconds.toDouble());
    currentValue = min(currentValue, duration);
    currentValue = max(currentValue, 0);

    // calculate the bottom progress bar position
    double curConWidth = MediaQuery
        .of(context)
        .size
        .width;
    double curTimePro = (currentValue / duration) * 100;
    double curBottomProW = (curConWidth / 100) * curTimePro;

    return SizedBox(
      height: barHeight,
      child: Stack(
        children: [
          // bottom ui controller
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedOpacity(
              opacity: _hideStuff ? 0.0 : 0.8,
              duration: const Duration(milliseconds: 400),
              child: Container(
                height: barHeight,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color.fromRGBO(0, 0, 0, 0),
                      Color.fromRGBO(0, 0, 0, 0.4),
                    ],
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    const SizedBox(width: 7),
                    // button - play/pause
                    _buildPlayStateBtn(
                      _playing ? Icons.pause : Icons.play_arrow,
                      _playOrPause,
                    ),
                    // next video
                    showConfig.nextBtn
                        ? _buildPlayStateBtn(
                      Icons.skip_next,
                          () {
                        bool isOverFlow = widget.curActiveIdx + 1 >=
                            _videoSourceTabs.video![widget.curTabIdx]!.list!
                                .length;
                        // video is available
                        if (!isOverFlow) {
                          int newTabIdx = widget.curTabIdx;
                          int newActiveIdx = widget.curActiveIdx + 1;
                          // switch resource
                          changeCurPlayVideo(newTabIdx, newActiveIdx);
                        }
                      },
                    )
                        : Container(),
                    // the time has been played
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0, left: 5),
                      child: Text(
                        _duration2String(_currentPos),
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // progress bar
                    _duration.inMilliseconds == 0
                        ? Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5, left: 5),
                        child: NewFijkSlider(
                          colors: const NewFijkSliderColors(
                            cursorColor: Colors.blue,
                            playedColor: Colors.blue,
                          ),
                          onChangeEnd: (double value) {},
                          value: 0,
                          onChanged: (double value) {},
                        ),
                      ),
                    )
                        : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5, left: 5),
                        child: NewFijkSlider(
                          colors: const NewFijkSliderColors(
                            cursorColor: Colors.blue,
                            playedColor: Colors.blue,
                          ),
                          value: currentValue,
                          cacheValue:
                          _bufferPos.inMilliseconds.toDouble(),
                          min: 0.0,
                          max: duration,
                          onChanged: (v) {
                            _startHideTimer();
                            setState(() {
                              _seekPos = v;
                            });
                          },
                          onChangeEnd: (v) {
                            setState(() {
                              player.seekTo(v.toInt());
                              if (kDebugMode) {
                                print("seek to $v");
                              }
                              _currentPos = Duration(
                                  milliseconds: _seekPos.toInt());
                              _seekPos = -1;
                            });
                          },
                        ),
                      ),
                    ),

                    // the total time
                    _duration.inMilliseconds == 0
                        ? const Text(
                      "00:00",
                      style: TextStyle(color: Colors.white),
                    )
                        : Padding(
                      padding: const EdgeInsets.only(right: 5.0, left: 5),
                      child: Text(
                        _duration2String(_duration),
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // video button
                    widget.player.value.fullScreen && showConfig.drawerBtn
                        ? Ink(
                      padding: const EdgeInsets.all(5),
                      child: InkWell(
                        onTap: () {
                          // call the parent widget's callback
                          widget.changeDrawerState(true);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 40,
                          height: 30,
                          child: const Text(
                            "Video",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                        : Container(),
                    // speed button
                    widget.player.value.fullScreen && showConfig.speedBtn
                        ? Ink(
                      padding: const EdgeInsets.all(5),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _hideSpeedStu = !_hideSpeedStu;
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 40,
                          height: 30,
                          child: Text(
                            _speed.toString() + " X",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                        : Container(),
                    // button - fullscreen/quit fullscreen
                    _buildPlayStateBtn(
                      widget.player.value.fullScreen
                          ? Icons.fullscreen_exit
                          : Icons.fullscreen,
                          () {
                        if (widget.player.value.fullScreen) {
                          player.exitFullScreen();
                        } else {
                          player.enterFullScreen();
                          // call the parent widget's callback
                          widget.changeDrawerState(false);
                        }
                      },
                    ),
                    const SizedBox(width: 7),
                    //
                  ],
                ),
              ),
            ),
          ),
          // the bottom progressbar, show when the other's uis disappear
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: showConfig.bottomPro &&
                _hideStuff &&
                _duration.inMilliseconds != 0
                ? Container(
              alignment: Alignment.bottomLeft,
              height: 4,
              color: Colors.white70,
              child: Container(
                color: Colors.blue,
                width: curBottomProW,
                height: 4,
              ),
            )
                : Container(),
          )
        ],
      ),
    );
  }

  // back button
  Widget _buildTopBackBtn() {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10.0,
      ),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      color: Colors.white,
      onPressed: () {
        // if it is fullscreen
        if (widget.player.value.fullScreen) {
          player.exitFullScreen();
        } else {
          if (widget.pageContent == null) return;
          player.stop();
          Navigator.pop(widget.pageContent!);
        }
      },
    );
  }

  //  the back icon and title in the player's top
  Widget _buildTopBar() {
    return AnimatedOpacity(
      opacity: _hideStuff ? 0.0 : 0.8,
      duration: const Duration(milliseconds: 400),
      child: Container(
        height: showConfig.stateAuto && !widget.player.value.fullScreen
            ? barFillingHeight
            : barHeight,
        alignment: Alignment.bottomLeft,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomLeft,
            colors: [
              Color.fromRGBO(0, 0, 0, 0.5),
              Color.fromRGBO(0, 0, 0, 0),
            ],
          ),
        ),
        child: SizedBox(
          height: barHeight,
          child: Row(
            children: <Widget>[
              _buildTopBackBtn(),
              Expanded(
                child: Text(
                  widget.playerTitle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // the play button in the middle of the player
  Widget _buildCenterPlayBtn() {
    return Container(
      color: Colors.transparent,
      height: double.infinity,
      width: double.infinity,
      child: Center(
        child: (_prepared && !_buffering)
            ? AnimatedOpacity(
          opacity: _hideStuff ? 0.0 : 0.7,
          duration: const Duration(milliseconds: 400),
          child: IconButton(
            iconSize: barHeight * 1.2,
            icon: Icon(_playing ? Icons.pause : Icons.play_arrow,
                color: Colors.white),
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            onPressed: _playOrPause,
          ),
        )
            : const SizedBox(
          width: barHeight * 0.8,
          height: barHeight * 0.8,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        ),
      ),
    );
  }

  // build the timer view
  Widget _buildDargProgressTime() {
    return _isTouch
        ? Container(
      height: 40,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
        color: Color.fromRGBO(0, 0, 0, 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Text(
          '${_duration2String(_dargPos)} / ${_duration2String(_duration)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    )
        : Container();
  }

  // show the brightness/volume controller
  Widget _buildDargVolumeAndBrightness() {
    // do not show up
    if (!varTouchInitSuc) return Container();

    IconData iconData;
    // according the drag position value, determine the icon
    if (updateDargVarVal! <= 0) {
      iconData = !isDargVerLeft! ? Icons.volume_mute : Icons.brightness_low;
    } else if (updateDargVarVal! < 0.5) {
      iconData = !isDargVerLeft! ? Icons.volume_down : Icons.brightness_medium;
    } else {
      iconData = !isDargVerLeft! ? Icons.volume_up : Icons.brightness_high;
    }
    // brightness/volume controller
    return Card(
      color: const Color.fromRGBO(0, 0, 0, 0.8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              iconData,
              color: Colors.white,
            ),
            Container(
              width: 100,
              height: 3,
              margin: const EdgeInsets.only(left: 8),
              child: LinearProgressIndicator(
                value: updateDargVarVal,
                backgroundColor: Colors.white54,
                valueColor: const AlwaysStoppedAnimation(Colors.lightBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // speed selection list
  List<Widget> _buildSpeedListWidget() {
    List<Widget> columnChild = [];
    speedList.forEach((String mapKey, double speedVals) {
      columnChild.add(
        Ink(
          child: InkWell(
            onTap: () {
              if (_speed == speedVals) return;
              setState(() {
                _speed = speed = speedVals;
                _hideSpeedStu = true;
                player.setSpeed(speedVals);
              });
            },
            child: Container(
              alignment: Alignment.center,
              width: 50,
              height: 30,
              child: Text(
                mapKey + " X",
                style: TextStyle(
                  color: _speed == speedVals ? Colors.blue : Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      );
      columnChild.add(
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: Container(
            width: 50,
            height: 1,
            color: Colors.white54,
          ),
        ),
      );
    });
    columnChild.removeAt(columnChild.length - 1);
    return columnChild;
  }

  // the player's controller ui
  Widget _buildGestureDetector() {
    return GestureDetector(
      onTap: _cancelAndRestartTimer,
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: AbsorbPointer(
        absorbing: _hideStuff,
        child: Column(
          children: <Widget>[
            // the controller in the player's top
            showConfig.topBar && widget.player.value.fullScreen
                ? _buildTopBar()
                : Container(
              height:
              showConfig.stateAuto && !widget.player.value.fullScreen
                  ? barFillingHeight
                  : barHeight,
            ),
            // middle icons
            Expanded(
              child: Stack(
                children: <Widget>[
                  // the top
                  Positioned(
                    top: widget.player.value.fullScreen ? 20 : 0,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // the progress bar when drag left or right
                        _buildDargProgressTime(),
                        // the controller brightness/volume when drag up or down
                        _buildDargVolumeAndBrightness()
                      ],
                    ),
                  ),
                  // the play button at center
                  Align(
                    alignment: Alignment.center,
                    child: _buildCenterPlayBtn(),
                  ),
                  // the speed selection
                  Positioned(
                    right: 35,
                    bottom: 0,
                    child: !_hideSpeedStu
                        ? Container(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: _buildSpeedListWidget(),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    )
                        : Container(),
                  ),
                  // the lock icon
                  showConfig.lockBtn && widget.player.value.fullScreen
                      ? Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedOpacity(
                      opacity: _hideStuff ? 0.0 : 0.7,
                      duration: const Duration(milliseconds: 400),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: IconButton(
                          iconSize: 30,
                          onPressed: () {
                            // change the lock icon and the player's state
                            widget.changeLockState(true);
                          },
                          icon: const Icon(Icons.lock_open),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                      : Container(),
                ],
              ),
            ),
            _buildMessageArea(),
            // bottom play controllers
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildGestureDetector();
  }

  //  the message to display up on video
  Widget _buildMessageArea() {
    return widget.player.value.fullScreen ?
    AnimatedOpacity(
      opacity: _hideStuff ? 0.8 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: Container(
        height: barHeight,
        alignment: Alignment.bottomLeft,
        child: SizedBox(
          height: barHeight,
          child: Row(
            children: [
              const SizedBox(width: 30,),
              Expanded(
                child: Text(
                  autoMessage,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ) :
    Container();
  }
}