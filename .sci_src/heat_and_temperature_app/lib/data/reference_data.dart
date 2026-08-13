import '../models/reference_table.dart';

/// Table 4-3 — liquefying and freezing points of gases.
const ReferenceTable kGasTable = ReferenceTable(
  number: 'Table 4-3',
  title: 'Liquefying and freezing points of gases',
  firstColumn: 'Liquefying point (°C)',
  secondColumn: 'Freezing point (°C)',
  axisMin: -280,
  axisMax: 0,
  note:
      'Cryogenic equipment can first liquefy air and then freeze it into a '
      'solid block. All other gases can be liquefied and frozen too, but at '
      'much lower temperatures — helium last of all, within four degrees of '
      'absolute zero.',
  rows: [
    SubstanceReading(substance: 'Chlorine', first: -35, second: -102),
    SubstanceReading(substance: 'Oxygen', first: -183, second: -218),
    SubstanceReading(substance: 'Nitrogen', first: -196, second: -210),
    SubstanceReading(substance: 'Hydrogen', first: -253, second: -259),
    SubstanceReading(substance: 'Helium', first: -269, second: -272),
  ],
);

/// Table 4-2 — melting and boiling points of metals, the other end of the
/// same scale.
const ReferenceTable kMetalTable = ReferenceTable(
  number: 'Table 4-2',
  title: 'Melting and boiling points of metals',
  firstColumn: 'Melting point (°C)',
  secondColumn: 'Boiling point (°C)',
  axisMin: 0,
  axisMax: 6000,
  note:
      'All solid bodies melt and then evaporate when the temperature is high '
      'enough. Even tungsten, the most heat-resistant of them, is gas above '
      '5,900°C — and at 6,000°C and above every material is gas, which is the '
      'state of all matter in the atmosphere of our sun.',
  rows: [
    SubstanceReading(substance: 'Tin', first: 232, second: 2260),
    SubstanceReading(substance: 'Lead', first: 327, second: 1620),
    SubstanceReading(substance: 'Aluminium', first: 660, second: 1800),
    SubstanceReading(substance: 'Copper', first: 1083, second: 2300),
    SubstanceReading(substance: 'Iron', first: 1535, second: 3000),
    SubstanceReading(substance: 'Platinum', first: 1773, second: 4300),
    SubstanceReading(substance: 'Tungsten', first: 3370, second: 5900),
  ],
);
