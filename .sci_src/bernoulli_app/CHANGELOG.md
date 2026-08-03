# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and the project uses [semantic versioning](https://semver.org/).

## [1.0.0] — 2026-08-02

### Added
- Animated recreation of Figure 1-10: a Venturi tube with three standpipes
  showing that pressure falls where the water speeds up.
- Interactive flow-rate and throat-diameter controls with live readouts.
- Pressure-budget bars showing how `p + ½ρv²` is divided at each station.
- Cavitation warning when the throat pressure falls below zero.
- Ten-question quiz on Bernoulli's principle with per-answer explanations.
- Light and dark themes, screen-reader labels, and "reduce motion" support.
- Unit and widget test suites; CI running `analyze` and `test`.

### Fixed
- Flow particles were reseeded on every frame while the throat slider was
  dragged, which made them jump instead of flowing.
