import 'package:flutter/material.dart';

class PhotoViewDefaultError extends StatelessWidget {

  PhotoViewDefaultError({Key key, this.holderWiget, this.onFailRelaod}) : super(key: key);
  final Widget holderWiget;
  final Function onFailRelaod;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onFailRelaod,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            holderWiget == null ? Container() : holderWiget,
            Icon(
              Icons.broken_image,
              color: Colors.blue,
              size: 60.0,
            )
          ],
        ),
//      child: Center(
//        child:
//        holderWiget == null ?
//        Icon(
//          Icons.broken_image,
//          color: Colors.grey[400],
//          size: 40.0,
//        ) : holderWiget,
//      ),
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
        color: Colors.transparent,
        child: Stack(children: <Widget>[
          holderWiget == null ? Container() : Center(
            child: holderWiget,
          ),
          Center(
            child: Container(
              width: 20.0,
              height: 20.0,
              child: const CircularProgressIndicator(),
            ),
          ),
        ])
    );
  }
}
