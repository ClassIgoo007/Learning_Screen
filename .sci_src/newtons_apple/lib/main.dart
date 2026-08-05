import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'theme/palette.dart';

void main() {
  runZonedGuarded<void>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // In release builds a crash reporter would be wired in here; in debug we
      // keep Flutter's own presentation so stack traces stay readable.
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        if (kReleaseMode) {
          _reportError(details.exception, details.stack);
        }
      };

      // A red-on-black stack trace is never the right thing to show a viewer.
      ErrorWidget.builder = (FlutterErrorDetails details) => const _FatalCard();

      await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      );

      runApp(const NewtonsAppleApp());
    },
    (Object error, StackTrace stack) => _reportError(error, stack),
  );
}

void _reportError(Object error, StackTrace? stack) {
  // Replace with Crashlytics / Sentry / your own sink.
  debugPrint('Unhandled error: $error\n$stack');
}

class _FatalCard extends StatelessWidget {
  const _FatalCard();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Palette.uiSurface,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Something went wrong while drawing the scene.\n'
            'Please restart the app.',
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: TextStyle(color: Palette.uiOnSurface, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
