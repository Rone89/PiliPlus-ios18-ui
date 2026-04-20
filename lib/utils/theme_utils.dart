import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/app_store_surface.dart';
import 'package:PiliPlus/main.dart';
import 'package:PiliPlus/utils/extension/theme_ext.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract final class ThemeUtils {
  static ThemeData getThemeData({
    required ColorScheme colorScheme,
    required bool isDynamic,
    bool isDark = false,
  }) {
    final appFontWeight = Pref.appFontWeight.clamp(
      -1,
      FontWeight.values.length - 1,
    );
    final fontWeight = appFontWeight == -1
        ? null
        : FontWeight.values[appFontWeight];
    late final textStyle = TextStyle(fontWeight: fontWeight);
    final scaffoldBackground = Color.alphaBlend(
      colorScheme.primary.withValues(alpha: isDark ? 0.05 : 0.035),
      colorScheme.surface,
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: AppStoreSurfaces.sectionRadius,
      borderSide: BorderSide(
        color: colorScheme.outline.withValues(alpha: isDark ? 0.2 : 0.08),
      ),
    );
    ThemeData themeData = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBackground,
      canvasColor: scaffoldBackground,
      textTheme: fontWeight == null
          ? null
          : TextTheme(
              displayLarge: textStyle,
              displayMedium: textStyle,
              displaySmall: textStyle,
              headlineLarge: textStyle,
              headlineMedium: textStyle,
              headlineSmall: textStyle,
              titleLarge: textStyle,
              titleMedium: textStyle,
              titleSmall: textStyle,
              bodyLarge: textStyle,
              bodyMedium: textStyle,
              bodySmall: textStyle,
              labelLarge: textStyle,
              labelMedium: textStyle,
              labelSmall: textStyle,
            ),
      tabBarTheme: fontWeight == null
          ? TabBarThemeData(
              dividerColor: Colors.transparent,
              labelColor: colorScheme.onSurface,
              unselectedLabelColor: colorScheme.outline,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: AppStoreSurfaces.pillRadius,
                color: AppStoreSurfaces.frostedColor(colorScheme),
                boxShadow: AppStoreSurfaces.shadow(colorScheme, opacity: 0.08),
              ),
              splashBorderRadius: AppStoreSurfaces.pillRadius,
            )
          : TabBarThemeData(
              labelStyle: textStyle,
              dividerColor: Colors.transparent,
              labelColor: colorScheme.onSurface,
              unselectedLabelColor: colorScheme.outline,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: AppStoreSurfaces.pillRadius,
                color: AppStoreSurfaces.frostedColor(colorScheme),
                boxShadow: AppStoreSurfaces.shadow(colorScheme, opacity: 0.08),
              ),
              splashBorderRadius: AppStoreSurfaces.pillRadius,
            ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 17,
          color: colorScheme.onSurface,
          fontWeight: fontWeight ?? FontWeight.w600,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppStoreSurfaces.frostedColor(
          colorScheme,
          lightOpacity: 0.9,
          darkOpacity: 0.84,
        ),
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primaryContainer.withValues(alpha: 0.9),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        actionTextColor: colorScheme.primary,
        backgroundColor: colorScheme.secondaryContainer,
        closeIconColor: colorScheme.secondary,
        contentTextStyle: TextStyle(color: colorScheme.onSecondaryContainer),
        elevation: 20,
      ),
      popupMenuTheme: PopupMenuThemeData(
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: AppStoreSurfaces.sectionRadius,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: AppStoreSurfaces.frostedColor(colorScheme),
        shape: const RoundedRectangleBorder(
          borderRadius: AppStoreSurfaces.cardRadius,
        ),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        // ignore: deprecated_member_use
        year2023: false,
        refreshBackgroundColor: colorScheme.onSecondary,
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: TextStyle(
          fontSize: 18,
          color: colorScheme.onSurface,
          fontWeight: fontWeight,
        ),
        backgroundColor: AppStoreSurfaces.frostedColor(colorScheme),
        shape: const RoundedRectangleBorder(
          borderRadius: AppStoreSurfaces.cardRadius,
        ),
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppStoreSurfaces.frostedColor(colorScheme),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: Style.bottomSheetRadius,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.42 : 0.52,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
        ),
        floatingLabelStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: AppStoreSurfaces.pillRadius,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: AppStoreSurfaces.pillRadius,
          ),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: isDark ? 0.25 : 0.12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: AppStoreSurfaces.sectionRadius,
        ),
        iconColor: colorScheme.onSurfaceVariant,
      ),
      // ignore: deprecated_member_use
      sliderTheme: const SliderThemeData(year2023: false),
      tooltipTheme: TooltipThemeData(
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[700]!.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        selectionHandleColor: colorScheme.primary,
      ),
      switchTheme: const SwitchThemeData(
        padding: .zero,
        materialTapTargetSize: .shrinkWrap,
        thumbIcon: WidgetStateProperty<Icon?>.fromMap(
          <WidgetStatesConstraint, Icon?>{
            WidgetState.selected: Icon(Icons.done),
            WidgetState.any: null,
          },
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
        },
      ),
    );
    if (isDark) {
      if (Pref.isPureBlackTheme) {
        themeData = darkenTheme(themeData);
      }
      if (Pref.darkVideoPage) {
        MyApp.darkThemeData = themeData;
      }
    }
    return themeData;
  }

  static ThemeData darkenTheme(ThemeData themeData) {
    final colorScheme = themeData.colorScheme;
    final color = colorScheme.surfaceContainerHighest.darken(0.7);
    return themeData.copyWith(
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: themeData.appBarTheme.copyWith(
        backgroundColor: Colors.black,
      ),
      cardTheme: themeData.cardTheme.copyWith(
        color: Colors.black,
      ),
      dialogTheme: themeData.dialogTheme.copyWith(
        backgroundColor: color,
      ),
      bottomSheetTheme: themeData.bottomSheetTheme.copyWith(
        backgroundColor: color,
      ),
      bottomNavigationBarTheme: themeData.bottomNavigationBarTheme.copyWith(
        backgroundColor: color,
      ),
      navigationBarTheme: themeData.navigationBarTheme.copyWith(
        backgroundColor: color,
      ),
      navigationRailTheme: themeData.navigationRailTheme.copyWith(
        backgroundColor: Colors.black,
      ),
      colorScheme: colorScheme.copyWith(
        primary: colorScheme.primary.darken(0.1),
        onPrimary: colorScheme.onPrimary.darken(0.1),
        primaryContainer: colorScheme.primaryContainer.darken(0.1),
        onPrimaryContainer: colorScheme.onPrimaryContainer.darken(0.1),
        inversePrimary: colorScheme.inversePrimary.darken(0.1),
        secondary: colorScheme.secondary.darken(0.1),
        onSecondary: colorScheme.onSecondary.darken(0.1),
        secondaryContainer: colorScheme.secondaryContainer.darken(0.1),
        onSecondaryContainer: colorScheme.onSecondaryContainer.darken(0.1),
        error: colorScheme.error.darken(0.1),
        surface: Colors.black,
        onSurface: colorScheme.onSurface.darken(0.15),
        surfaceTint: colorScheme.surfaceTint.darken(),
        inverseSurface: colorScheme.inverseSurface.darken(),
        onInverseSurface: colorScheme.onInverseSurface.darken(),
        surfaceContainer: colorScheme.surfaceContainer.darken(),
        surfaceContainerHigh: colorScheme.surfaceContainerHigh.darken(),
        surfaceContainerHighest: colorScheme.surfaceContainerHighest.darken(
          0.4,
        ),
      ),
    );
  }
}
