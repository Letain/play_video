import 'package:flutter/material.dart';

import 'demo.dart';
import 'dto/demoNavigatorParameter.dart';

class CameraParameterInputWidget extends StatefulWidget {

  // final DemoNavigatorParameter? parameter;
  //
  // CameraParameterInputWidget({this.parameter});

  @override
  _CameraParameterInputWidgetState createState() => _CameraParameterInputWidgetState();
}

class _CameraParameterInputWidgetState extends State<CameraParameterInputWidget> {

  var textController1 = TextEditingController();
  var textController2 = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    textController1.dispose();
    textController2.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Camera情報入力"),
      ),
      body: Column(
        children: [
          const Text("Camera List Get Url(Optional)"),
          TextField(
            maxLines: 1,
            controller: textController1,
          ),
          const Text("Person Info Get Url(Optional)"),
          TextField(
            maxLines: 1,
            controller: textController2,
          ),
          TextButton(
              onPressed: () {
                _playDemo(context);
              },
              child: const Text("Play")
          )
        ],
      ),
    );
  }

  void _playDemo(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
      return Scaffold(
        appBar: AppBar(
          title: const Text('Demo'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ),
        body: DemoPlayer(title: 'Demo', parameter: DemoNavigatorParameter(cameraListUrl: textController1.text, cameraPersonInfoUrl: textController2.text) ),
      );
    }));
  }
}