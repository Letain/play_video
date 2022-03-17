import 'package:flutter/cupertino.dart';
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
          const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
          const Text("Camera List Get Url"),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child:
              TextField(
                maxLines: 1,
                controller: textController1,
              )),
          // const Text("Person Info Get Url(Optional)"),
          // TextField(
          //   maxLines: 1,
          //   controller: textController2,
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  elevation: MaterialStateProperty.all(0),
                  backgroundColor: MaterialStateProperty.all(Colors.lightBlue),
                ),
                onPressed: () {
                  _playDemo(context);
                },

                child: const Text("Play", style: TextStyle(fontSize: 26, color: Colors.white),)
            ),)
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
        body: DemoPlayer(title: 'Demo', parameter: DemoNavigatorParameter(cameraListUrl: textController1.text) ),
      );
    }));
  }
}