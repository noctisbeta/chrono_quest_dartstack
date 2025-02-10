import 'package:flutter/material.dart';

final class ChronoBarAnimationManager {
  ChronoBarAnimationManager({
    required this.vsync,
  })  : _resetScrollAnimationController = AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 800),
        ),
        _resetZoomAnimationController = AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 800),
        ),
        _chronoBarStateAnimationController = AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 300),
        ),
        _shadowHorizontalAnimationController = AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 300),
        ),
        _shadowVerticalAnimationController = AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 300),
        ),
        _shadowPulseAnimationController = AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 200),
        ),
        _confirmedShadowAnimationController = AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 800),
        ) {
    resetScrollAnimation = const AlwaysStoppedAnimation(0);
    resetZoomAnimation = const AlwaysStoppedAnimation(0);
    chronoBarStateAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _chronoBarStateAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    shadowHorizontalAnimation = const AlwaysStoppedAnimation(0);
    shadowVerticalAnimation = const AlwaysStoppedAnimation(0);
    shadowPulseAnimation = const AlwaysStoppedAnimation(0);
    confirmedShadowAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(
      CurvedAnimation(
        parent: _confirmedShadowAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    confirmedShadowAnimation?.addListener(_confirmedShadowAnimationListener);
    _chronoBarStateAnimationController.forward();
  }

  void dispose() {
    _resetScrollAnimationController.dispose();
    _resetZoomAnimationController.dispose();

    _chronoBarStateAnimationController.dispose();

    _shadowHorizontalAnimationController.dispose();
    _shadowVerticalAnimationController.dispose();
    _shadowPulseAnimationController.dispose();
    _confirmedShadowAnimationController.dispose();
  }

  final TickerProvider vsync;

  final AnimationController _resetScrollAnimationController;
  Animation<double>? resetScrollAnimation;

  final AnimationController _resetZoomAnimationController;
  Animation<double>? resetZoomAnimation;

  final AnimationController _chronoBarStateAnimationController;
  Animation<double>? chronoBarStateAnimation;

  final AnimationController _shadowHorizontalAnimationController;
  Animation<double>? shadowHorizontalAnimation;
  final AnimationController _shadowVerticalAnimationController;
  Animation<double>? shadowVerticalAnimation;
  final AnimationController _shadowPulseAnimationController;
  Animation<double>? shadowPulseAnimation;
  final AnimationController _confirmedShadowAnimationController;
  Animation<double>? confirmedShadowAnimation;

  Listenable get mergedAnimations => Listenable.merge([
        resetScrollAnimation,
        resetZoomAnimation,
        chronoBarStateAnimation,
        shadowHorizontalAnimation,
        shadowVerticalAnimation,
        shadowPulseAnimation,
        confirmedShadowAnimation,
        horizontalDelta,
        verticalDelta,
        shadowPulseDelta,
        confirmedShadowSpread,
        isConfirmed,
      ]);

  final ValueNotifier<double> horizontalDelta = ValueNotifier<double>(0);
  final ValueNotifier<double> verticalDelta = ValueNotifier<double>(0);
  final ValueNotifier<double> shadowPulseDelta = ValueNotifier<double>(0);
  final ValueNotifier<double> confirmedShadowSpread = ValueNotifier<double>(0);
  final ValueNotifier<bool> isConfirmed = ValueNotifier<bool>(false);

  void toggleAnimation() {
    if (_chronoBarStateAnimationController.isCompleted ||
        _chronoBarStateAnimationController.status == AnimationStatus.forward) {
      _chronoBarStateAnimationController.reverse();
    } else if (_chronoBarStateAnimationController.status ==
        AnimationStatus.reverse) {
      _chronoBarStateAnimationController.forward();
    } else {
      _chronoBarStateAnimationController.forward();
    }
  }

  void _shadowVerticalAnimationListener() {
    verticalDelta.value = shadowVerticalAnimation!.value;
  }

  void _shadowHorizontalAnimationListener() {
    horizontalDelta.value = shadowHorizontalAnimation!.value;
  }

  void startVerticalShadowAnimation() {
    _shadowVerticalAnimationController
      ..removeListener(_shadowVerticalAnimationListener)
      ..value = 0;

    shadowVerticalAnimation =
        Tween<double>(begin: verticalDelta.value, end: 0).animate(
      CurvedAnimation(
        parent: _shadowVerticalAnimationController,
        curve: Curves.linear,
      ),
    );

    _shadowVerticalAnimationController
      ..removeListener(_shadowVerticalAnimationListener)
      ..addListener(_shadowVerticalAnimationListener)
      ..forward();
  }

  void startHorizontalShadowAnimation() {
    _shadowHorizontalAnimationController
      ..removeListener(_shadowHorizontalAnimationListener)
      ..value = 0;

    shadowHorizontalAnimation =
        Tween<double>(begin: horizontalDelta.value, end: 0).animate(
      CurvedAnimation(
        parent: _shadowHorizontalAnimationController,
        curve: Curves.linear,
      ),
    );

    _shadowHorizontalAnimationController
      ..removeListener(_shadowHorizontalAnimationListener)
      ..addListener(_shadowHorizontalAnimationListener)
      ..forward();
  }

  void _shadowPulseAnimationListener() {
    shadowPulseDelta.value = shadowPulseAnimation!.value;

    if (_shadowPulseAnimationController.isCompleted) {
      _shadowPulseAnimationController.reverse();
    }
  }

  void startShadowPulseAnimation() {
    _shadowPulseAnimationController
      ..removeListener(_shadowPulseAnimationListener)
      ..value = 0;

    shadowPulseAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _shadowPulseAnimationController,
        curve: Curves.easeInOutSine,
      ),
    );

    _shadowPulseAnimationController
      ..removeListener(_shadowPulseAnimationListener)
      ..addListener(_shadowPulseAnimationListener)
      ..forward();
  }

  void _confirmedShadowAnimationListener() {
    confirmedShadowSpread.value = confirmedShadowAnimation!.value;

    if (isConfirmed.value) {
      if (_confirmedShadowAnimationController.isCompleted) {
        _confirmedShadowAnimationController.reverse();
      } else if (_confirmedShadowAnimationController.isDismissed) {
        _confirmedShadowAnimationController.forward();
      }
    } else {
      _confirmedShadowAnimationController.reverse();
    }
  }

  void runConfirmedShadowAnimation() {
    if (_confirmedShadowAnimationController.isCompleted ||
        _confirmedShadowAnimationController.status == AnimationStatus.forward) {
      _confirmedShadowAnimationController.reverse();
    } else if (_confirmedShadowAnimationController.status ==
        AnimationStatus.reverse) {
      _confirmedShadowAnimationController.forward();
    } else {
      _confirmedShadowAnimationController.forward();
    }
  }

  void resetScroll(
    double currentScrollOffset,
    void Function() callback,
  ) {
    _resetScrollAnimationController
      ..removeListener(callback)
      ..value = 0;

    resetScrollAnimation =
        Tween<double>(begin: currentScrollOffset, end: 0).animate(
      CurvedAnimation(
        parent: _resetScrollAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _resetScrollAnimationController
      ..removeListener(callback)
      ..addListener(callback)
      ..forward();
  }

  void resetZoom(
    double currentZoomFactor,
    void Function() callback,
  ) {
    _resetZoomAnimationController
      ..removeListener(callback)
      ..value = 0;

    resetZoomAnimation =
        Tween<double>(begin: currentZoomFactor, end: 3).animate(
      CurvedAnimation(
        parent: _resetZoomAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _resetZoomAnimationController
      ..removeListener(callback)
      ..addListener(callback)
      ..forward();
  }
}
