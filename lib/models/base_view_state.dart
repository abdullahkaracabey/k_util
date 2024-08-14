import 'package:flutter/material.dart' hide WidgetState;
import 'package:k_util/l10n/k_util_localizations.dart';
import 'package:k_util/models/app_error.dart';
import 'package:k_util/models/enums.dart';
import 'package:k_util/util/snack.dart';

typedef OnError = void Function(AppException error);

enum ErrorShowType { snack, modal }

typedef RequestCall<T> = Future<T> Function();

class BaseViewState<W extends StatefulWidget> extends State<W> {
  WidgetState currentState = WidgetState.init;
  ColorScheme get colorScheme => Theme.of(context).colorScheme;
  TextTheme get textTheme => Theme.of(context).textTheme;
  BuildContext? _dialogContext;

  BaseViewState();

  @override
  void initState() {
    super.initState();
  }

  Widget getLoadingView() {
    return const CircularProgressIndicator();
  }

  void hideKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  Future<T?> callRequest<T>(RequestCall<T> function,
      {bool shouldChangeWidgetState = true,
      Function? onThrowError,
      String? alertText}) async {
    try {
      if (shouldChangeWidgetState) {
        if (alertText != null) {
          showLoaderDialog(context, text: alertText);
        } else {
          actionState(WidgetState.onAction);
        }
      }
      var result = await function();

      hideDialog();
      return result;
    } catch (e) {
      debugPrint(e.toString());
      onError(e);
      rethrow;
    } finally {
      if (shouldChangeWidgetState) {
        actionState(WidgetState.init);
      }
    }
  }

  onUpdate() {
    setState(() {});
  }

  // onChangeLanguage() {
  //   final textTheme = Theme.of(context).textTheme;

  //   final languages = AppLanguageManager().languages;
  //   final keys = languages.keys.toList();
  //   showModalBottomSheet(
  //     context: context,
  //     // isDismissible: false,
  //     builder: (context) {
  //       return Container(
  //           height: 200,
  //           padding: const EdgeInsets.all(16),
  //           child: ListView.builder(
  //             itemCount: keys.length,
  //             itemBuilder: (context, index) {
  //               var key = keys[index];
  //               var language = languages[key];
  //               return ListTile(
  //                 title: Text(language ?? ""),
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                   AppLanguageManager().changeLanguage(key);
  //                 },
  //               );
  //             },
  //           ));
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  void onError(dynamic rawError,
      {ErrorShowType showType = ErrorShowType.snack,
      shouldClearActionState = true}) {
    currentState = WidgetState.init;
    final localization = KUtilLocalizations.of(context)!;

    AppException error;

    if (rawError is AppException) {
      error = rawError;
    } else {
      error = AppException(message: rawError.toString());
    }

    String message;

    if (error.code != null) {
      switch (error.code) {
        case AppException.kUnknownError:
          message = localization.warningUnknownError;
          break;
        case AppException.kUnAuthorized:
          if (error.message != null) {
            message = error.message!;
          } else {
            message = localization.warningLogin;
          }
          break;
        default:
          message = error.message ?? localization.warningUnknownError;
      }
    } else {
      message = error.message!;
    }

    if (shouldClearActionState) {
      actionState(WidgetState.init);
    }

    if (showType == ErrorShowType.snack) {
      Snack.showInfoSnack(context, message,
          duration: const Duration(seconds: 2));
      return;
    }

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(localization.error),
              content: Text("$message ${error.code ?? ''}"),
              actions: [
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(localization.ok))
              ],
            ));
  }

  showInfoDialog(String title, String message) {
    final localization = KUtilLocalizations.of(context)!;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(localization.ok))
              ],
            ));
  }

  Future showLoaderDialog(BuildContext context, {String? text}) {
    AlertDialog alert = AlertDialog(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
              // backgroundColor: AppThemeData.primaryColor,
              ),
          text != null
              ? Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(left: 7),
                      child: Text(text)))
              : const SizedBox(
                  width: 1,
                  height: 1,
                ),
        ],
      ),
    );
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        _dialogContext = context;
        return alert;
      },
    );
  }

  hideDialog() {
    if (_dialogContext != null) {
      Navigator.pop(_dialogContext!);
      _dialogContext = null;
    }
  }

  @override
  void actionState(WidgetState state) {
    // if (isActive) {
    //   showLoaderDialog(context, text: text);
    // } else {
    //   try {
    //     Navigator.pop(context);
    //   } catch (e) {
    //     debugPrint(e.toString());
    //   }
    // }

    // if (currentState == state) return; //TODO in error catch block current state is always init. Solve this.
    currentState = state;
    if (mounted) {
      setState(() {});
    }
  }
}
