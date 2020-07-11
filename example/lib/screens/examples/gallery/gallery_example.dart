import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view_example/screens/app_bar.dart';
import 'package:photo_view_example/screens/examples/gallery/gallery_example_item.dart';
import 'dart:io';

import '../custom_page_route_builder.dart';

class GalleryExample extends StatefulWidget {
  @override
  _GalleryExampleState createState() => _GalleryExampleState();
}

class _GalleryExampleState extends State<GalleryExample> {
  bool verticalGallery = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const ExampleAppBar(
            title: "Gallery Example",
            showGoBack: true,
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GalleryExampleItemThumbnail(
                        galleryExampleItem: galleryItems[0],
                        onTap: () {
                          open(context, 0);
                        },
                      ),
                      GalleryExampleItemThumbnail(
                        galleryExampleItem: galleryItems[2],
                        onTap: () {
                          open(context, 2);
                        },
                      ),
                      GalleryExampleItemThumbnail(
                        galleryExampleItem: galleryItems[3],
                        onTap: () {
                          open(context, 3);
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("Vertical"),
                      Checkbox(
                        value: verticalGallery,
                        onChanged: (value) {
                          setState(() {
                            verticalGallery = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void open(BuildContext context, final int index) {
    Navigator.push(context, CustomPageRouteBuilder(
            (_, Animation<double> animation, Animation<double> secondaryAnimation) {
          Color backgroundColor = Colors.black;
          return StatefulBuilder(
            builder: (c, setState) {
              return Container(
                  color: backgroundColor,
                  child: GalleryPhotoViewWrapper(
                    initialIndex: index,
                    galleryItem: GalleryItem(
                        id: '1',
                        url: 'https://xms-dev-1251001060.cos.ap-guangzhou.myqcloud.com/x-project/user-upload-files/d28892e0920bf811f655e8e40b083577.jpg',
                        holderUrl: 'https://xms-dev-1251001060.cos.ap-guangzhou.myqcloud.com/x-project/user-upload-files/d28892e0920bf811f655e8e40b083577.jpg?imageView2/2/w/225.0/q/80'
                    ),
                    scrollDirection: Axis.horizontal,
                    getNewHead: (id) => null,
                    getNewTail: (id) => null,
                    getBackgroundColor: (color) {
                      setState(() => backgroundColor = color);
                    },
                  ));
            },
          );
        }));
  }



}



class GalleryItem {
  GalleryItem({this.id, this.resource, this.filePath, this.url, this.holderUrl, this.thumbWidth, this.thumbHeight, this.isImage = true});
  final String id;
  final String resource;
  final String filePath;
  final String url;
  final String holderUrl;
  final double thumbWidth;
  final double thumbHeight;
  final bool isImage;
}



class GalleryPhotoViewWrapper extends StatefulWidget {
  GalleryPhotoViewWrapper({
    this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialIndex = 1000,
    this.getNewTail,
    this.getNewHead,
    this.download,
    this.getBackgroundColor,
    this.maxLength,
    @required this.galleryItem,
    this.scrollDirection = Axis.horizontal,
  }) : pageController = PageController(initialPage: initialIndex);

  final LoadingBuilder loadingBuilder;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final int maxLength;
  final PageController pageController;
  final GalleryItem galleryItem;
  final GalleryItem Function(String) getNewTail;
  final GalleryItem Function(String) getNewHead;
  final void Function(GalleryItem) download;
  final void Function(Color) getBackgroundColor;
  final Axis scrollDirection;


  @override
  State<StatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> with TickerProviderStateMixin {

  int currentIndex;
  Map<int,GalleryItem> items;
  int _leading;
  int _tail;
  bool _scorllEnable = true;

  /// 下载事件
  bool downloadBtnVisable = false;
  bool downloadBtnEnable = true;

  /// 返回事件记录
  Offset initPosition;
  Offset initOffset;
  bool isDrag = false;
  List<Offset> updatePosition = [];
  Offset currentOffset = Offset(0,0);
  double scale = 1.0;

  /// 拖动取消动画
  bool isAnimate = false;
  AnimationController _bakOffsetAnimationController;
  Animation<Offset> _bakOffsetAnimation;
  AnimationController _bakScaleAnimationController;
  Animation<double> _bakScaleAnimation;


  @override
  void initState() {
    items = { widget.initialIndex : widget.galleryItem};
    currentIndex = widget.initialIndex;
    _leading = widget.initialIndex;
    _tail = widget.initialIndex;
    init();
    // 动画
    _bakOffsetAnimationController = new AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this)
      ..addListener(() => setState(() {}));
    _bakOffsetAnimation = new Tween(begin: Offset.zero, end: Offset.zero).animate(_bakOffsetAnimationController);
    _bakScaleAnimationController = new AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _bakScaleAnimation = new Tween(begin: 1.0, end: 1.0).animate(_bakScaleAnimationController);

    // 状态栏隐藏
    SystemChrome.setEnabledSystemUIOverlays([]);

    // 横竖屏设置
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.initState();
  }

  @override
  void dispose(){
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top,SystemUiOverlay.bottom]);
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }



  /// 超过前边界，禁止滑动
  disableScrollable(){
    setState(() {
      _scorllEnable = false;
    });
    Future.delayed(Duration(milliseconds: 100)).then((value)  {
      widget.pageController.animateToPage(_leading, duration: Duration(milliseconds: 100), curve: Curves.easeIn);
      setState(() {
        this._scorllEnable = true;
      });
    });
  }

  init() async {
    addHeadItem();
    addTailItem();
    /// 如果没有设置最大长度，就需要监听设置栅栏
    if (widget.maxLength == null) {
      widget.pageController.addListener(() {
        if (((widget.pageController?.offset ?? 0) < (_leading * MediaQuery
            .of(context)
            .size
            .width)) && _scorllEnable) {
          disableScrollable();
        }
      });
    }
//    Future.delayed(Duration(milliseconds: 800))
//      .then((value) => setState(() => downloadBtnVisable = true));
  }

  addHeadItem(){
    if (_leading == 0) return;
    var item = widget.getNewHead(items[_leading].id);
    if (item != null) {
      items[_leading - 1] = item;
      _leading -= 1;
    }
  }

  addTailItem(){
    var item = widget.getNewTail(items[_tail].id);
    if (item != null) {
      items[_tail + 1] = item;
      _tail += 1;
    }
  }

  void onPageChanged(int index) {
    this.downloadBtnVisable = false;
    setState(() => currentIndex = index);
    if (index == _leading) addHeadItem();
    if (index == _tail) addTailItem();
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
                  scrollPhysics: _scorllEnable ? const BouncingScrollPhysics() : const ClampingScrollPhysics(),
                  builder: _buildItem,
                  itemCount: widget.maxLength ?? (_tail + 1),
                  loadingBuilder: widget.loadingBuilder,
                  backgroundDecoration: widget.backgroundDecoration,
                  pageController: widget.pageController,
                  onPageChanged: onPageChanged,
                  scrollDirection: widget.scrollDirection,
                ),
                (!downloadBtnVisable || isDrag ) ? Container() : GestureDetector(
                  onTap: !downloadBtnEnable ? null : () async {
                    setState(() => downloadBtnEnable = false);
                    if (widget.download != null) {
                      widget.download(items[currentIndex]);
                    } else {
                      _saveGalleryImage(items[currentIndex]);
                    }
                    Future.delayed(Duration(milliseconds: 800))
                        .then((value) => setState(() => downloadBtnEnable = true));
                  },
                  child: Container(
                    height: 36,
                    width: 36,
                    margin: EdgeInsets.only(right: 20,bottom: 40),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey,width: 0.5)
                    ),
                    child: Icon(
                      Icons.file_download,
                    ),
                  ),
                )
              ],
            ),
          ),
        )
    );
    return Transform.translate(
      offset: isAnimate ? _bakOffsetAnimation.value : currentOffset,
      child: Transform.scale( //_bakScaleAnimation
          scale: isAnimate ? _bakScaleAnimation.value : scale,
          child: child
      ),
    );
  }

  _saveGalleryImage(GalleryItem item) async {
    /// 图片保存的代码
  }

  _onScaleStart(context,details,delta,controllerValue ){
    this.initOffset = details.localFocalPoint;
    this.initPosition = controllerValue.position;
    this.isDrag = false;
    setState(() => this.isAnimate = false);
    _bakOffsetAnimationController.reset();
    _bakScaleAnimationController.reset();
  }

  _onScaleUpdate(context,details,delta,controllerValue) {
    this.updatePosition.add(controllerValue.position);
    Offset currentOffset = Offset(details.localFocalPoint.dx - this.initOffset.dx, details.localFocalPoint.dy - this.initOffset.dy);
    if ( this.isDrag
        || (this.updatePosition.length > 3
            && this.updatePosition[3].dy == this.initPosition.dy
            && (this.updatePosition[3].dx - this.initPosition.dx).abs() < 4)
            && (this.scale == details.scale)) {

      var verticalDistance = currentOffset.dy > 300 ? 300 : currentOffset.dy;
      verticalDistance = verticalDistance < 0 ? 0 : verticalDistance;
      final color = Color.fromRGBO(0, 0, 0, 1 - verticalDistance / 300);
      widget?.getBackgroundColor?.call(color);
      // scale
      final scale = (1 - verticalDistance / 300 ) < 0.3 ? 0.3  : (1 - verticalDistance / 300 );
      _bakOffsetAnimation = _bakOffsetAnimationController.drive(new Tween(begin: this.currentOffset, end: Offset.zero));
      _bakScaleAnimation = _bakScaleAnimationController.drive(new Tween(begin: scale, end: 1.0));
      setState(() {
        this.isDrag = true;
        this.currentOffset = currentOffset;
        this.scale = scale;
      });
    }
  }

  _onScaleEnd(context,details,delta,controllerValue){
    if (currentOffset.dy > 150) {
      Navigator.of(context).pop();
      return;
    }

    if (this.isDrag) {
      setState(() => this.isAnimate = true);
      _bakOffsetAnimationController.forward();
      _bakScaleAnimationController.forward();
    }
    this.updatePosition = [];
    widget?.getBackgroundColor?.call(Colors.black);

    setState(() {
      this.isDrag = false;
      this.scale = 1;
      this.currentOffset = Offset.zero;
    });
  }

  PhotoViewGalleryPageOptions _buildImageItem(BuildContext context, int index) {
    final GalleryItem item = items[index];
    ImageProvider provider;
    if (item.filePath != null)
      provider = FileImage(File(item.filePath));
    else if (item.url != null)
      provider = CacheNetworkImage(item.url);
    else if (item.resource != null)
      provider = AssetImage(item.resource);
    return PhotoViewGalleryPageOptions(
        backgroundDecoration: BoxDecoration(color: Color(0x00000000)),
        imageProvider: provider,
        onTapUp: (context,_,value) {
          Navigator.of(context).pop();
        },
//        holderWiget: ,
        minScale: PhotoViewComputedScale.contained * 0.8,
        maxScale: PhotoViewComputedScale.covered * 1.4,
        heroAttributes: PhotoViewHeroAttributes(tag: item.id),
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onScaleEnd: _onScaleEnd,
        loadResultCallback: (result) async {
          Future.delayed(Duration(milliseconds: 500))
              .then((value) {
            if (index == currentIndex && result) {
              setState(() {
                this.downloadBtnVisable = true;
              });
            }
          });
        }
    );
  }

  PhotoViewGalleryPageOptions _buildVideoItem(BuildContext context, int index) {
    final GalleryItem item = items[index];
    return PhotoViewGalleryPageOptions
        .customChild(
      child: VideoView(id: item.id, thumbUrl: item.holderUrl, videoUrl: item.url,thumbHeight: item.thumbHeight, thumbWidth: item.thumbWidth,),
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final GalleryItem item = items[index];
    if (item == null) return PhotoViewGalleryPageOptions.customChild(child: Container());
    if (item.isImage) {
      return _buildImageItem(context, index);
    } else {
      return _buildVideoItem(context, index);
    }
  }
}


