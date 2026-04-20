import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/app_store_surface.dart';
import 'package:PiliPlus/common/widgets/badge.dart';
import 'package:PiliPlus/common/widgets/flutter/layout_builder.dart';
import 'package:PiliPlus/common/widgets/image/image_save.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/common/widgets/progress_bar/video_progress_indicator.dart';
import 'package:PiliPlus/common/widgets/stat/stat.dart';
import 'package:PiliPlus/common/widgets/video_popup_menu.dart';
import 'package:PiliPlus/http/search.dart';
import 'package:PiliPlus/models/common/badge_type.dart';
import 'package:PiliPlus/models/common/stat_type.dart';
import 'package:PiliPlus/models/model_hot_video_item.dart';
import 'package:PiliPlus/models/model_video.dart';
import 'package:PiliPlus/models/search/result.dart';
import 'package:PiliPlus/utils/date_utils.dart';
import 'package:PiliPlus/utils/duration_utils.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:flutter/material.dart' hide LayoutBuilder;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class VideoCardH extends StatelessWidget {
  const VideoCardH({
    super.key,
    required this.videoItem,
    this.onTap,
    this.onViewLater,
    this.onRemove,
  });
  final BaseVideoItemModel videoItem;
  final VoidCallback? onTap;
  final ValueChanged<int>? onViewLater;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    String type = 'video';
    String? badge;
    if (videoItem case final SearchVideoItemModel item) {
      final typeOrNull = item.type;
      if (typeOrNull != null && typeOrNull.isNotEmpty) {
        type = typeOrNull;
        if (type == 'ketang') {
          badge = 'Course';
        } else if (type == 'live_room') {
          badge = 'Live';
        }
      }
      if (item.isUnionVideo == 1) {
        badge = 'Collab';
      }
    } else if (videoItem case final HotVideoItemModel item) {
      if (item.isCharging == true) {
        badge = 'Exclusive';
      } else if (item.isCooperation == 1) {
        badge = 'Collab';
      } else {
        badge = item.pgcLabel;
      }
    }
    void onLongPress() => imageSaveDialog(
      bvid: videoItem.bvid,
      title: videoItem.title,
      cover: videoItem.cover,
    );
    final colorScheme = ColorScheme.of(context);
    return Material(
      type: MaterialType.transparency,
      child: FrostedCard(
        borderRadius: AppStoreSurfaces.cardRadius,
        child: InkWell(
          borderRadius: AppStoreSurfaces.cardRadius,
          onLongPress: onLongPress,
          onSecondaryTap: PlatformUtils.isMobile ? null : onLongPress,
          onTap:
              onTap ??
              () async {
                if (type == 'ketang') {
                  PageUtils.viewPugv(seasonId: videoItem.aid);
                  return;
                } else if (type == 'live_room') {
                  if (videoItem case final SearchVideoItemModel item) {
                    int? roomId = item.id;
                    if (roomId != null) {
                      PageUtils.toLiveRoom(roomId);
                    }
                  } else {
                    SmartDialog.showToast(
                      'err: live_room : ${videoItem.runtimeType}',
                    );
                  }
                  return;
                }
                if (videoItem case final HotVideoItemModel item) {
                  if (item.redirectUrl?.isNotEmpty == true &&
                      PageUtils.viewPgcFromUri(item.redirectUrl!)) {
                    return;
                  }
                }

                try {
                  final int? cid =
                      videoItem.cid ??
                      await SearchHttp.ab2c(
                        aid: videoItem.aid,
                        bvid: videoItem.bvid,
                      );
                  if (cid != null) {
                    PageUtils.toVideoPage(
                      bvid: videoItem.bvid,
                      cid: cid,
                      cover: videoItem.cover,
                      title: videoItem.title,
                    );
                  }
                } catch (err) {
                  SmartDialog.showToast(err.toString());
                }
              },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: AppStoreSurfaces.sectionRadius,
                  child: AspectRatio(
                    aspectRatio: Style.aspectRatio,
                    child: LayoutBuilder(
                      builder: (context, boxConstraints) {
                        final double maxWidth = boxConstraints.maxWidth;
                        final double maxHeight = boxConstraints.maxHeight;
                        num? progress;
                        if (videoItem case final HotVideoItemModel item) {
                          progress = item.progress;
                        }

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            NetworkImgLayer(
                              src: videoItem.cover,
                              width: maxWidth,
                              height: maxHeight,
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.04),
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.28),
                                  ],
                                ),
                              ),
                            ),
                            if (badge != null)
                              PBadge(
                                text: badge,
                                top: 10.0,
                                right: 10.0,
                                type: switch (badge) {
                                  'Exclusive' => PBadgeType.error,
                                  _ => PBadgeType.primary,
                                },
                              ),
                            if (progress != null && progress != 0) ...[
                              PBadge(
                                text: progress == -1
                                    ? 'Watched'
                                    : '${DurationUtils.formatDuration(progress)}/${DurationUtils.formatDuration(videoItem.duration)}',
                                right: 10,
                                bottom: 10,
                                type: PBadgeType.gray,
                              ),
                              Positioned(
                                left: 0,
                                bottom: 0,
                                right: 0,
                                child: VideoProgressIndicator(
                                  color: colorScheme.primary,
                                  backgroundColor:
                                      colorScheme.secondaryContainer,
                                  progress: progress == -1
                                      ? 1
                                      : progress / videoItem.duration,
                                ),
                              ),
                            ] else if (videoItem.duration > 0)
                              PBadge(
                                text: DurationUtils.formatDuration(
                                  videoItem.duration,
                                ),
                                right: 10.0,
                                bottom: 10.0,
                                type: PBadgeType.gray,
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (videoItem case final SearchVideoItemModel item) ...[
                        if (item.titleList?.isNotEmpty == true)
                          Text.rich(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            TextSpan(
                              children: item.titleList!
                                  .map(
                                    (e) => TextSpan(
                                      text: e.text,
                                      style: TextStyle(
                                        fontSize:
                                            Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .fontSize,
                                        height: 1.38,
                                        fontWeight: FontWeight.w600,
                                        color: e.isEm
                                            ? colorScheme.primary
                                            : colorScheme.onSurface,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                      ] else
                        Text(
                          videoItem.title,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.bodyMedium!.fontSize,
                            height: 1.38,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 10),
                      Text(
                        _metaText(),
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1,
                          color: colorScheme.outline,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          StatWidget(
                            type: StatType.play,
                            value: videoItem.stat.view,
                          ),
                          const SizedBox(width: 8),
                          StatWidget(
                            type: StatType.danmaku,
                            value: videoItem.stat.danmu,
                          ),
                          const Spacer(),
                          FrostedCard(
                            borderRadius: AppStoreSurfaces.pillRadius,
                            blur: 10,
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
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _metaText() {
    String pubdate = DateFormatUtils.dateFormat(videoItem.pubdate!);
    if (pubdate != '') {
      pubdate += '  ';
    }
    return "$pubdate${videoItem.owner.name}";
  }
}
