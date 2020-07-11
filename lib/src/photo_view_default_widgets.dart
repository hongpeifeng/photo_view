import 'package:flutter/material.dart';

class PhotoViewDefaultError extends StatelessWidget {

  PhotoViewDefaultError({Key key, this.holderWiget}) : super(key: key);
  final Widget holderWiget;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Color(0x00000000),
      child: Center(
        child:
        holderWiget == null ?
        Icon(
          Icons.broken_image,
          color: Colors.grey[400],
          size: 40.0,
        ) : holderWiget,
      ),
    );
  }
}

class PhotoViewDefaultLoading extends StatelessWidget {
  const PhotoViewDefaultLoading({Key key, this.event, this.holderWiget}) : super(key: key);

  final ImageChunkEvent event;
  final Widget holderWiget;

  @override
  Widget build(BuildContext context) {
    final value = event == null
        ? 0.0
        : event.cumulativeBytesLoaded / event.expectedTotalBytes;
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Color(0x00000000),
        child: Stack(children: <Widget>[
          holderWiget == null ? Container() : Center(
            child: holderWiget,
          ),
          Center(
            child: Container(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(value: value),
            ),
          ),
        ])
    );
  }
}
