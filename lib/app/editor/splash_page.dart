import 'dart:async';

import 'package:common_assets/common_assets.dart';
import 'package:common_util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'cotroller/splash_controller.dart';

class SplashPage extends StatefulWidget {
  static const String route = '/splash';
  final Duration? timeoutDuration;
  final VoidCallback? onTimeout;

  const SplashPage({
    super.key,
    this.timeoutDuration,
    this.onTimeout,
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late SplashController _controller;

  int _progressAnimationKey = 0;
  bool _showOnboarding = false;
  int _currentSlide = 0;
  Timer? _autoSlideTimer;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const Color primaryColor = Color(0xFF00A5AE);
  static const Color darkText = Color(0xFF242424);
  static const Color lightBg = Color(0xFFF8FAFB);
  static const Color cardBg = Color(0xFFFFFFFF);

  final _slideItems = [
    PrepareSplashItem(
      title: 'splash_slide1_title'.tr,
      content: 'splash_slide1_content'.tr,
      assetGenImage: CommonAssets.image.splash1,
    ),
    PrepareSplashItem(
      title: 'splash_slide2_title'.tr,
      content: 'splash_slide2_content'.tr,
      assetGenImage: CommonAssets.image.splash2,
    ),
    PrepareSplashItem(
      title: 'splash_slide3_title'.tr,
      content: 'splash_slide3_content'.tr,
      assetGenImage: CommonAssets.image.splash3,
    ),
    PrepareSplashItem(
      title: 'splash_slide4_title'.tr,
      content: 'splash_slide4_content'.tr,
      assetGenImage: CommonAssets.image.splash4,
    ),
    PrepareSplashItem(
      title: 'splash_slide5_title'.tr,
      content: 'splash_slide5_content'.tr,
      assetGenImage: CommonAssets.image.splash5,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showOnboarding = true;
        });
        _startAutoSlide();
      }
    });

    _controller = Get.find<SplashController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.loadProject(context);
        if (widget.timeoutDuration != null) {
          Timer(widget.timeoutDuration!, () {
            if (mounted) {
              widget.onTimeout?.call();
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    _animationController.dispose();
    if (Get.isRegistered<SplashController>()) {
      Get.delete<SplashController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 640),
            padding: const EdgeInsets.all(30),
            color: lightBg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildLogo(context),
                const SizedBox(height: 30),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildLoadingArea(context),
                ),
                if (_showOnboarding) ...[
                  const SizedBox(height: 20),
                  _buildOnboardingSlides(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentSlide < 4) {
        _currentSlide++;
      } else {
        _currentSlide = 0;
      }
      _pageController.animateToPage(
        _currentSlide,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _goToSlide(int index) {
    setState(() {
      _currentSlide = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    _startAutoSlide();
  }

  Widget _buildLogo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // CommonAssets.image.araCircleLogo.svg(width: 76, height: 76),
        AutoConfig.instance.domainType.isDferiDomain
            ? CommonAssets.image.dferiLogo.svg(width: 76, height: 76)
            : CommonAssets.image.araCircleLogo.svg(width: 76, height: 76),
        const SizedBox(width: 10),
        const Text(
          'Office',
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _controller.title ?? 'loading'.tr,
            style: const TextStyle(
              color: primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'splash_loading_note'.tr,
            style: TextStyle(
              color: darkText.withValues(alpha: 0.65),
              fontSize: 15,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 6,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                key: ValueKey(_progressAnimationKey),
                tween: Tween(begin: -0.25, end: 1.0),
                duration: const Duration(seconds: 2),
                builder: (context, value, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.25,
                    child: Transform.translate(
                      offset:
                          Offset(value * MediaQuery.of(context).size.width, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00A5AE), Color(0xFF0093CD)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                },
                onEnd: () {
                  if (mounted) {
                    setState(() {
                      _progressAnimationKey++;
                    });
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOnboardingSlides(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () => _goToSlide(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: _currentSlide == index ? 13 : 10,
                height: _currentSlide == index ? 13 : 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentSlide == index
                      ? primaryColor
                      : Colors.grey.withValues(alpha: 0.4),
                  boxShadow: _currentSlide == index
                      ? [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 15),
        Container(
          height: 400,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentSlide = index;
              });
            },
            itemCount: _slideItems.length,
            itemBuilder: (context, index) {
              final slideItem = _slideItems[index];
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          slideItem.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 40,
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00A5AE), Color(0xFF0093CD)],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      slideItem.content,
                      style: TextStyle(
                        fontSize: 16,
                        color: darkText.withValues(alpha: 0.8),
                        height: 1.6,
                        letterSpacing: -0.2,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 450),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 35,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: slideItem.assetGenImage.image(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PrepareSplashItem {
  final String title;
  final String content;
  final AssetGenImage assetGenImage;

  PrepareSplashItem({
    required this.title,
    required this.content,
    required this.assetGenImage,
  });
}
