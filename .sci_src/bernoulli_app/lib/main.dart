import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  // Everything runs inside a guarded zone so that an unexpected error is
  // reported through one path instead of vanishing into the console.
  runZonedGuarded<void>(
    () {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        _report(details.exception, details.stack);
      };

      // Errors raised by the engine outside the Flutter framework.
      PlatformDispatcher.instance.onError = (error, stack) {
        _report(error, stack);
        return true;
      };

      runApp(const BernoulliApp());
    },
    _report,
  );
}

/// Single place to send crashes. Wire a reporter (Crashlytics, Sentry,
/// your own endpoint) in here; in debug it just prints.
void _report(Object error, StackTrace? stack) {
  if (kDebugMode) {
    debugPrint('Unhandled error: $error\n$stack');
  }
  // TODO(release): forward to a crash reporting service.
}
