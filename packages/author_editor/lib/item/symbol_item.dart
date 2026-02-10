import 'package:app_ui/app_ui.dart';
import 'package:author_editor/vulcan_editor_eventbus.dart';
import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SymbolType {
  // 로마 숫자
  roman1(image: SvgGenImage('assets/image/symbolRoman1.svg'), code: 'I'),
  roman2(image: SvgGenImage('assets/image/symbolRoman2.svg'), code: 'II'),
  roman3(image: SvgGenImage('assets/image/symbolRoman3.svg'), code: 'III'),
  roman4(image: SvgGenImage('assets/image/symbolRoman4.svg'), code: 'IV'),
  roman5(image: SvgGenImage('assets/image/symbolRoman5.svg'), code: 'V'),
  roman6(image: SvgGenImage('assets/image/symbolRoman6.svg'), code: 'VI'),
  roman7(image: SvgGenImage('assets/image/symbolRoman7.svg'), code: 'VII'),
  roman8(image: SvgGenImage('assets/image/symbolRoman8.svg'), code: 'VIII'),
  roman9(image: SvgGenImage('assets/image/symbolRoman9.svg'), code: 'IX'),
  roman10(image: SvgGenImage('assets/image/symbolRoman10.svg'), code: 'X'),
  roman11(image: SvgGenImage('assets/image/symbolRoman11.svg'), code: 'ⅰ'),
  roman12(image: SvgGenImage('assets/image/symbolRoman12.svg'), code: 'ⅱ'),
  roman13(image: SvgGenImage('assets/image/symbolRoman13.svg'), code: 'ⅲ'),
  roman14(image: SvgGenImage('assets/image/symbolRoman14.svg'), code: 'ⅳ'),
  roman15(image: SvgGenImage('assets/image/symbolRoman15.svg'), code: 'ⅴ'),
  roman16(image: SvgGenImage('assets/image/symbolRoman16.svg'), code: 'ⅵ'),
  roman17(image: SvgGenImage('assets/image/symbolRoman17.svg'), code: 'ⅶ'),
  roman18(image: SvgGenImage('assets/image/symbolRoman18.svg'), code: 'ⅷ'),
  roman19(image: SvgGenImage('assets/image/symbolRoman19.svg'), code: 'ⅸ'),
  roman20(image: SvgGenImage('assets/image/symbolRoman20.svg'), code: 'ⅹ'),
  // 특수 문자
  special1(image: SvgGenImage('assets/image/symbolSpecial1.svg'), code: '○'),
  special2(image: SvgGenImage('assets/image/symbolSpecial2.svg'), code: '●'),
  special3(image: SvgGenImage('assets/image/symbolSpecial3.svg'), code: '□'),
  special4(image: SvgGenImage('assets/image/symbolSpecial4.svg'), code: '■'),
  special5(image: SvgGenImage('assets/image/symbolSpecial5.svg'), code: '△'),
  special6(image: SvgGenImage('assets/image/symbolSpecial6.svg'), code: '▽'),
  special7(image: SvgGenImage('assets/image/symbolSpecial7.svg'), code: '▷'),
  special8(image: SvgGenImage('assets/image/symbolSpecial8.svg'), code: '◁'),
  special9(image: SvgGenImage('assets/image/symbolSpecial9.svg'), code: '▲'),
  special10(image: SvgGenImage('assets/image/symbolSpecial10.svg'), code: '▼'),
  special11(image: SvgGenImage('assets/image/symbolSpecial11.svg'), code: '◀'),
  special12(image: SvgGenImage('assets/image/symbolSpecial12.svg'), code: '▶'),
  special13(image: SvgGenImage('assets/image/symbolSpecial13.svg'), code: '※'),
  special14(image: SvgGenImage('assets/image/symbolSpecial14.svg'), code: '©'),
  special15(image: SvgGenImage('assets/image/symbolSpecial15.svg'), code: '®'),
  special16(image: SvgGenImage('assets/image/symbolSpecial16.svg'), code: '™'),
  special17(image: SvgGenImage('assets/image/symbolSpecial17.svg'), code: '§'),
  special18(image: SvgGenImage('assets/image/symbolSpecial18.svg'), code: '¶'),
  special19(image: SvgGenImage('assets/image/symbolSpecial19.svg'), code: '†'),
  special20(image: SvgGenImage('assets/image/symbolSpecial20.svg'), code: '‡'),
  special21(image: SvgGenImage('assets/image/symbolSpecial21.svg'), code: '•'),
  special22(image: SvgGenImage('assets/image/symbolSpecial22.svg'), code: '★'),
  special23(image: SvgGenImage('assets/image/symbolSpecial23.svg'), code: '☆'),
  special24(image: SvgGenImage('assets/image/symbolSpecial24.svg'), code: '♠'),
  special25(image: SvgGenImage('assets/image/symbolSpecial25.svg'), code: '♤'),
  special26(image: SvgGenImage('assets/image/symbolSpecial26.svg'), code: '♣'),
  special27(image: SvgGenImage('assets/image/symbolSpecial27.svg'), code: '♧'),
  special28(image: SvgGenImage('assets/image/symbolSpecial28.svg'), code: '♥'),
  special29(image: SvgGenImage('assets/image/symbolSpecial29.svg'), code: '♡'),
  special30(image: SvgGenImage('assets/image/symbolSpecial30.svg'), code: '♦'),
  special31(image: SvgGenImage('assets/image/symbolSpecial31.svg'), code: '♢'),
  // 동그라미속 숫자
  circleNumber1(
      image: SvgGenImage('assets/image/symbolCircleNumber1.svg'), code: '①'),
  circleNumber2(
      image: SvgGenImage('assets/image/symbolCircleNumber2.svg'), code: '②'),
  circleNumber3(
      image: SvgGenImage('assets/image/symbolCircleNumber3.svg'), code: '③'),
  circleNumber4(
      image: SvgGenImage('assets/image/symbolCircleNumber4.svg'), code: '④'),
  circleNumber5(
      image: SvgGenImage('assets/image/symbolCircleNumber5.svg'), code: '⑤'),
  circleNumber6(
      image: SvgGenImage('assets/image/symbolCircleNumber6.svg'), code: '⑥'),
  circleNumber7(
      image: SvgGenImage('assets/image/symbolCircleNumber7.svg'), code: '⑦'),
  circleNumber8(
      image: SvgGenImage('assets/image/symbolCircleNumber8.svg'), code: '⑧'),
  circleNumber9(
      image: SvgGenImage('assets/image/symbolCircleNumber9.svg'), code: '⑨'),
  circleNumber10(
      image: SvgGenImage('assets/image/symbolCircleNumber10.svg'), code: '⑩'),
  circleNumber11(
      image: SvgGenImage('assets/image/symbolCircleNumber11.svg'), code: '⑪'),
  circleNumber12(
      image: SvgGenImage('assets/image/symbolCircleNumber12.svg'), code: '⑫'),
  circleNumber13(
      image: SvgGenImage('assets/image/symbolCircleNumber13.svg'), code: '⑬'),
  circleNumber14(
      image: SvgGenImage('assets/image/symbolCircleNumber14.svg'), code: '⑭'),
  circleNumber15(
      image: SvgGenImage('assets/image/symbolCircleNumber15.svg'), code: '⑮'),
  circleNumber16(
      image: SvgGenImage('assets/image/symbolCircleNumber16.svg'), code: '⑯'),
  circleNumber17(
      image: SvgGenImage('assets/image/symbolCircleNumber17.svg'), code: '⑰'),
  circleNumber18(
      image: SvgGenImage('assets/image/symbolCircleNumber18.svg'), code: '⑱'),
  circleNumber19(
      image: SvgGenImage('assets/image/symbolCircleNumber19.svg'), code: '⑲'),
  circleNumber20(
      image: SvgGenImage('assets/image/symbolCircleNumber20.svg'), code: '⑳'),
  // 수학 기호
  math1(image: SvgGenImage('assets/image/symbolMath1.svg'), code: '±'),
  math2(image: SvgGenImage('assets/image/symbolMath2.svg'), code: '×'),
  math3(image: SvgGenImage('assets/image/symbolMath3.svg'), code: '÷'),
  math4(image: SvgGenImage('assets/image/symbolMath4.svg'), code: '∑'),
  math5(image: SvgGenImage('assets/image/symbolMath5.svg'), code: '∫'),
  math6(image: SvgGenImage('assets/image/symbolMath6.svg'), code: '√'),
  math7(image: SvgGenImage('assets/image/symbolMath7.svg'), code: '≈'),
  math8(image: SvgGenImage('assets/image/symbolMath8.svg'), code: '≠'),
  math9(image: SvgGenImage('assets/image/symbolMath9.svg'), code: '≤'),
  math10(image: SvgGenImage('assets/image/symbolMath10.svg'), code: '≥'),
  math11(image: SvgGenImage('assets/image/symbolMath11.svg'), code: '∞'),
  math12(image: SvgGenImage('assets/image/symbolMath12.svg'), code: '∈'),
  math13(image: SvgGenImage('assets/image/symbolMath13.svg'), code: '∩'),
  math14(image: SvgGenImage('assets/image/symbolMath14.svg'), code: '∪'),
  // 화살표
  arrow1(image: SvgGenImage('assets/image/symbolArrow1.svg'), code: '←'),
  arrow2(image: SvgGenImage('assets/image/symbolArrow2.svg'), code: '→'),
  arrow3(image: SvgGenImage('assets/image/symbolArrow3.svg'), code: '↑'),
  arrow4(image: SvgGenImage('assets/image/symbolArrow4.svg'), code: '↓'),
  arrow5(image: SvgGenImage('assets/image/symbolArrow5.svg'), code: '↔'),
  arrow6(image: SvgGenImage('assets/image/symbolArrow6.svg'), code: '↕'),
  arrow7(image: SvgGenImage('assets/image/symbolArrow7.svg'), code: '⇐'),
  arrow8(image: SvgGenImage('assets/image/symbolArrow8.svg'), code: '⇒'),
  arrow9(image: SvgGenImage('assets/image/symbolArrow9.svg'), code: '⇑'),
  arrow10(image: SvgGenImage('assets/image/symbolArrow10.svg'), code: '⇓'),
  arrow11(image: SvgGenImage('assets/image/symbolArrow11.svg'), code: '⇔'),
  arrow12(image: SvgGenImage('assets/image/symbolArrow12.svg'), code: '⇕'),
  arrow13(image: SvgGenImage('assets/image/symbolArrow13.svg'), code: '↻'),
  arrow14(image: SvgGenImage('assets/image/symbolArrow14.svg'), code: '↺'),
  // 통화 기호
  currency1(image: SvgGenImage('assets/image/symbolCurrency1.svg'), code: '\$'),
  currency2(image: SvgGenImage('assets/image/symbolCurrency2.svg'), code: '€'),
  currency3(image: SvgGenImage('assets/image/symbolCurrency3.svg'), code: '£'),
  currency4(image: SvgGenImage('assets/image/symbolCurrency4.svg'), code: '¥'),
  currency5(image: SvgGenImage('assets/image/symbolCurrency5.svg'), code: '₩'),
  currency6(image: SvgGenImage('assets/image/symbolCurrency6.svg'), code: '₿'),
  currency7(image: SvgGenImage('assets/image/symbolCurrency7.svg'), code: '¢'),
  currency8(image: SvgGenImage('assets/image/symbolCurrency8.svg'), code: '₹'),
  currency9(image: SvgGenImage('assets/image/symbolCurrency9.svg'), code: '₽'),
  currency10(
      image: SvgGenImage('assets/image/symbolCurrency10.svg'), code: '₴'),
  currency11(
      image: SvgGenImage('assets/image/symbolCurrency11.svg'), code: '₱'),
  currency12(
      image: SvgGenImage('assets/image/symbolCurrency12.svg'), code: '₲'),
  currency13(
      image: SvgGenImage('assets/image/symbolCurrency13.svg'), code: '₪'),
  currency14(
      image: SvgGenImage('assets/image/symbolCurrency14.svg'), code: '₺'),
  // 그리스 문자
  greek1(image: SvgGenImage('assets/image/symbolGreek1.svg'), code: 'α'),
  greek2(image: SvgGenImage('assets/image/symbolGreek2.svg'), code: 'β'),
  greek3(image: SvgGenImage('assets/image/symbolGreek3.svg'), code: 'γ'),
  greek4(image: SvgGenImage('assets/image/symbolGreek4.svg'), code: 'δ'),
  greek5(image: SvgGenImage('assets/image/symbolGreek5.svg'), code: 'ε'),
  greek6(image: SvgGenImage('assets/image/symbolGreek6.svg'), code: 'ζ'),
  greek7(image: SvgGenImage('assets/image/symbolGreek7.svg'), code: 'η'),
  greek8(image: SvgGenImage('assets/image/symbolGreek8.svg'), code: 'θ'),
  greek9(image: SvgGenImage('assets/image/symbolGreek9.svg'), code: 'ι'),
  greek10(image: SvgGenImage('assets/image/symbolGreek10.svg'), code: 'κ'),
  greek11(image: SvgGenImage('assets/image/symbolGreek11.svg'), code: 'λ'),
  greek12(image: SvgGenImage('assets/image/symbolGreek12.svg'), code: 'μ'),
  greek13(image: SvgGenImage('assets/image/symbolGreek13.svg'), code: 'ν'),
  greek14(image: SvgGenImage('assets/image/symbolGreek14.svg'), code: 'ξ');

  final SvgGenImage image;
  final String code;

  const SymbolType({required this.image, required this.code});

  static List<SymbolType> get romanSymbols => [
        SymbolType.roman1,
        SymbolType.roman2,
        SymbolType.roman3,
        SymbolType.roman4,
        SymbolType.roman5,
        SymbolType.roman6,
        SymbolType.roman7,
        SymbolType.roman8,
        SymbolType.roman9,
        SymbolType.roman10,
        SymbolType.roman11,
        SymbolType.roman12,
        SymbolType.roman13,
        SymbolType.roman14,
        SymbolType.roman15,
        SymbolType.roman16,
        SymbolType.roman17,
        SymbolType.roman18,
        SymbolType.roman19,
        SymbolType.roman20,
      ];

  static List<SymbolType> get specialSymbols => [
        SymbolType.special1,
        SymbolType.special2,
        SymbolType.special3,
        SymbolType.special4,
        SymbolType.special5,
        SymbolType.special6,
        SymbolType.special7,
        SymbolType.special8,
        SymbolType.special9,
        SymbolType.special10,
        SymbolType.special11,
        SymbolType.special12,
        SymbolType.special13,
        SymbolType.special14,
        SymbolType.special15,
        SymbolType.special16,
        SymbolType.special17,
        SymbolType.special18,
        SymbolType.special19,
        SymbolType.special20,
        SymbolType.special21,
        SymbolType.special22,
        SymbolType.special23,
        SymbolType.special24,
        SymbolType.special25,
        SymbolType.special26,
        SymbolType.special27,
        SymbolType.special28,
        SymbolType.special29,
        SymbolType.special30,
        SymbolType.special31,
      ];

  static List<SymbolType> get circleNumberSymbols => [
        SymbolType.circleNumber1,
        SymbolType.circleNumber2,
        SymbolType.circleNumber3,
        SymbolType.circleNumber4,
        SymbolType.circleNumber5,
        SymbolType.circleNumber6,
        SymbolType.circleNumber7,
        SymbolType.circleNumber8,
        SymbolType.circleNumber9,
        SymbolType.circleNumber10,
        SymbolType.circleNumber11,
        SymbolType.circleNumber12,
        SymbolType.circleNumber13,
        SymbolType.circleNumber14,
        SymbolType.circleNumber15,
        SymbolType.circleNumber16,
        SymbolType.circleNumber17,
        SymbolType.circleNumber18,
        SymbolType.circleNumber19,
        SymbolType.circleNumber20,
      ];

  static List<SymbolType> get mathSymbols => [
        SymbolType.math1,
        SymbolType.math2,
        SymbolType.math3,
        SymbolType.math4,
        SymbolType.math5,
        SymbolType.math6,
        SymbolType.math7,
        SymbolType.math8,
        SymbolType.math9,
        SymbolType.math10,
        SymbolType.math11,
        SymbolType.math12,
        SymbolType.math13,
        SymbolType.math14,
      ];

  static List<SymbolType> get arrowSymbols => [
        SymbolType.arrow1,
        SymbolType.arrow2,
        SymbolType.arrow3,
        SymbolType.arrow4,
        SymbolType.arrow5,
        SymbolType.arrow6,
        SymbolType.arrow7,
        SymbolType.arrow8,
        SymbolType.arrow9,
        SymbolType.arrow10,
        SymbolType.arrow11,
        SymbolType.arrow12,
        SymbolType.arrow13,
        SymbolType.arrow14,
      ];

  static List<SymbolType> get greekSymbols => [
        SymbolType.greek1,
        SymbolType.greek2,
        SymbolType.greek3,
        SymbolType.greek4,
        SymbolType.greek5,
        SymbolType.greek6,
        SymbolType.greek7,
        SymbolType.greek8,
        SymbolType.greek9,
        SymbolType.greek10,
        SymbolType.greek11,
        SymbolType.greek12,
        SymbolType.greek13,
        SymbolType.greek14,
      ];

  static List<SymbolType> get currencySymbols => [
        SymbolType.currency1,
        SymbolType.currency2,
        SymbolType.currency3,
        SymbolType.currency4,
        SymbolType.currency5,
        SymbolType.currency6,
        SymbolType.currency7,
        SymbolType.currency8,
        SymbolType.currency9,
        SymbolType.currency10,
        SymbolType.currency11,
        SymbolType.currency12,
        SymbolType.currency13,
        SymbolType.currency14,
      ];
}

