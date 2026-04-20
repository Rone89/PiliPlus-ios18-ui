import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/app_store_surface.dart';
import 'package:PiliPlus/common/widgets/custom_height_widget.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/common/widgets/scroll_physics.dart';
import 'package:PiliPlus/pages/common/common_page.dart';
import 'package:PiliPlus/pages/home/controller.dart';
import 'package:PiliPlus/pages/main/controller.dart';
import 'package:PiliPlus/pages/mine/controller.dart';
import 'package:PiliPlus/utils/extension/get_ext.dart';
import 'package:PiliPlus/utils/extension/size_ext.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends CommonPageState<HomePage>
    with AutomaticKeepAliveClientMixin {
  final _homeController = Get.putOrFind(HomeController.new);
  final _mainController = Get.find<MainController>();

  @override
  bool get needsCorrection => _homeController.hideTopBar;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    Widget tabBar;
    if (_homeController.tabs.length > 1) {
      tabBar = Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 2),
        child: FrostedCard(
          borderRadius: AppStoreSurfaces.pillRadius,
          blur: 18,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          child: SizedBox(
            height: 42,
            width: double.infinity,
            child: TabBar(
              controller: _homeController.tabController,
              tabs: _homeController.tabs.map((e) => Tab(text: e.label)).toList(),
              isScrollable: true,
              dividerColor: Colors.transparent,
              dividerHeight: 0,
              splashBorderRadius: AppStoreSurfaces.pillRadius,
              tabAlignment: TabAlignment.center,
              labelPadding: const EdgeInsets.symmetric(horizontal: 18),
              onTap: (_) {
                feedBack();
                if (!_homeController.tabController.indexIsChanging) {
                  _homeController.animateToTop();
                }
              },
            ),
          ),
        ),
      );
      if (_homeController.hideTopBar &&
          _mainController.barHideType == .instant) {
        tabBar = Material(
          color: theme.colorScheme.surface,
          child: tabBar,
        );
      }
    } else {
      tabBar = const SizedBox(height: 8);
    }
    return Column(
      children: [
        if (!_mainController.useSideBar &&
            MediaQuery.sizeOf(context).isPortrait)
          customAppBar(theme),
        tabBar,
        Expanded(
          child: onBuild(
            tabBarView(
              controller: _homeController.tabController,
              children: _homeController.tabs.map((e) => e.page).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget customAppBar(ThemeData theme) {
    const padding = EdgeInsets.fromLTRB(14, 8, 14, 0);
    final child = Row(
      children: [
        searchBar(theme),
        const SizedBox(width: 8),
        msgBadge(_mainController),
        const SizedBox(width: 8),
        userAvatar(theme: theme, mainController: _mainController),
      ],
    );
    if (_homeController.hideTopBar) {
      if (_mainController.barOffset case final barOffset?) {
        return Obx(
          () {
            final offset = barOffset.value;
            return CustomHeightWidget(
              offset: Offset(0, -offset),
              height: Style.topBarHeight - offset,
              child: Padding(
                padding: padding,
                child: child,
              ),
            );
          },
        );
      }
      if (_homeController.showTopBar case final showTopBar?) {
        return Obx(() {
          final showSearchBar = showTopBar.value;
          return AnimatedOpacity(
            opacity: showSearchBar ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: AnimatedContainer(
              curve: Curves.easeInOutCubicEmphasized,
              duration: const Duration(milliseconds: 500),
              height: showSearchBar ? Style.topBarHeight : 0,
              padding: padding,
              child: child,
            ),
          );
        });
      }
    }
    return Container(
      height: Style.topBarHeight,
      padding: padding,
      child: child,
    );
  }

  Widget searchBar(ThemeData theme) {
    return Expanded(
      child: FrostedCard(
        borderRadius: AppStoreSurfaces.pillRadius,
        blur: 18,
        color: AppStoreSurfaces.frostedColor(
          theme.colorScheme,
          lightOpacity: 0.9,
          darkOpacity: 0.84,
        ),
        child: SizedBox(
          height: 46,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: AppStoreSurfaces.pillRadius,
              splashColor: theme.colorScheme.primaryContainer.withValues(
                alpha: 0.24,
              ),
              onTap: () => Get.toNamed(
                '/search',
                parameters: _homeController.enableSearchWord
                    ? {'hintText': _homeController.defaultSearch.value}
                    : null,
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.75,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: theme.colorScheme.onPrimaryContainer,
                      semanticLabel: 'Search',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => Text(
                        _homeController.defaultSearch.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget userAvatar({
  required ThemeData theme,
  required MainController mainController,
}) {
  return Semantics(
    label: 'Mine',
    child: Obx(
      () {
        if (mainController.accountService.isLogin.value) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: AppStoreSurfaces.frostedColor(
                theme.colorScheme,
                lightOpacity: 0.84,
                darkOpacity: 0.8,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.08),
              ),
              boxShadow: AppStoreSurfaces.shadow(
                theme.colorScheme,
                opacity: 0.08,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  NetworkImgLayer(
                    type: .avatar,
                    width: 34,
                    height: 34,
                    src: mainController.accountService.face.value,
                  ),
                  Positioned.fill(
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: mainController.toMinePage,
                        splashColor: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                        customBorder: const CircleBorder(),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Obx(
                      () => MineController.anonymity.value
                          ? IgnorePointer(
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.secondaryContainer,
                                ),
                                child: Icon(
                                  size: 14,
                                  MdiIcons.incognito,
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return _toolbarBubble(
          theme,
          IconButton(
            tooltip: 'Sign in',
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
            ),
            onPressed: mainController.toMinePage,
            icon: Icon(
              Icons.person_rounded,
              size: 22,
              color: theme.colorScheme.primary,
            ),
          ),
        );
      },
    ),
  );
}

Widget msgBadge(MainController mainController) {
  return Obx(
    () {
      if (mainController.accountService.isLogin.value) {
        final count = mainController.msgUnReadCount.value;
        final isNumBadge = mainController.msgBadgeMode == .number;
        return Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return _toolbarBubble(
              theme,
              IconButton(
                tooltip: 'Messages',
                onPressed: () {
                  mainController
                    ..msgUnReadCount.value = ''
                    ..lastCheckUnreadAt = DateTime.now().millisecondsSinceEpoch;
                  Get.toNamed('/whisper');
                },
                icon: Badge(
                  isLabelVisible:
                      mainController.msgBadgeMode != .hidden && count.isNotEmpty,
                  alignment: isNumBadge
                      ? const Alignment(0.0, -0.85)
                      : const Alignment(1.0, -0.85),
                  label: isNumBadge && count.isNotEmpty ? Text(count) : null,
                  child: const Icon(Icons.notifications_none),
                ),
              ),
            );
          },
        );
      }
      return const SizedBox.shrink();
    },
  );
}

Widget _toolbarBubble(ThemeData theme, Widget child) {
  return FrostedCard(
    borderRadius: AppStoreSurfaces.pillRadius,
    blur: 16,
    elevated: false,
    color: AppStoreSurfaces.frostedColor(
      theme.colorScheme,
      lightOpacity: 0.88,
      darkOpacity: 0.8,
    ),
    child: SizedBox(
      width: 42,
      height: 42,
      child: child,
    ),
  );
}
