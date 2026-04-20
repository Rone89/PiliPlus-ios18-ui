import 'package:PiliPlus/common/widgets/app_store_surface.dart';
import 'package:PiliPlus/common/widgets/custom_arc.dart';
import 'package:PiliPlus/utils/extension/theme_ext.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:flutter/material.dart';

class ActionItem extends StatelessWidget {
  const ActionItem({
    super.key,
    required this.icon,
    this.selectIcon,
    this.onTap,
    this.onLongPress,
    this.text,
    this.selectStatus = false,
    required this.semanticsLabel,
    this.expand = true,
    this.animation,
    this.onStartTriple,
    this.onCancelTriple,
  }) : assert(!selectStatus || selectIcon != null),
       _isThumbsUp = onStartTriple != null;

  final Icon icon;
  final Icon? selectIcon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? text;
  final bool selectStatus;
  final String semanticsLabel;
  final bool expand;
  final Animation<double>? animation;
  final VoidCallback? onStartTriple;
  final void Function([bool])? onCancelTriple;
  final bool _isThumbsUp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primary = !expand && colorScheme.isLight
        ? colorScheme.inversePrimary
        : colorScheme.primary;
    final iconColor = selectStatus ? primary : icon.color ?? colorScheme.outline;

    Widget iconChild = Icon(
      selectStatus ? selectIcon!.icon! : icon.icon,
      size: 18,
      color: iconColor,
    );

    if (animation != null) {
      iconChild = Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: animation!,
            builder: (context, child) => Arc(
              size: 28,
              color: primary,
              progress: -animation!.value,
            ),
          ),
          iconChild,
        ],
      );
    } else {
      iconChild = SizedBox.square(dimension: 28, child: iconChild);
    }

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.symmetric(
        horizontal: expand ? 4 : 0,
        vertical: expand ? 10 : 0,
      ),
      decoration: BoxDecoration(
        borderRadius: AppStoreSurfaces.sectionRadius,
        color: selectStatus
            ? primary.withValues(alpha: 0.12)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        border: Border.all(
          color: selectStatus
              ? primary.withValues(alpha: 0.16)
              : colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: expand
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectStatus
                        ? primary.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.22),
                  ),
                  child: Center(child: iconChild),
                ),
                const SizedBox(height: 8),
                _buildText(theme),
              ],
            )
          : Center(child: iconChild),
    );

    final child = Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: AppStoreSurfaces.sectionRadius,
        onTap: _isThumbsUp ? null : onTap,
        onLongPress: _isThumbsUp ? null : onLongPress,
        onSecondaryTap: PlatformUtils.isMobile || _isThumbsUp
            ? null
            : onLongPress,
        onTapDown: _isThumbsUp ? (_) => onStartTriple!() : null,
        onTapUp: _isThumbsUp ? (_) => onCancelTriple!(true) : null,
        onTapCancel: _isThumbsUp ? onCancelTriple : null,
        child: content,
      ),
    );

    return expand ? Expanded(child: child) : child;
  }

  Widget _buildText(ThemeData theme) {
    final hasText = text != null;
    final child = Text(
      hasText ? text! : '-',
      key: hasText ? ValueKey(text!) : null,
      style: TextStyle(
        color: selectStatus
            ? theme.colorScheme.primary
            : theme.colorScheme.outline,
        fontSize: theme.textTheme.labelSmall!.fontSize,
        fontWeight: selectStatus ? FontWeight.w600 : FontWeight.w500,
      ),
    );
    if (hasText) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: child,
      );
    }
    return child;
  }
}
