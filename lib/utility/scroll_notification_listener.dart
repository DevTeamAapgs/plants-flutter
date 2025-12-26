import 'package:flutter/material.dart';

class ScrollNotificationListener extends StatefulWidget {

  final Widget child;
  final Map? params;
  final Future<dynamic> Function(BuildContext,{dynamic body,bool isLoadMore}) future;

  const ScrollNotificationListener({Key? key, required this.child, required this.future, this.params}) : super(key: key);

  @override
  State<ScrollNotificationListener> createState() => _ScrollNotificationListenerState();
}

class _ScrollNotificationListenerState extends State<ScrollNotificationListener> {

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      child: widget.child,
      onNotification: (scrollInfo)
      {
//        print("Scroll Pixel - " + scrollInfo.metrics.pixels.toString());
//        print("Scroll MaxScroll - " + scrollInfo.metrics.maxScrollExtent.toString() + " - " + scrollInfo.metrics.minScrollExtent.toString());
//        print("Scroll Extend - " + scrollInfo.metrics.extentAfter.toString() + " - " + scrollInfo.metrics.extentBefore.toString() + " - " + scrollInfo.metrics.extentInside.toString());
        if (!_isLoading && scrollInfo.metrics.pixels ==
            scrollInfo.metrics.maxScrollExtent) {
          _isLoading = true;

          try {
            widget.future(context, body : widget.params ?? {}, isLoadMore : true).then((value) => _isLoading = false);
          } on Exception catch(error){
            _isLoading = false;
          }
        }
        return true;
      },
    );
  }
}