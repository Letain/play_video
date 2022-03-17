import 'package:flutter/material.dart';

import 'demoInput.dart';
import 'playLocal.dart';
import 'fijkPlayer.dart';
import 'rtspFijkPlayer.dart';
import 'rtspFlutterVlc.dart';
import 'demo.dart';

// void main() => runApp(VideoApp());

// void main() => runApp(MaterialApp(title: 'demo', home: MyHomePage(title: 'FijkPlayer',),));
//void main() => runApp(MaterialApp(title: 'demo', home: RtspFijkPlayer(title: 'FijkPlayer',),));

// void main() => runApp(const FlutterVlcPlayerApp());

void main() => runApp(const TopWidget());

class TopWidget extends StatelessWidget {
  const TopWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Play video',
      home: TopScreen()
    );
  }

}

class TopScreen extends StatelessWidget{
  const TopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                _playRtsp(context);
              },
              child: const Text('Play RTSP')
            ),
            TextButton(
              onPressed: () {
                _playOthers(context);
              },
              child: const Text('Play Others')
            ),
            TextButton(
              onPressed: () {
                _playDemo(context);
              },
              child: Text('Play Demo', style: TextStyle(color: Colors.red[300], fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  void _playRtsp(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
      return Scaffold(
        appBar: AppBar(
          title: const Text('RTSP'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ),
        body: RtspFijkPlayer(title: 'FijkPlayer',),
      );
    }));
  }

  void _playOthers(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
      return Scaffold(
        appBar: AppBar(
          title: const Text('OTHERS'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ),
        body: MyHomePage(title: 'FijkPlayer',),
      );
    }));
  }

  void _playDemo(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
      // return Scaffold(
      //   appBar: AppBar(
      //     title: const Text('Demo'),
      //     leading: IconButton(
      //       icon: const Icon(Icons.arrow_back),
      //       onPressed: (){
      //         Navigator.pop(context);
      //       },
      //     ),
      //   ),
      //   body: DemoPlayer(title: 'Demo',),
      // );
      return CameraParameterInputWidget();
    }));
  }
}