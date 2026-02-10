import 'package:get/get.dart';

enum AnimationType {
  no('animation_no'),
  flash('animation_flash'),
  shake('animation_shake'),
  bounce('animation_bounce'),
  tada('animation_tada'),
  swing('animation_swing'),
  wobble('animation_wobble'),
  pulse('animation_pulse'),
  flip('animation_flip'),
  flipInX('animation_flip_in_x'),
  flipOutX('animation_flip_out_x'),
  flipInY('animation_flip_in_y'),
  flipOutY('animation_flip_out_y'),
  fadeIn('animation_fade_in'),
  fadeInUp('animation_fade_in_up'),
  fadeInDown('animation_fade_in_down'),
  fadeInLeft('animation_fade_in_left'),
  fadeInRight('animation_fade_in_right'),
  fadeInUpBig('animation_fade_in_up_big'),
  fadeInDownBig('animation_fade_in_down_big'),
  fadeInLeftBig('animation_fade_in_left_big'),
  fadeInRightBig('animation_fade_in_right_big'),
  fadeOut('animation_fade_out'),
  fadeOutUp('animation_fade_out_up'),
  fadeOutDown('animation_fade_out_down'),
  fadeOutLeft('animation_fade_out_left'),
  fadeOutRight('animation_fade_out_right'),
  fadeOutUpBig('animation_fade_out_up_big'),
  fadeOutDownBig('animation_fade_out_down_big'),
  fadeOutLeftBig('animation_fade_out_left_big'),
  fadeOutRightBig('animation_fade_out_right_big'),
  bounceIn('animation_bounce_in'),
  bounceInUp('animation_bounce_in_up'),
  bounceInDown('animation_bounce_in_down'),
  bounceInLeft('animation_bounce_in_left'),
  bounceInRight('animation_bounce_in_right'),
  bounceOut('animation_bounce_out'),
  bounceOutUp('animation_bounce_out_up'),
  bounceOutDown('animation_bounce_out_down'),
  bounceOutLeft('animation_bounce_out_left'),
  bounceOutRight('animation_bounce_out_right'),
  rotateIn('animation_rotate_in'),
  rotateInUpLeft('animation_rotate_in_up_left'),
  rotateInDownLeft('animation_rotate_in_down_left'),
  rotateInUpRight('animation_rotate_in_up_right'),
  rotateInDownRight('animation_rotate_in_down_right'),
  rotateOut('animation_rotate_out'),
  rotateOutUpLeft('animation_rotate_out_up_left'),
  rotateOutDownLeft('animation_rotate_out_down_left'),
  rotateOutUpRight('animation_rotate_out_up_right'),
  rotateOutDownRight('animation_rotate_out_down_right'),
  hinge('animation_hinge'),
  rolls('animation_rolls'),
  rollIn('animation_roll_in'),
  rollOut('animation_roll_out'),
  lightSpeedIn('animation_light_speed_in'),
  lightSpeedOut('animation_light_speed_out'),
  wiggle('animation_wiggle');

  final String translationKey;
  const AnimationType(this.translationKey);

  // 번역된 이름을 가져오는 getter
  String get name => translationKey.tr;

  // CSS 클래스명으로 사용할 수 있는 형태
  String get cssName => 've-animation-${toString().split('.').last}';

  // factory constructor 방식
  factory AnimationType.fromString(String tag) {
    return AnimationType.values.firstWhere(
      (type) => type.cssName == tag,
      orElse: () => AnimationType.no, // 기본값 지정 필요
    );
  }
}
