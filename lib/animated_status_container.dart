import 'dart:async';
import 'package:flutter/material.dart';

/// A container that shows a message for a short period of time and then shrinks
class AnimatedStatusContainer extends StatefulWidget {
  final String message;
  final bool isError;

  const AnimatedStatusContainer(
      {super.key, this.isError = false, required this.message});

  @override
  State<AnimatedStatusContainer> createState() =>
      _AnimatedStatusContainerState();
}

class _AnimatedStatusContainerState extends State<AnimatedStatusContainer> {
  double _width = 0;
  double _height = 0;
  bool isExpanded = false;

  /// The number of seconds for which the container is expanded
  final expandedSeconds = 5;

  /// The number of milliseconds for the transition between expanded and shrunken states
  final transitionMillis = 600;

  // Created expandedTimer as a class field to be able to cancel it when the widget is disposed
  late Timer expandedTimer;

  @override
  void dispose() {
    super.dispose();
    expandedTimer.cancel();
  }

  void shrink() {
    setState(() {
      isExpanded = false;
      _width = 0;
      _height = 0;
    });
  }

  void expand() {
    setState(() {
      // Arbitrary values
      _width = 300;
      _height = 30;
      isExpanded = true;
    });

    expandedTimer = Timer(Duration(seconds: expandedSeconds), shrink);
  }

  @override
  void initState() {
    super.initState();
    expand();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
        duration: Duration(milliseconds: transitionMillis),
        width: _width,
        height: _height,
        child: Text(
          widget.message,
          style: theme.textTheme.bodySmall!.copyWith(
              color: widget.isError
                  ? theme.colorScheme.error
                  : theme.primaryColor),
        ));
  }
}
