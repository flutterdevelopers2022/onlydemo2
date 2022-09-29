import 'dart:io';
import 'dart:math';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:share_plus/share_plus.dart';
void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey _globalKey = GlobalKey();

  Future<Uint8List> _capturePng() async {
    var pngBytes;
    try {
      print('inside');
      RenderRepaintBoundary boundary =
      _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
     pngBytes = byteData!.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes);
    //  print(pngBytes);
    //  print(bs64);
      setState(() {});
    } catch (e) {
      print(e);
    }
    return pngBytes;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_permission();
    print("Hello good morning");

  }
  get_permission()
  async {
    var status = await Permission.storage.status;
    if(status.isDenied){
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      print(statuses[Permission.storage]);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          RepaintBoundary(child: Container(
            width: double.infinity,
            height: 200,
            alignment: Alignment.center,
            color: Colors.red,
            child: Text(
              "Hello this is tesring share file",
              style: TextStyle(fontSize: 30, color: Colors.white),
            ),
          ),key: _globalKey,),
          ElevatedButton(onPressed: () {
            Uint8List uniList;
         _capturePng().then((value) async {
           uniList=value;
           print(uniList);

           var path=await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS)+"/creative";
          Directory dir=Directory(path);
          if(!await dir.exists()){
           await dir.create();
          }
          int r=Random().nextInt(1000);
          String img_name="img$r.jpg";
          File file=File("${dir.path}/$img_name");
         await file.writeAsBytes(uniList);
          print("ImagePath:${file.path}");
           Share.shareFiles(['${file.path}'], text: 'Great picture');
         });
          }, child: Text("Share"))
        ],
      )),
    );
  }
}
