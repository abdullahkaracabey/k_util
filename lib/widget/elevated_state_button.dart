import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_util/controllers/button_state_controller.dart';
import 'package:k_util/widget/state_widget.dart';

class ElevatedStateButton extends ConsumerStatefulWidget {
  final Widget child;
  final WidgetStateController controller;
  final AsyncCallback? onPressed;
  const ElevatedStateButton(
      {super.key,
      required this.child,
      required this.controller,
      this.onPressed});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StateWidgetState();
}

class _StateWidgetState extends ConsumerState<ElevatedStateButton> {
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

  void _onTap() {
    if (widget.controller.isOnAction() == true) return;
    widget.onPressed
        ?.call()
        .onError((error, stackTrace) => widget.controller.error())
        .then((value) {
      widget.controller.done();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: _onTap,
        child: StateWidget(controller: widget.controller, child: widget.child));
  }
}
