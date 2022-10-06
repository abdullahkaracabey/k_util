import 'package:flutter/material.dart';
import 'package:k_util/l10n/k_util_localizations.dart';
import 'package:k_util/models/app_error.dart';
import 'package:k_util/models/enums.dart';
import 'package:k_util/util/snack.dart';

typedef OnError = void Function(AppException error);

enum ErrorShowType { snack, modal }

class BaseViewState<W extends StatefulWidget> extends State<W> {
  WidgetState currentState = WidgetState.init;
  ColorScheme get colorScheme => Theme.of(context).colorScheme;
  TextTheme get textTheme => Theme.of(context).textTheme;

  BaseViewState();

  @override
  void initState() {
    super.initState();
  }

  Widget getLoadingView() {
    return const CircularProgressIndicator();
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
          message = localization.warningLogin;
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
              content: Text(message),
              actions: [
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(localization.ok))
              ],
            ));
  }

  showLoaderDialog(BuildContext context, {String? text}) {
    AlertDialog alert = AlertDialog(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
              // backgroundColor: AppThemeData.primaryColor,
              ),
          text != null
              ? Container(
                  margin: const EdgeInsets.only(left: 7), child: Text(text))
              : const SizedBox(
                  width: 1,
                  height: 1,
                ),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void actionState(WidgetState state, {String? text}) {
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
