import 'package:flutter/foundation.dart';
import 'package:k_util/models/enums.dart';

class WidgetStateController extends ChangeNotifier {
  WidgetState state = WidgetState.init;
  void start() {
    if (state != WidgetState.onAction) {
      state = WidgetState.onAction;
      notifyListeners();
    }
  }

  void done({Duration? revertDuration}) {
    // if (!mounted) return;
    if (state != WidgetState.completed) {
      state = WidgetState.completed;
      notifyListeners();

      if (revertDuration != null) {
        Future.delayed(revertDuration, () {
          state = WidgetState.init;
          notifyListeners();
        });
      }
    }
  }

  void init() {
    if (state != WidgetState.init) {
      state = WidgetState.init;
      notifyListeners();
    }
  }

  void error({Duration? revertDuration}) {
    if (state != WidgetState.error) {
      state = WidgetState.error;
      notifyListeners();

      if (revertDuration != null) {
        Future.delayed(revertDuration, () {
          state = WidgetState.init;
          notifyListeners();
        });
      }
    }
  }

  bool isOnAction() => state == WidgetState.onAction;
}
