import 'package:flutter/foundation.dart';

import '../physics/venturi.dart';

/// Holds everything the simulation screen can change. Kept out of the widget
/// so the behaviour can be unit tested without pumping a frame.
class SimulationController extends ChangeNotifier {
  SimulationController({VenturiModel? model}) : _model = model ?? const VenturiModel();

  VenturiModel _model;
  bool _running = true;
  bool _showStreamlines = true;

  VenturiModel get model => _model;
  bool get running => _running;
  bool get showStreamlines => _showStreamlines;

  /// True when the pipe shape is doing nothing: no constriction, no drop.
  bool get isStraightPipe => _model.isStraightPipe;

  set flow(double value) {
    final next = _model.copyWith(
      flow: value.clamp(VenturiModel.minFlow, VenturiModel.maxFlow).toDouble(),
    );
    if (next == _model) return;
    _model = next;
    notifyListeners();
  }

  set throatDiameter(double value) {
    // Never let the throat exceed the pipe: that would assert in the model.
    final upper = _model.wideDiameter < VenturiModel.maxThroat
        ? _model.wideDiameter
        : VenturiModel.maxThroat;
    final next = _model.copyWith(
      throatDiameter: value.clamp(VenturiModel.minThroat, upper).toDouble(),
    );
    if (next == _model) return;
    _model = next;
    notifyListeners();
  }

  void toggleRunning() {
    _running = !_running;
    notifyListeners();
  }

  void setRunning(bool value) {
    if (_running == value) return;
    _running = value;
    notifyListeners();
  }

  void setShowStreamlines(bool value) {
    if (_showStreamlines == value) return;
    _showStreamlines = value;
    notifyListeners();
  }

  void reset() {
    _model = const VenturiModel();
    _running = true;
    _showStreamlines = true;
    notifyListeners();
  }

  /// Spoken description of the figure, for screen readers.
  String describe() => _model.describe();
}
