import 'package:flutter/material.dart' hide WidgetState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_util/controllers/button_state_controller.dart';
import 'package:k_util/models/enums.dart';

class StateWidget extends ConsumerStatefulWidget {
  final Widget child;
  final WidgetStateController controller;
  final Color? progressColor;
  const StateWidget(
      {super.key,
      required this.child,
      required this.controller,
      this.progressColor = Colors.white});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StateWidgetState();
}

class _StateWidgetState extends ConsumerState<StateWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  void _onChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const SizedBox(
        width: 24,
        height: 15,
      ),
      widget.child,
      const SizedBox(
        width: 9,
      ),
      if (state == WidgetState.onAction)
        SizedBox(
          width: 15,
          height: 15,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: widget.progressColor,
          ),
        ),
      if (state == WidgetState.completed)
        const Icon(Icons.check, color: Colors.green, size: 15),
      if (state == WidgetState.error)
        const Icon(
          Icons.error,
          color: Colors.red,
          size: 15,
        ),
      if (state == WidgetState.init)
        const SizedBox(
          width: 15,
        ),
    ]);
  }
}
