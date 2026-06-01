import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/utils/error_handler.dart';
import 'package:vibin_app/widgets/icon_text.dart';

class FutureContent<T> extends StatelessWidget {
  final Future<T> future;
  final double? height;
  final Widget Function(BuildContext context, T data) builder;
  final T Function()? mockData;
  final bool Function(T data)? hasData;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const FutureContent({
    super.key,
    required this.future,
    required this.builder,
    this.height,
    this.mockData,
    this.hasData,
    this.emptyWidget,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final lm = AppLocalizations.of(context)!;

    return SizedBox(
      height: height,
      child: FutureBuilder<T>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {

            if (mockData != null) {
              return Skeletonizer(
                enabled: snapshot.connectionState == ConnectionState.waiting,
                child: builder(context, mockData!()),
              );
            }

            return loadingWidget ??
                const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            final stacktrace = snapshot.stackTrace;

            if (error != null) {
              logger.handle(error, stacktrace, "An unknown error occurred");
            }

            return Center(
              child: errorWidget ??
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 8,
                  children: [
                    Icon(Icons.error, color: theme.colorScheme.error, size: 48),
                    if (snapshot.error != null)
                      Text(
                        lm.dialog_error,
                      ),
                    TextButton(
                      onPressed: () => ErrorHandler.showErrorDialog(
                        context,
                        lm.dialog_error_generic_message,
                        error: error,
                        stackTrace: stacktrace
                      ),
                      child: IconText(
                        icon: Icons.open_in_browser,
                        text: lm.dialog_error_details,
                        color: theme.colorScheme.error,
                      )
                    ),
                  ],
                ),
            );
          }

          if (snapshot.hasData) {
            final data = snapshot.data as T;

            if (hasData != null && !hasData!(data)) {
              return emptyWidget ?? Center(child: Text(lm.section_no_data));
            }

            return builder(context, data);
          }

          return emptyWidget ?? Center(child: Text(lm.section_no_data));
        },
      ),
    );
  }
}
