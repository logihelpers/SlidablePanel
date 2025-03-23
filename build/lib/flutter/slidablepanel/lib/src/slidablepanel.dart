import 'package:flet/flet.dart';
import 'package:flutter/material.dart';

class SlidablePanelControl extends StatefulWidget {
  final Control? parent;
  final Control control;
  final List<Control> children;
  final FletControlBackend backend;

  const SlidablePanelControl({
    super.key,
    required this.parent,
    required this.control,
    required this.children,
    required this.backend,
  });

  @override
  State<SlidablePanelControl> createState() => _SlidablePanelControlState();
}

class _SlidablePanelControlState extends State<SlidablePanelControl>
    with FletStoreMixin, SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late Tween<double> _widthTween;
  late bool _contentHidden;
  Duration _duration = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _contentHidden = widget.control.attrBool("content_hidden", false)!;
    _controller = AnimationController(
      duration: _duration,
      vsync: this,
    );
    
    _widthTween = Tween<double>(
      begin: widget.control.attrDouble("content_width", 200.0) ?? 200.0,
      end: 0,
    );
    _widthAnimation = _widthTween.animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Set initial controller value based on content_hidden
    _controller.value = _contentHidden ? 1.0 : 0.0;
  }

  void _updateAnimation(double maxWidth) {
    _widthTween.begin = maxWidth;
    _widthAnimation = _widthTween.animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(SlidablePanelControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    double newWidth = widget.control.attrDouble("content_width", 200.0) ?? 200.0;
    bool newContentHidden = widget.control.attrBool("content_hidden", false)!;

    if (newWidth != _widthTween.begin || newContentHidden != _contentHidden) {
      setState(() {
        _updateAnimation(newWidth);
        if (newContentHidden != _contentHidden) {
          _contentHidden = newContentHidden;
          if (_contentHidden) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("SlidablePanel build ($hashCode): ${widget.control.id}");

    return withPageArgs((context, pageArgs) {
      var sideBarControl = widget.children
          .where((c) => c.name == "content" && c.isVisible)
          .first;

      var builder = LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              AnimatedBuilder(
                animation: _widthAnimation,
                builder: (context, child) {
                  return SizedBox(
                    width: _widthAnimation.value,
                    height: constraints.maxHeight,
                    child: createControl(
                        widget.control,
                        sideBarControl.id,
                        widget.control.isDisabled),
                  );
                },
              ),
            ],
          );
        },
      );

      return constrainedControl(context, builder, widget.parent, widget.control);
    });
  }
}