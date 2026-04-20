import 'dart:async';

import 'package:PiliPlus/common/assets.dart';
import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/app_store_surface.dart';
import 'package:PiliPlus/common/widgets/flutter/list_tile.dart';
import 'package:PiliPlus/common/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/common\widgets/image/network_img_layer.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/nav_bar_config.dart';
import 'package:PiliPlus/models_new/fav/fav_folder/list.dart';
import 'package:PiliPlus/pages/common/common_page.dart';
import 'package:PiliPlus/pages/home/view.dart';
import 'package:PiliPlus/pages/login/controller.dart';
import 'package:PiliPlus/pages/main/controller.dart';
import 'package:PiliPlus/pages/mine/controller.dart';
import 'package:PiliPlus/pages/mine/widgets/item.dart';
import 'package:PiliPlus/utils/extension/get_ext.dart';
import 'package:PiliPlus/utils/extension/num_ext.dart';
import 'package:PiliPlus/utils/extension/theme_ext.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart' hide ListTile;
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key, this.showBackBtn = false});

  final bool showBackBtn;

  @override
  State<MinePage> createState() => _MediaPageState();
}

class _MediaPageState extends CommonPageState<MinePage>
    with AutomaticKeepAliveClientMixin {
  final MineController controller = Get.putOrFind(MineController.new);
  late final MainController _mainController = Get.find<MainController>();

  @override
  bool get wantKeepAlive => true;

  bool get checkPage =>
      _mainController.navigationBars[0] != NavigationBarType.mine &&
      _mainController.selectedIndex.value == 0;

  @override
  bool onNotificationType1(UserScrollNotification notification) {
    if (checkPage) {
      return false;
    }
    return super.onNotificationType1(notification);
  }

  @override
  bool onNotificationType2(ScrollNotification notification) {
    if (checkPage) {
      return false;
    }
    return super.onNotificationType2(notification);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final secondary = theme.colorScheme.secondary;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: _buildHeaderActions,
        ),
        Expanded(
          child: Material(
            type: MaterialType.transparency,
            child: refreshIndicator(
              onRefresh: controller.onRefresh,
              child: onBuild(
                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 120),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    _buildUserInfo(theme, secondary),
                    const SizedBox(height: 14),
                    _buildActions(secondary),
                    const SizedBox(height: 16),
                    Obx(
                      () => controller.loadingState.value is Loading
                          ? const SizedBox.shrink()
                          : _buildFav(theme, secondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(Color primary) {
    return FrostedCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: controller.list
            .map(
              (e) => Flexible(
                child: InkWell(
                  onTap: e.onTap,
                  borderRadius: AppStoreSurfaces.sectionRadius,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 96),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: AppStoreSurfaces.sectionRadius,
                          color: primary.withValues(alpha: 0.08),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.14),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(size: e.size, e.icon, color: primary),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              e.title,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget get _buildHeaderActions {
    const iconSize = 22.0;
    const padding = EdgeInsets.all(8);
    const style = ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap);
    return Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.showBackBtn)
          const Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 8),
                child: BackButton(),
              ),
            ),
          ),
        if (!_mainController.hasHome) ...[
          _headerAction(
            child: IconButton(
              iconSize: iconSize,
              padding: padding,
              style: style,
              tooltip: 'Search',
              onPressed: () => Get.toNamed('/search'),
              icon: const Icon(Icons.search),
            ),
          ),
          msgBadge(_mainController),
        ],
        if (GStorage.reply != null)
          _headerAction(
            child: IconButton(
              iconSize: iconSize,
              padding: padding,
              style: style,
              tooltip: 'Reply history',
              onPressed: () => Get.toNamed('/myReply'),
              icon: const Icon(Icons.message_outlined),
            ),
          ),
        Obx(
          () {
            final anonymity = MineController.anonymity.value;
            return _headerAction(
              child: IconButton(
                iconSize: iconSize,
                padding: padding,
                style: style,
                tooltip: "${anonymity ? 'Exit' : 'Enter'} incognito",
                onPressed: MineController.onChangeAnonymity,
                icon: anonymity
                    ? const Icon(MdiIcons.incognito)
                    : const Icon(MdiIcons.incognitoOff),
              ),
            );
          },
        ),
        _headerAction(
          child: IconButton(
            iconSize: iconSize,
            padding: padding,
            style: style,
            tooltip: 'Switch account',
            onPressed: () => LoginPageController.switchAccountDialog(context),
            icon: const Icon(Icons.switch_account_outlined),
          ),
        ),
        Obx(
          () => _headerAction(
            child: IconButton(
              iconSize: iconSize,
              padding: padding,
              style: style,
              tooltip: 'Switch theme',
              onPressed: controller.onChangeTheme,
              icon: controller.themeType.value.icon,
            ),
          ),
        ),
        _headerAction(
          child: IconButton(
            iconSize: iconSize,
            padding: padding,
            style: style,
            tooltip: 'Settings',
            onPressed: () => Get.toNamed('/setting', preventDuplicates: false),
            icon: const Icon(Icons.settings_outlined),
          ),
        ),
      ],
    );
  }

  Widget _headerAction({required Widget child}) {
    return FrostedCard(
      borderRadius: AppStoreSurfaces.pillRadius,
      blur: 16,
      elevated: false,
      child: SizedBox(
        width: 42,
        height: 42,
        child: child,
      ),
    );
  }

  Widget _buildUserInfo(ThemeData theme, Color secondary) {
    final countStyle = TextStyle(
      fontSize: theme.textTheme.titleMedium!.fontSize,
      fontWeight: FontWeight.bold,
    );
    final labelStyle = theme.textTheme.labelMedium!.copyWith(
      color: theme.colorScheme.outline,
    );
    final coinLabelStyle = TextStyle(
      fontSize: theme.textTheme.labelMedium!.fontSize,
      color: theme.colorScheme.outline,
    );
    final coinValStyle = TextStyle(
      fontSize: theme.textTheme.labelMedium!.fontSize,
      fontWeight: FontWeight.bold,
      color: secondary,
    );
    return Obx(() {
      final userInfo = controller.userInfo.value;
      final levelInfo = userInfo.levelInfo;
      final hasLevel = levelInfo != null;
      final isVip = userInfo.vipStatus != null && userInfo.vipStatus! > 0;
      final userStat = controller.userStat.value;
      return FrostedCard(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: controller.onLogin,
              onLongPress: () {
                Feedback.forLongPress(context);
                controller.onLogin(true);
              },
              onSecondaryTap: PlatformUtils.isMobile
                  ? null
                  : () => controller.onLogin(true),
              child: Row(
                children: [
                  userInfo.face != null
                      ? Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: AppStoreSurfaces.shadow(
                              theme.colorScheme,
                              opacity: 0.12,
                            ),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              NetworkImgLayer(
                                src: userInfo.face,
                                type: .avatar,
                                width: 62,
                                height: 62,
                              ),
                              if (isVip)
                                Positioned(
                                  right: -1,
                                  bottom: -2,
                                  child: Image.asset(
                                    Assets.vipIcon,
                                    height: 19,
                                    cacheHeight: 19.cacheSize(context),
                                    semanticLabel: 'VIP',
                                  ),
                                ),
                            ],
                          ),
                        )
                      : ClipOval(
                          child: Image.asset(
                            width: 62,
                            height: 62,
                            cacheHeight: 62.cacheSize(context),
                            Assets.avatarPlaceHolder,
                            semanticLabel: 'Default avatar',
                          ),
                        ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                userInfo.uname ?? 'Tap to sign in',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isVip && userInfo.vipType == 2
                                      ? theme.colorScheme.vipColor
                                      : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Image.asset(
                              Utils.levelName(
                                levelInfo?.currentLevel ?? 0,
                                isSeniorMember: userInfo.isSeniorMember == 1,
                              ),
                              height: 11,
                              cacheHeight: 11.cacheSize(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: 'Coins ', style: coinLabelStyle),
                              TextSpan(
                                text: userInfo.money?.toString() ?? '-',
                                style: coinValStyle,
                              ),
                              TextSpan(text: '      EXP ', style: coinLabelStyle),
                              TextSpan(
                                text: levelInfo?.currentExp?.toString() ?? '-',
                                style: coinValStyle,
                              ),
                              TextSpan(
                                text: "/${levelInfo?.nextExp ?? '-'}",
                                style: coinLabelStyle,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          minHeight: 4,
                          value: hasLevel
                              ? levelInfo.currentExp! / levelInfo.nextExp!
                              : 0,
                          backgroundColor: theme.colorScheme.outline.withValues(
                            alpha: 0.18,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(secondary),
                          stopIndicatorColor: Colors.transparent,
                          borderRadius: AppStoreSurfaces.pillRadius,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _statButton(
                  count: userStat.dynamicCount,
                  countStyle: countStyle,
                  name: 'Dynamics',
                  labelStyle: labelStyle,
                  onTap: () => controller.push('memberDynamics'),
                ),
                const SizedBox(width: 10),
                _statButton(
                  count: userStat.following,
                  countStyle: countStyle,
                  name: 'Following',
                  labelStyle: labelStyle,
                  onTap: () => controller.push('follow'),
                ),
                const SizedBox(width: 10),
                _statButton(
                  count: userStat.follower,
                  countStyle: countStyle,
                  name: 'Followers',
                  labelStyle: labelStyle,
                  onTap: () => controller.push('fan'),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _statButton({
    required int? count,
    required TextStyle countStyle,
    required String name,
    required TextStyle? labelStyle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppStoreSurfaces.sectionRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: AppStoreSurfaces.sectionRadius,
            color: Colors.white.withValues(alpha: 0.04),
          ),
          child: Column(
            children: [
              Text(
                count?.toString() ?? '-',
                style: countStyle,
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: labelStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _autoRefresh() => Future.delayed(
    const Duration(milliseconds: 150),
    () => controller.onRefresh(isManual: false),
  );

  Widget _buildFav(ThemeData theme, Color secondary) {
    return FrostedCard(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          ListTile(
            onTap: () => Get.toNamed('/fav')?.whenComplete(_autoRefresh),
            dense: true,
            title: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Favorites  ',
                      style: TextStyle(
                        fontSize: theme.textTheme.titleMedium!.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (controller.favFolderCount != null)
                      TextSpan(
                        text: "${controller.favFolderCount}  ",
                        style: TextStyle(
                          fontSize: theme.textTheme.titleSmall!.fontSize,
                          color: secondary,
                        ),
                      ),
                    WidgetSpan(
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            trailing: IconButton(
              tooltip: 'Refresh',
              onPressed: controller.onRefresh,
              icon: const Icon(Icons.refresh, size: 20),
            ),
          ),
          _buildFavBody(theme, secondary, controller.loadingState.value),
        ],
      ),
    );
  }

  Widget _buildFavBody(
    ThemeData theme,
    Color secondary,
    LoadingState loadingState,
  ) {
    return switch (loadingState) {
      Loading() => const SizedBox.shrink(),
      Success(:final response) => Builder(
        builder: (context) {
          List<FavFolderInfo>? favFolderList = response.list;
          if (favFolderList == null || favFolderList.isEmpty) {
            return const SizedBox.shrink();
          }
          bool flag = (controller.favFolderCount ?? 0) > favFolderList.length;
          return SizedBox(
            height: 208,
            child: ListView.separated(
              controller: controller.scrollController,
              padding: const EdgeInsets.only(left: 20, top: 10, right: 20),
              itemCount: response.list.length + (flag ? 1 : 0),
              itemBuilder: (context, index) {
                if (flag && index == favFolderList.length) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 35),
                    child: Center(
                      child: FrostedCard(
                        borderRadius: AppStoreSurfaces.pillRadius,
                        elevated: false,
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: IconButton(
                            tooltip: 'More',
                            padding: EdgeInsets.zero,
                            onPressed: () =>
                                Get.toNamed('/fav')?.whenComplete(_autoRefresh),
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: secondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return FavFolderItem(
                    heroTag: Utils.generateRandomString(8),
                    item: response.list[index],
                    onPop: _autoRefresh,
                  );
                }
              },
              scrollDirection: Axis.horizontal,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
            ),
          );
        },
      ),
      Error(:final errMsg) => SizedBox(
        height: 160,
        child: Center(
          child: Text(
            errMsg ?? '',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    };
  }
}
