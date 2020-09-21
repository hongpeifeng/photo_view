
import 'dart:io';
import 'dart:typed_data';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';

class VideoView extends StatefulWidget {

  final String id;
  final String videoUrl;
  final String thumbUrl;
  final double thumbWidth;
  final double thumbHeight;
  final Widget placeHolder; // video 背景视图

  final Map<String, String> headers;
  /// 从缓存取出图片
  /// param url
  final Future<File> Function(String) getFileFromCache;

  /// 保存图片到缓存中
  /// param1: url
  /// param2: fileBytes
  final Future<File> Function(String, Uint8List) saveFileToCache;

  VideoView({
    this.id,
    this.thumbUrl,
    this.videoUrl,
    this.thumbWidth,
    this.thumbHeight,
    this.placeHolder,
    this.headers,
    this.getFileFromCache,
    this.saveFileToCache
  });

  @override
  _VideoViewState createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {

  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;

  static final HttpClient client = HttpClient()..autoUncompress = false;

  init () async {
    var videoFile = await widget.getFileFromCache?.call(widget.videoUrl);
    print(widget.videoUrl);
    if (videoFile == null) {
      final Uri resolved = Uri.base.resolve(widget.videoUrl);
      final HttpClientRequest request = await client.getUrl(resolved);
      widget.headers?.forEach((String name, String value) {
        request.headers.add(name, value);
      });
      final HttpClientResponse response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw Exception('can not get video');
      }

      final Uint8List bytes = await consolidateHttpClientResponseBytes(response);
      // 保存到缓存中，同时返回
      var videoFile = await widget.saveFileToCache?.call(widget.videoUrl,bytes);
      if (videoFile == null)  // 如果没有设置缓存函数的话
        throw Exception('could not save video');
    }
    _videoPlayerController = VideoPlayerController.file(videoFile);
    setState(() {
      _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          aspectRatio: widget.thumbWidth / widget.thumbHeight,
          showControls: true,
          showControlsOnInitialize: false,
          autoInitialize: true,
          allowFullScreen: false,
          allowMuting: false,
          placeholder: _placeholder());
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VideoView oldWidget) {
    // TODO: implement didUpdateWidget
    if (_videoPlayerController?.value?.isPlaying ?? false)
      _videoPlayerController.pause();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  _placeholder() {
    return Center(
      child: widget.placeHolder ?? Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){},
      child: Hero(
        tag: widget.id,
        child: Stack(
          children: <Widget>[
            _chewieController == null ? _placeholder() :
            Stack(children: <Widget>[
              Chewie(controller: _chewieController),
              ValueListenableBuilder(
                valueListenable: _videoPlayerController,
                builder: (context,VideoPlayerValue value,_) {
                  return value.isPlaying ? Container() : GestureDetector(
                    onTap: () async{
                      await _videoPlayerController.initialize();
                      _videoPlayerController.play();
                    },
                    child: Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 80.0,
                      ),
                    ),
                  );
                },
              ),
            ]),
            _chewieController == null ? const Center(child: CircularProgressIndicator(),) : Container(),
          ],
        ),
      ),
    );
  }

}
