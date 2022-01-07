import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ScrollImageViewTest extends StatefulWidget {
  @override
  _ScrollImageViewTestState createState() => _ScrollImageViewTestState();
}

class _ScrollImageViewTestState extends State<ScrollImageViewTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Image(
              fit: BoxFit.fitWidth,
              image: CacheNetworkImage(
                  "https://fb-cdn.fanbook.mobi/fanbook/app/files/chatroom/image/5b928cc334d34b3e52966bb1777c9bb7.jpg")),
        ),
      ),
    );
  }
}

class ImagePageView extends StatefulWidget {
  @override
  _ImagePageViewState createState() => _ImagePageViewState();
}

class _ImagePageViewState extends State<ImagePageView> {
  final galleryItems = [
    "https://fb-cdn.fanbook.mobi/fanbook/app/files/chatroom/image/5b928cc334d34b3e52966bb1777c9bb7.jpg",
    "https://fb-cdn.fanbook.mobi/fanbook/app/files/chatroom/image/63cb094c3500436f72704412d8b2d3dc.jpg",
    "https://fb-cdn.fanbook.mobi/fanbook/app/files/chatroom/image/91307c62fc8e698d79f7aca4a78856bf.jpg",
    "https://fb-cdn.fanbook.mobi/fanbook/app/files/chatroom/image/cde48a1d7b2b7c32421ee3fbe51d4ed4.jpg"
  ];
  final PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  void onPageChanged(int index) {}

  void _onScaleStart(context, details, delta, controllerValue) {
    // logger.info(
    //     "_onScaleStart_onScaleStart: $context $details  $delta $controllerValue");
    // galleryGestureWrapperKey.currentState
    //     .onScaleStart(context, details, delta, controllerValue);
  }

  void _onScaleUpdate(context, details, delta, controllerValue) {
    // logger.info("_onScaleUpdate: $details  $delta $controllerValue");

    // galleryGestureWrapperKey.currentState
    //     .onScaleUpdate(context, details, delta, controllerValue);
  }

  void _onScaleEnd(context, details, delta, controllerValue) {
    // logger.info("_onScaleEnd: $details  $delta $controllerValue");

    // galleryGestureWrapperKey.currentState
    //     .onScaleEnd(context, details, delta, controllerValue);
  }

  PhotoViewGalleryPageOptions _buildImageItem(BuildContext context, int index) {
    final String item = galleryItems[index];
    ImageProvider provider = CacheNetworkImage(item);

    //其他图片背景为黑色
    return PhotoViewGalleryPageOptions(
        imageProvider: provider,
        onTapUp: (context, _, value) {
          Navigator.of(context).pop();
        },
        filterQuality: FilterQuality.high,
        //占位符-缩略图
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 4,
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onScaleEnd: _onScaleEnd);
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final String item = galleryItems[index];
    if (item == null)
      return PhotoViewGalleryPageOptions.customChild(child: Container());

    return _buildImageItem(context, index);
  }

  @override
  Widget build(BuildContext context) {
    var child = Scaffold(
        backgroundColor: Color(0x00000000),
        body: GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              color: Color(0x00000000),
            ),
            constraints: BoxConstraints.expand(
              height: MediaQuery.of(context).size.height,
            ),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: <Widget>[
                PhotoViewGallery.builder(
                  builder: _buildItem,
                  itemCount: galleryItems.length,
                  backgroundDecoration: BoxDecoration(color: Colors.black),
                  pageController: pageController,
                  onPageChanged: onPageChanged,
                  scrollDirection: Axis.horizontal,
                  scrollPhysics: BouncingScrollPhysics(),
                  // ? const BouncingScrollPhysics()
                  // : const ClampingScrollPhysics(),
                ),
              ],
            ),
          ),
        ));

    return child;
  }
}
