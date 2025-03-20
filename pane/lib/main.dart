import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplitPaneExample(),
    );
  }
}

class SplitPaneExample extends StatefulWidget {
  const SplitPaneExample({super.key});

  @override
  State<SplitPaneExample> createState() => _SplitPaneExampleState();
}

class _SplitPaneExampleState extends State<SplitPaneExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  bool _isPanelOpen = true;
  final double _maxWidth = 200.0; // Maximum width of the sliding panel

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _widthAnimation = Tween<double>(begin: _maxWidth, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePanel() {
    if (_isPanelOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isPanelOpen = !_isPanelOpen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sliding Split Pane')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              AnimatedBuilder(
                animation: _widthAnimation,
                builder: (context, child) {
                  return SizedBox(
                    width: _widthAnimation.value,
                    height: constraints.maxHeight,
                    child: Container(
                      color: Colors.blue[100],
                      child: _widthAnimation.value > 50 // Only show content when wide enough
                          ? Center(child: Text('Left Panel'))
                          : null,
                    ),
                  );
                },
              ),
              Expanded(
                child: Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Main Content'),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _togglePanel,
                          child: Text(_isPanelOpen ? 'Close Panel' : 'Open Panel'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}