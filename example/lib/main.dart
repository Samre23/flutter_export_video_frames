import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_export_video_frames/flutter_export_video_frames.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Plugin Example App",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(images: <Image>[]),
    );
  }
}

class ImageItem extends StatelessWidget {
  ImageItem({required this.image});
  final Image image;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: image
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required this.images});

  final List<Image> images;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _isClean = false;
  Future _getImages() async {
    var file = await ImagePicker.pickVideo(source: ImageSource.gallery);
    var images = await ExportVideoFrame.exportImage(file.path,10,0);
    var result = images.map((file) => Image.file(file)).toList();
    setState(() {
      widget.images.addAll(result);
      _isClean = true;
    });
  }

  Future _getGifImages() async {
    var file = await ImagePicker.pickImage(source: ImageSource.gallery);
    var images = await ExportVideoFrame.exportGifImage(file.path,0);
    var result = images.map((file) => Image.file(file)).toList();
    setState(() {
      widget.images.addAll(result);
      _isClean = true;
    });
  }

  Future _getImagesByDuration() async {
    var file = await ImagePicker.pickVideo(source: ImageSource.gallery);
    var duration = Duration(seconds: 1);
    var image = await ExportVideoFrame.exportImageBySeconds(file, duration,pi/2);
    setState(() {
      widget.images.add(Image.file(image));
      _isClean = true;
    });
    await ExportVideoFrame.saveImage(image, "Video Export Demo",waterMark: "images/water_mark.png",alignment: Alignment.bottomLeft,scale: 2.0);
  }

  Future _cleanCache() async {
    var result = await ExportVideoFrame.cleanImageCache();
    print(result);
    setState(() {
      widget.images.clear();
      _isClean = false;
    });
  }

  Future _handleClickFirst() async {
    if (_isClean) {
      await _cleanCache();
    } else {
      await _getImages();
    }
  }

  Future _handleClickSecond() async {
    if (_isClean) {
      await _cleanCache();
    } else {
      await _getImagesByDuration();
    }
  }

  Future _handleClickThird() async {
    if (_isClean) {
      await _cleanCache();
    } else {
      await _getGifImages();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Export Image"),
      ),
      body: Container(
        padding: EdgeInsets.zero,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child:
              GridView.extent(
                  maxCrossAxisExtent: 400,
                  childAspectRatio: 1.0,
                  padding: const EdgeInsets.all(4),
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  children: widget.images.length > 0 ? widget.images.map((image) => ImageItem(image:image)).toList() : [Container()]
              ),
            ),
            Expanded(
              flex: 0,
              child: Center(
                child: MaterialButton(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  height: 40,
                  minWidth: 100,
                  onPressed: () {
                    _handleClickFirst();
                  },
                  color: Colors.orange,
                  child: Text(_isClean ? "Clean" : "Export image list"),
                ),
              ),
            ),
            Expanded(
              flex: 0,
              child: Center(
                child: MaterialButton(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  height: 40,
                  minWidth: 150,
                  onPressed: () {
                    _handleClickSecond();
                  },
                  color: Colors.orange,
                  child: Text(_isClean ? "Clean" : "Export one image and save"),
                ),
              ),
            ),
            Expanded(
              flex: 0,
              child: Center(
                child: MaterialButton(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  height: 40,
                  minWidth: 150,
                  onPressed: () {
                    _handleClickThird();
                  },
                  color: Colors.orange,
                  child: Text(_isClean ? "Clean" : "Export gif image"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
