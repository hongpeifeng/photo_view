import 'package:flutter/material.dart';

//加载图片失败后显示的Widget
class PhotoViewDefaultError extends StatelessWidget {

  PhotoViewDefaultError({Key? key, this.holderWiget, this.onFailReload}) : super(key: key);
  final Widget? holderWiget;     //占位背景暂时不用
  final Function? onFailReload;  //重新加载方法

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.black,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: onFailReload as void Function()?,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
                Icons.broken_image,
                color: Colors.white30,
                size: 60
            ),
            const SizedBox(height: 80),
            Container(
              constraints: const BoxConstraints.tightFor(width: 128, height: 36),
              decoration: BoxDecoration(border: Border.all(color: Colors.white30, width: 0.5), borderRadius: BorderRadius.circular(5)),
              alignment: Alignment.center,
              child: const Text("重新加载", style: TextStyle(fontSize: 14, color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}

class PhotoViewDefaultLoading extends StatelessWidget {
  const PhotoViewDefaultLoading({Key? key, this.event, this.holderWiget}) : super(key: key);

  final ImageChunkEvent? event;
  final Widget? holderWiget;

  @override
  Widget build(BuildContext context) {
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
              width: 16,
              height: 16,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ])
    );
  }
}
