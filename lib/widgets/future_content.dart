import 'package:flutter/material.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

class FutureContent<T> extends StatelessWidget {
  final Future<T> future;
  final double? height;
  final Widget Function(BuildContext context, T data) builder;
  final bool Function(T data)? hasData;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const FutureContent({
    super.key,
    required this.future,
    required this.builder,
    this.height,
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
            return loadingWidget ??
                const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return errorWidget ??
              Center(
                child: Text(
                  '${lm.dialog_error}: ${snapshot.error}',
                  style: TextStyle(color: theme.colorScheme.error),
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
