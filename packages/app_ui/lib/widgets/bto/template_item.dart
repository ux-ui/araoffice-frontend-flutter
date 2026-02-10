import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app_ui.dart';

class TemplateItem extends StatelessWidget {
  // 프로젝트 아이템을 참고하여 변경 예정
  // final EpubBook data;
  final FileSystemEntity data;
  final String heroTag;
  final void Function()? onTap;
  final void Function()? onLongPress;

  final bool? isBookmarked;

  const TemplateItem({
    super.key,
    required this.data,
    // required this.data,
    required this.heroTag,
    this.isBookmarked,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 180,
          child: Stack(children: [
            Card(
              elevation: 3,
              color: context.surfaceContainerLow,
              child: InkWell(
                highlightColor: context.primary.withAlpha(26),
                splashColor: context.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
                onTap: onTap,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // book thumbnail
                      Center(
                        child: Icon(
                          Icons.book,
                          size: 140,
                          color: context.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
                top: 7,
                right: 7,
                child: Card(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: context.outline),
                        borderRadius: BorderRadius.circular(5)),
                    color: context.background,
                    // child: Assets.icon.gradeOn.svg(color: context.surfaceDim))),
                    child: isBookmarked == null
                        ? null
                        : isBookmarked ?? false
                            ? CommonAssets.icon.gradeOn.svg(
                                colorFilter: ColorFilter.mode(
                                    context.surfaceDim, BlendMode.srcIn))
                            : CommonAssets.icon.gradeOff.svg(
                                colorFilter: const ColorFilter.mode(
                                    Color(0xffFFC000), BlendMode.srcIn)))),
          ]),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              data.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.bodyLarge?.copyWith(
                color: context.onSurface,
              ),
            ),
            // -- 팝업 버튼
            Align(
              alignment: Alignment.topRight,
              child: PopupMenuButton(
                iconSize: 20,
                tooltip: 'popup Tooltip',
                color: context.background,
                surfaceTintColor: context.background,
                icon: Icon(
                  Icons.more_vert,
                  color: context.onSurface,
                ),
                itemBuilder: (context) {
                  return [
                    CustomPopupMenuItem(
                      value: 'move',
                      // 책 이동
                      child: Text('book_move'.tr),
                    ),
                    CustomPopupMenuItem(
                      value: 'move',
                      child: Text('book_move'.tr),
                    ),
                  ];
                },
                onSelected: (value) {},
              ),
            ),
          ],
        ),
        data.author == null
            ? const SizedBox()
            : Text(
                data.author!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodyMedium?.copyWith(
                  color: const Color(0xff808080),
                ),
              ),
      ],
    );
  }
}

class CustomPopupMenuItem<T> extends PopupMenuItem<T> {
  const CustomPopupMenuItem({
    super.key,
    super.value,
    super.child,
    double? height,
  }) : super(
          height: height ?? 36.0,
        );
}

abstract class FileSystemEntity {
  final String name;
  final String type;
  final String? author;
  final bool? isBookmarked;
  final bool isFixedMode = true;
  String path;

  FileSystemEntity(
      {required this.name,
      required this.type,
      required this.path,
      this.author,
      this.isBookmarked});
}

class Project extends FileSystemEntity {
  Project(
      {required super.name,
      required super.path,
      required String super.author,
      required bool super.isBookmarked})
      : super(type: 'project');
}

// class Folder extends FileSystemEntity {
//   List<FileSystemEntity> contents;

//   Folder({required String name, required String path, required this.contents})
//       : super(name: name, type: 'folder', path: path);
// }