class SymbolItem extends StatelessWidget with EditorEventbus {
  SymbolItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 로마 숫자
            _buildSymbol(
                title: 'symbol_roman'.tr, symbols: SymbolType.romanSymbols),
            const SizedBox(height: 16),

            // 특수 문자
            _buildSymbol(
                title: 'symbol_special'.tr, symbols: SymbolType.specialSymbols),
            const SizedBox(height: 16),

            // 동그라미속 숫자
            _buildSymbol(
                title: 'symbol_circle_number'.tr,
                symbols: SymbolType.circleNumberSymbols),
            const SizedBox(height: 16),

            // 수학 기호
            _buildSymbol(
                title: 'symbol_math'.tr, symbols: SymbolType.mathSymbols),
            const SizedBox(height: 16),

            // 화살표
            _buildSymbol(
                title: 'symbol_arrow'.tr, symbols: SymbolType.arrowSymbols),
            const SizedBox(height: 16),

            // 통화 기호
            _buildSymbol(
                title: 'symbol_currency'.tr,
                symbols: SymbolType.currencySymbols),
            const SizedBox(height: 16),

            // 그리스 문자
            _buildSymbol(
                title: 'symbol_greek'.tr, symbols: SymbolType.greekSymbols),
            const SizedBox(height: 16),
          ],
        ));
  }

  Widget _buildSymbol(
      {required String title, required List<SymbolType> symbols}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VulcanXText(
            text: title,
            suffixIcon: const Icon(Icons.expand_more_rounded, size: 16.0)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            symbols.length,
            (index) => VulcanXElevatedButton.gray(
              width: 40,
              height: 40,
              onPressed: () => controller.insertText(symbols[index].code),
              child: symbols[index].image.svg(fit: BoxFit.none),
            ),
          ),
        ),
      ],
    );
  }
}
