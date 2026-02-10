import 'package:common_assets/common_assets.dart';

extension AssetsImageExtension on $AssetsImageGen {
  AssetGenImage fromName(String name) {
    return AssetGenImage('assets/image/$name.png');
  }

  AssetGenImage fromNumberedImage(String prefix, int number,
      {int padLength = 2}) {
    return fromName('${prefix}_${number.toString().padLeft(padLength, '0')}');
  }

  // 특정 경로의 이미지를 위한 메서드
  AssetGenImage fromPath(String path) {
    return AssetGenImage(path);
  }
}
