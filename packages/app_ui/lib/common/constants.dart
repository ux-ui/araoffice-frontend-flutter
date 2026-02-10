import 'dart:ui';

const double kAppHorizontalSpace = 20.0;
const double kAppListItemHorizontalSpace = 10.0;
const double kAppListItemVerticalSpace = 10.0;

// ignore: depend_on_referenced_packages

const int kPenColor01 = 0xFFFFFF;
const int kPenColor02 = 0xFFFF66;
const int kPenColor03 = 0xFFB800;
const int kPenColor04 = 0xFF1212;
const int kPenColor05 = 0x990000;
const int kPenColor06 = 0x66FF99;
const int kPenColor07 = 0x33CC00;
const int kPenColor08 = 0x009900;
const int kPenColor09 = 0x00FFFF;
const int kPenColor10 = 0x67D0FF;
const int kPenColor11 = 0x0066FF;
const int kPenColor12 = 0x6633FF;
const int kPenColor13 = 0xB133FF;
const int kPenColor14 = 0xBCBCBC;
const int kPenColor15 = 0x808080;
const int kPenColor16 = 0x000000;

const int kFillColor01 = 0xFF0000;
const int kFillColor02 = 0xFF8800;
const int kFillColor03 = 0xFFEA00;
const int kFillColor04 = 0x77FF00;
const int kFillColor05 = 0x33CC00;
const int kFillColor06 = 0x009900;
const int kFillColor07 = 0x00FFFF;
const int kFillColor08 = 0x00AFFF;
const int kFillColor09 = 0x0066FF;
const int kFillColor10 = 0x7300FF;
const int kFillColor11 = 0xD400FF;
const int kFillColor12 = 0xFF00C8;

const kPenColors = <int>[
  kPenColor01,
  kPenColor02,
  kPenColor03,
  kPenColor04,
  kPenColor05,
  kPenColor06,
  kPenColor07,
  kPenColor08,
  kPenColor09,
  kPenColor10,
  kPenColor11,
  kPenColor12,
  kPenColor13,
  kPenColor14,
  kPenColor15,
  kPenColor16,
];

const kFillColors = <int>[
  kFillColor01,
  kFillColor02,
  kFillColor03,
  kFillColor04,
  kFillColor05,
  kFillColor06,
  kFillColor07,
  kFillColor08,
  kFillColor09,
  kFillColor10,
  kFillColor11,
  kFillColor12,
];

const kDefaultPenWidth = 2.0;
const kDefaultPenColor = kPenColor16;
const kDefaultFillColor = kFillColor01;
const kMaxMemoLength = 300;

enum PenColorType {
  pen01(kPenColor01),
  pen02(kPenColor02),
  pen03(kPenColor03),
  pen04(kPenColor04),
  pen05(kPenColor05),
  pen06(kPenColor06),
  pen07(kPenColor07),
  pen08(kPenColor08),
  pen09(kPenColor09),
  pen10(kPenColor10),
  pen11(kPenColor11),
  pen12(kPenColor12),
  pen13(kPenColor13),
  pen14(kPenColor14),
  pen15(kPenColor15),
  pen16(kPenColor16);

  final int rgb;

  const PenColorType(this.rgb);

  Color get color => Color((0xff << 24) | rgb);

  static PenColorType fromColor(Color color) {
    final rgb = ((color.r * 255.0).round() << 16) |
        ((color.g * 255.0).round() << 8) |
        (color.b * 255.0).round();
    return PenColorType.values.firstWhere(
      (e) => e.rgb == rgb,
      orElse: () => PenColorType.pen16,
    );
  }
}

// 100% — FF
// 95% — F2
// 90% — E6
// 85% — D9
// 80% — CC
// 75% — BF
// 70% — B3
// 65% — A6
// 60% — 99
// 55% — 8C
// 50% — 80
// 45% — 73
// 40% — 66
// 35% — 59
// 30% — 4D
// 25% — 40
// 20% — 33
// 15% — 26
// 10% — 1A
// 5% — 0D
// 0% — 00
