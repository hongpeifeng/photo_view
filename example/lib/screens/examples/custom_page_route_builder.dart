import 'package:flutter/material.dart';

class CustomPageRouteBuilder extends PageRouteBuilder {
  // 跳转的页面
//  final Widget widget;
  final RoutePageBuilder pageBuilder;

  CustomPageRouteBuilder(this.pageBuilder)
      : super(
            opaque: false,
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return pageBuilder(context, animation, secondaryAnimation);
            },
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child) {
              return FadeTransition(
                  child: child,
                  opacity: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                      parent: animation, curve: Curves.fastOutSlowIn)));
            });
}
