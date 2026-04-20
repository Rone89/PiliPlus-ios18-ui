import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/app_store_surface.dart';
import 'package:PiliPlus/common\widgets/badge.dart';
import 'package:PiliPlus/common\widgets/flutter/layout_builder.dart';
import 'package:PiliPlus/common\widgets/image/image_save.dart';
import 'package:PiliPlus/common\widgets/image/network_img_layer.dart';
import 'package:PiliPlus/common\widgets/stat/stat.dart';
import 'package:PiliPlus/common\widgets/video_popup_menu.dart';
import 'package:PiliPlus/http/search.dart';
import 'package:PiliPlus/models/common/badge_type.dart';
import 'package:PiliPlus/models/common/stat_type.dart';
import 'package:PiliPlus/models/model_rec_video_item.dart';
import 'package:PiliPlus/utils/app_scheme.dart';
import 'package:PiliPlus/utils/date_utils.dart';
import 'package:PiliPlus/utils/duration_utils.dart';
import 'package:PiliPlus/utils/id_utils.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart' hide LayoutBuilder;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:intl/intl.dart';

class VideoCardV extends StatelessWidget {
  final BaseRcmdVideoItemModel videoItem;
  final VoidCallback? onRemove;

  const VideoCardV({
    super.key,
    required this.videoItem,
    this.onRemove,
  });

  Future<void> onPushDetail(String heroTag) async {
    String? goto = videoItem.goto;
    switch (goto) {
      case 'bangumi':
        PageUtils.viewPgc(epId: videoItem.param!);
        break;
      case 'av':
        String bvid = videoItem.bvid ?? IdUtils.av2bv(videoItem.aid!);
        int? cid =
            videoItem.cid ??
            await SearchHttp.ab2c(aid: videoItem.aid, bvid: bvid);
        if (cid != null) {
          PageUtils.toVideoPage(
            aid: videoItem.aid,
            bvid: bvid,
            cid: cid,
            cover: videoItem.cover,
            title: videoItem.title,
          );
        }
        break;
      case 'picture':
        try {
          PiliScheme.routePushFromUrl(videoItem.uri!);
        } catch (err) {
          SmartDialog.showToast(err.toString());
        }
        break;
      default:
        if (videoItem.uri?.isNotEmpty == true) {
          PiliScheme.routePushFromUrl(videoItem.uri!);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    void onLongPress() => imageSaveDialog(
      title: videoItem.title,
      cover: videoItem.cover,
      bvid: videoItem.bvid,
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        FrostedCard(
          borderRadius: AppStoreSurfaces.cardRadius,
          child: InkWell(
            borderRadius: AppStoreSurfaces.cardRadius,
            onTap: () => onPushDetail(Utils.makeHeroTag(videoItem.aid)),
            onLongPress: onLongPress,
            onSecondaryTap: PlatformUtils.isMobile ? null : onLongPress,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: Style.aspectRatio,
                  child: LayoutBuilder(
                    builder: (context, boxConstraints) {
                      double maxWidth = boxConstraints.maxWidth;
                      double maxHeight = boxConstraints.maxHeight;
                      return ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            NetworkImgLayer(
                              src: videoItem.cover,
                              width: maxWidth,
                              height: maxHeight,
                              type: .emote,
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.04),
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.3),
                                  ],
                                ),
                              ),
                            ),
                            if (videoItem.duration > 0)
                              PBadge(
                                bottom: 10,
                                right: 10,
                                size: PBadgeSize.small,
                                type: PBadgeType.gray,
                                text: DurationUtils.formatDuration(
                                  videoItem.duration,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            videoItem.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              height: 1.35,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        videoStat(context, theme),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (videoItem.goto == 'bangumi')
                              PBadge(
                                text: videoItem.pgcBadge,
                                isStack: false,
                                size: PBadgeSize.small,
                                type: PBadgeType.line_primary,
                                fontSize: 9,
                              ),
                            if (videoItem.rcmdReason != null)
                              PBadge(
                                text: videoItem.rcmdReason,
                                isStack: false,
                                size: PBadgeSize.small,
                                type: PBadgeType.secondary,
                              ),
                            if (videoItem.goto == 'picture')
                              const PBadge(
                                text: 'Dynamic',
                                isStack: false,
                                size: PBadgeSize.small,
                                type: PBadgeType.line_primary,
                                fontSize: 9,
                              ),
                            if (videoItem.isFollowed)
                              const PBadge(
                                text: 'Following',
                                isStack: false,
                                size: PBadgeSize.small,
                                type: PBadgeType.secondary,
                              ),
                            Text(
                              videoItem.owner.name.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              semanticsLabel: 'UP ${videoItem.owner.name}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (videoItem.goto == 'av')
          Positioned(
            top: 10,
            right: 10,
            child: FrostedCard(
              borderRadius: AppStoreSurfaces.pillRadius,
              blur: 12,
              elevated: false,
              child: SizedBox(
                width: 30,
                height: 30,
                child: VideoPopupMenu(
                  iconSize: 17,
                  videoItem: videoItem,
                  onRemove: onRemove,
                ),
              ),
            ),
          ),
      ],
    );
  }

  static final shortFormat = DateFormat('M-d');
  static final longFormat = DateFormat('yy-M-d');

  Widget videoStat(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        StatWidget(
          type: StatType.play,
          value: videoItem.stat.view,
        ),
        if (videoItem.goto != 'picture') ...[
          const SizedBox(width: 4),
          StatWidget(
            type: StatType.danmaku,
            value: videoItem.stat.danmu,
          ),
        ],
        if (videoItem is RcmdVideoItemModel) ...[
          const Spacer(),
          Text.rich(
            maxLines: 1,
            TextSpan(
              style: TextStyle(
                fontSize: theme.textTheme.labelSmall!.fontSize,
                color: theme.colorScheme.outline.withValues(alpha: 0.8),
              ),
              text: DateFormatUtils.dateFormat(
                videoItem.pubdate,
                short: shortFormat,
                long: longFormat,
              ),
            ),
          ),
          const SizedBox(width: 2),
        ],
      ],
    );
  }
}
