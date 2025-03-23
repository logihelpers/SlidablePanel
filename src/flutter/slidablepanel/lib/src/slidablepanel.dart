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
  late Tween<double> _widthTween;  // Added to track the Tween
  late bool _sidebarState;
  Duration _duration = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();

    _sidebarState = widget.control.attrBool("content_state", true)!;

    _controller = AnimationController(
      duration: _duration,
      vsync: this,
    );

    // Initialize the tween and animation
    _widthTween = Tween<double>(begin: widget.control.attrDouble("content_width", 200.0) ?? 200.0, end: 0);
    _widthAnimation = _widthTween.animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _togglePanel(_sidebarState);

    // Subscribe to backend methods in initState
    widget.backend.subscribeMethods(widget.control.id, (methodName, args) async {
      switch (methodName) {
        case "toggle_content":
          _togglePanel(bool.parse(args["content_state"].toString()));
          break;
      }
      return null;
    });
  }

  void _updateAnimation(double maxWidth) {
    _widthTween.begin = maxWidth;  // Update the tween's begin value
    _widthAnimation = _widthTween.animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    // If panel is open, reset controller to match new maxWidth
    if (_sidebarState) {
      _controller.value = 0; // Start at maxWidth
    } else {
      _controller.value = 1; // Stay at 0
    }
  }

  @override
  void didUpdateWidget(SlidablePanelControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update animation if sidebar_width changes
    double newWidth = widget.control.attrDouble("content_width", 200.0) ?? 200.0;
    if (newWidth != _widthTween.begin) {  // Compare with tween's begin value
      setState(() {
        _updateAnimation(newWidth);
        widget.backend.updateControlState(widget.control.id, {"content_width": newWidth.toString()});
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePanel(bool sidebarState) {
    if (sidebarState) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    
    _sidebarState = sidebarState;
    widget.backend.updateControlState(widget.control.id, {"content_state": sidebarState.toString()});
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("SlidablePanel build ($hashCode): ${widget.control.id}");

    return withPageArgs((context, pageArgs) {
      var sideBarControl = widget.children.where((c) => c.name == "content" && c.isVisible);

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
                    child: createControl(widget.control, sideBarControl.first.id, widget.control.isDisabled)
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