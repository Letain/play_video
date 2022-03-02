import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class FlutterVlcPlayerApp extends StatelessWidget {
  const FlutterVlcPlayerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterVlcPlayer',
      theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
      home: VlcPlayerWidget(),
    );
  }
}


class VlcPlayerWidget extends StatefulWidget {
  const VlcPlayerWidget({Key? key}) : super(key: key);

  @override
  _VlcPlayerWidget createState() => _VlcPlayerWidget();
}

class _VlcPlayerWidget extends State<VlcPlayerWidget> {
  late VlcPlayerController _player;

  Future<void> initializePlayer() async {}

  @override
  void initState() {
    super.initState();

    _player = VlcPlayerController.network(
      // 'https://media.w3.org/2010/05/sintel/trailer.mp4',
      'rtsp://root:secom000@192.168.1.86:554/live1s1.sdp',
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(rtp: VlcRtpOptions([VlcRtpOptions.rtpOverRtsp(true)])),
      // options: VlcPlayerOptions(),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    await _player.stopRendererScanning();
    await _player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: VlcPlayer(
          controller: _player,
          aspectRatio: 16/9,
          placeholder: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}