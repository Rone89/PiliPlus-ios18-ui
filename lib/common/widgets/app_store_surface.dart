import 'dart:ui';

import 'package:flutter/material.dart';

abstract final class AppStoreSurfaces {
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(28));
  static const BorderRadius sectionRadius = BorderRadius.all(
    Radius.circular(24),
  );
  static const BorderRadius pillRadius = BorderRadius.all(
    Radius.circular(999),
  );

  static Color frostedColor(
    ColorScheme colorScheme, {
    double lightOpacity = 0.82,
    double darkOpacity = 0.76,
  }) {
    final base = colorScheme.brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.4);
    final surface = colorScheme.surface.withValues(
      alpha: colorScheme.brightness == Brightness.dark
          ? darkOpacity
          : lightOpacity,
    );
    return Color.alphaBlend(surface, base);
  }

  static BorderSide border(ColorScheme colorScheme) => BorderSide(
    color: colorScheme.outline.withValues(
      alpha: colorScheme.brightness == Brightness.dark ? 0.2 : 0.08,
    ),
  );

  static List<BoxShadow> shadow(
    ColorScheme colorScheme, {
    double opacity = 0.12,
  }) => [
    BoxShadow(
      color: colorScheme.shadow.withValues(
        alpha: colorScheme.brightness == Brightness.dark ? 0.28 : opacity,
      ),
      blurRadius: 32,
      offset: const Offset(0, 18),
      spreadRadius: -18,
    ),
  ];

  static Gradient backgroundGradient(ColorScheme colorScheme) {
    final surface = colorScheme.surface;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.alphaBlend(
          colorScheme.primary.withValues(
            alpha: colorScheme.brightness == Brightness.dark ? 0.18 : 0.12,
          ),
          surface,
        ),
        Color.alphaBlend(
          colorScheme.secondary.withValues(
            alpha: colorScheme.brightness == Brightness.dark ? 0.1 : 0.07,
          ),
          surface,
        ),
        surface,
      ],
    );
  }
}

class AppStoreBackground extends StatelessWidget {
  const AppStoreBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppStoreSurfaces.backgroundGradient(colorScheme),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.95, -1.0),
                  radius: 1.15,
                  colors: [
                    colorScheme.primary.withValues(
                      alpha: colorScheme.brightness == Brightness.dark
                          ? 0.14
                          : 0.1,
                    ),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(1.0, -0.85),
                  radius: 1.0,
                  colors: [
                    colorScheme.secondary.withValues(
                      alpha: colorScheme.brightness == Brightness.dark
                          ? 0.08
                          : 0.06,
                    ),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class FrostedCard extends StatelessWidget {
  const FrostedCard({
    super.key,
    required this.child,
    this.borderRadius = AppStoreSurfaces.cardRadius,
    this.blur = 22,
    this.padding,
    this.color,
    this.borderSide,
    this.elevated = true,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final BorderSide? borderSide;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: color ?? AppStoreSurfaces.frostedColor(colorScheme),
            border: Border.fromBorderSide(
              borderSide ?? AppStoreSurfaces.border(colorScheme),
            ),
            boxShadow: elevated ? AppStoreSurfaces.shadow(colorScheme) : null,
          ),
          child: padding == null ? child : Padding(padding: padding!, child: child),
        ),
      ),
    );
  }
}
