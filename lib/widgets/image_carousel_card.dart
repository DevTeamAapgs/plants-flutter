import 'dart:io';

import 'package:flutter/material.dart';
import 'package:arumbu/constants/urls.dart';

class ImageCarouselCard extends StatefulWidget {
  const ImageCarouselCard({
    super.key,
    required this.images,
    this.width = 331,
    this.height = 251,
    this.borderRadius = 32,
    this.borderWidth = 5,
  });

  final List<String> images;
  final double width;
  final double height;
  final double borderRadius;
  final double borderWidth;

  @override
  State<ImageCarouselCard> createState() => _ImageCarouselCardState();
}

class _ImageCarouselCardState extends State<ImageCarouselCard> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(widget.borderRadius);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // White border + rounded corners
          Container(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: widget.borderWidth,
                  color: Colors.white,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
                borderRadius: BorderRadius.all(radius),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.all(radius),
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.images.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _buildImage(widget.images[i]),
              ),
            ),
          ),

          // Dots indicator (overlay)
          Positioned(
            bottom: 10,
            child: _Dots(count: widget.images.length, index: _index),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.startsWith('file://')) {
      final cleaned = path.replaceFirst('file://', '');
      final file = File(cleaned);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
        );
      }
    }

    final resolved = path.startsWith('http') ? path : "${URLs.imageUrl}$path";
    return Image.network(
      resolved,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (i) {
          final active = i == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 8,
            width: active ? 18 : 8,
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.white70,
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }),
      ),
    );
  }
}
