import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';

class ExpandingSearchBar extends StatefulWidget {
  const ExpandingSearchBar({
    super.key,
    this.hintText = 'Search…',
    this.onSubmitted,
    this.expandFromRight = false,
    this.maxWidth = 320,
    this.debounce = const Duration(seconds: 2),
    this.onCancel,
  });

  final String hintText;
  final ValueChanged<String>? onSubmitted;
  final bool expandFromRight;
  final double maxWidth;
  final Duration debounce;
  final VoidCallback? onCancel;

  @override
  State<ExpandingSearchBar> createState() => _ExpandingSearchBarState();
}

class _ExpandingSearchBarState extends State<ExpandingSearchBar>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounceTimer;
  String _lastEmitted = '';

  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _fadeCtrl,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeIn,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    _fadeCtrl.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new timer
    _debounceTimer = Timer(widget.debounce, () {
      final text = _controller.text.trim();
      if (text != _lastEmitted) {
        log("inga varan 1");

        _lastEmitted = text;
        widget.onSubmitted?.call(text);
      }
    });
  }

  void _open() {
    setState(() => _expanded = true);
    _fadeCtrl.forward();
    Future.microtask(() => _focusNode.requestFocus());
  }

  void _close() {
    setState(() => _expanded = false);
    _fadeCtrl.reverse();
    _controller.clear();
    _focusNode.unfocus();
    _debounceTimer?.cancel();
    // Reset last emitted when closing
    _lastEmitted = '';
    widget.onCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    final align = widget.expandFromRight
        ? Alignment.centerRight
        : Alignment.centerLeft;
    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.maxWidth),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const double collapsedSize = 37;
            const double height = 40;
            const double radius = 18;
            const double spacing = 8;
            const cancelMinWidth = 0.0;
            final cancelMaxWidth = 70.0;

            final double _available =
                constraints.maxWidth - cancelMaxWidth - spacing;
            final double _safeAvail = _available.isFinite
                ? (_available > 0 ? _available.floorToDouble() : 0)
                : 0;
            final targetSearchWidth = _expanded
                ? (_safeAvail < collapsedSize ? _safeAvail : _safeAvail)
                : collapsedSize;

            final childrenLTR = <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                width: targetSearchWidth,
                height: height,
                decoration: ShapeDecoration(
                  color: const Color(0xFFD0FFE2),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Color(0xFF86EFAC)),
                    borderRadius: BorderRadius.circular(radius),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _expanded
                    ? Row(
                        children: [
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.search,
                            size: 20,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              autofocus: true,
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                hintText: widget.hintText,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              onSubmitted: (value) {
                                // Cancel debounce timer and submit immediately
                                _debounceTimer?.cancel();
                                final text = value.trim();
                                if (text.isNotEmpty) {
                                  _lastEmitted = text;
                                  log("inga varan 2");

                                  widget.onSubmitted?.call(text);
                                }
                              },
                            ),
                          ),
                        ],
                      )
                    : IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.search,
                          size: 20,
                          color: Colors.green,
                        ),
                        onPressed: _open,
                      ),
              ),

              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                width: _expanded ? spacing : 0,
              ),

              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                width: _expanded ? cancelMaxWidth : cancelMinWidth,
                child: FadeTransition(
                  opacity: _fade,
                  child: _expanded
                      ? SizedBox(
                          height: 32,
                          width: 32,
                          child: IconButton(
                            onPressed: _close,
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFD0FFE2),
                              side: const BorderSide(
                                color: Color(0xFF86EFAC),
                                width: 1.2,
                              ),
                              shape: const CircleBorder(),
                              padding: EdgeInsets.zero,
                            ),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: Colors.green,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ];

            final childrenRTL = childrenLTR;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: widget.expandFromRight ? childrenRTL : childrenLTR,
            );
          },
        ),
      ),
    );
  }
}
