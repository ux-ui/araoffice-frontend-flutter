import 'package:common_assets/common_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app_ui.dart';

class WidgetDemoPage extends StatefulWidget {
  const WidgetDemoPage({super.key});

  @override
  State<WidgetDemoPage> createState() => _WidgetDemoPageState();
}

class _WidgetDemoPageState extends State<WidgetDemoPage> {
  @override
  Widget build(BuildContext context) => widgetDemo(context);
}

Widget widgetDemo(BuildContext context) {
  return Scaffold(
      appBar: AppBar(
        title: const Text('Test Widget Page'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  toggleBtn(context),
                  fabBtn(context),
                  downloadBtn(context),
                  const RectangleCheckBox(isChecked: true),
                  const RectangleCheckBox(isChecked: false),
                  const CircleCheckBox(isChecked: true),
                  iconBtn(context),
                  labelBtn(context),
                  const SizedBox(height: 10),
                  tabBar(),
                  const SizedBox(height: 10),
                  textFiled(),
                  dropDown(context),
                  dialog(context),
                  circleRadio(context),
                  rectangleRadio(context),
                  navIcon(),
                  menuList(),
                  elevation(),
                  laelCheckBox(),
                  LabelRectangleCheckbox(
                      label: 'label',
                      onChanged: (value) {
                        debugPrint('value : $value');
                      }),
                ],
              ),
            )),
          ),
          Expanded(
            child: SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Text('VulcanX Theme', style: context.titleLarge)),
                  const SizedBox(height: 10),
                  Text('VulcanX divider', style: context.titleSmall),
                  const VulcanXDivider(),
                  const SizedBox(height: 10),
                  Text('VulcanX TextField', style: context.titleSmall),
                  const VulcanXTextField(
                    hintText: '너비를 입력하세요',
                    // suffixText: 'px',
                    //suffixIcon: CommonAssets.icon.search.svg(width: 10, height: 10), // svg를 사용하면 사이즈 변경이 안됨
                    suffixIcon: Icon(Icons.add, size: 20),
                    isSearchIcon: true,
                  ),
                  const SizedBox(height: 10),
                  Text('VulcanX TextField', style: context.titleSmall),
                  const VulcanXLabelTextField(
                    label: '너비',
                    unit: 'px',
                    textFieldWidth: 150,
                    spaceBetween: 220,
                    initialValue: '1280',
                  ),
                  const SizedBox(height: 10),
                  GridSelector(
                    width: 400,
                    height: 400,
                    onChanged: (rows, cols) {
                      // 마우스 호버 시 호출됨
                      debugPrint('Hovering: $rows rows x $cols columns');
                    },
                    onSelection: (rows, cols) {
                      // 클릭했을 때 호출됨
                      debugPrint('Selected: $rows rows x $cols columns');
                    },
                    maxRows: 8,
                    maxCols: 8,
                    selectedColor: Colors.lightBlueAccent,
                    unselectedColor: Colors.grey,
                  ),
                  const SizedBox(height: 10),
                  GridSelectorPopup(
                      onSelection: (rows, cols) {
                        debugPrint(
                            'Final Selection: $rows rows x $cols columns');
                      },
                      child: VulcanXElevatedButton.nullStyle(
                          child: Text('add_table'.tr))),
                  const SizedBox(height: 10),
                  Text('VulcanX SvgIcon Selector', style: context.titleSmall),
                  VulcanXSvgIconSelector(
                    svgIcons: [
                      CommonAssets.icon.undo,
                      CommonAssets.icon.redo,
                    ],
                    onSelected: (index) {
                      debugPrint('선택된 SVG 아이콘 인덱스: $index');
                      // 여기에 선택된 아이콘에 대한 추가 로직을 구현할 수 있습니다.
                    },
                    initialSelectedIndex: 0,
                    iconSize: 28.0,
                  ),
                  const SizedBox(height: 10),
                  Text('VulcanX SvgButton Selector', style: context.titleSmall),
                  VulcanXSvgButtonSelector(
                    svgAssets: [
                      CommonAssets.icon.iconH1,
                      CommonAssets.icon.iconH2,
                      CommonAssets.icon.iconH3,
                      CommonAssets.icon.iconH4,
                      CommonAssets.icon.iconH5,
                      CommonAssets.icon.iconH6,
                    ],
                    onSelectedIndex: (index) {},
                  ),
                  const SizedBox(height: 10),
                  Text('VulcanX Button Selector', style: context.titleSmall),
                  VulcanXButtonSelector(
                    options: const ['요소', '위젯', '기타'],
                    onSelected: (index) {},
                  ),
                  const SizedBox(height: 10),
                  Text('VulcanX Dropdown', style: context.titleSmall),
                  VulcanXDropdown<String>(
                    value: '권한이 있는 사용자',
                    items: const [
                      VulcanXIconDropdownMenuItem(
                        value: '권한이 있는 사용자',
                        icon: Icons.lock_open,
                        child: Text('권한이 있는 사용자'),
                      ),
                      VulcanXIconDropdownMenuItem(
                        value: '관리자',
                        icon: Icons.admin_panel_settings,
                        child: Text('관리자'),
                      ),
                      VulcanXIconDropdownMenuItem(
                        value: '일반 사용자',
                        icon: Icons.person,
                        child: Text('일반 사용자'),
                      ),
                    ],
                    onChanged: (String? newValue) {},
                    hintText: '권한이 있는 사용자',
                    hintIcon: Icons.lock, // 힌트 텍스트 옆의 아이콘
                  ),
                  const SizedBox(height: 10),
                  VulcanXDropdown<String>(
                    value: 'uuid',
                    stringItems: const ['uuid', 'uuid2'],
                    onChanged: (String? newValue) {},
                    hintText: '권한이 있는 사용자',
                    hintIcon: Icons.lock, // 힌트 텍스트 옆의 아이콘
                  ),
                  const SizedBox(height: 10),
                  Text('VDocumentHoverActionItem', style: context.titleSmall),
                  const DocumentHoverActionItem(
                      index: 1,
                      pageId: 'pageId',
                      label: 'coverTitle',
                      url: 'coverHref'),
                  const SizedBox(height: 10),
                  Text('VulcanX close Dialog', style: context.titleSmall),
                  OutlinedButton.icon(
                      label: Text('공유하기', style: context.titleSmall),
                      icon: CommonAssets.icon.shareOn.svg(),
                      onPressed: () async {
                        VulcanCloseDialogType? result =
                            await VulcanCloseDialogWidget(
                          title: '비동기 커스텀 다이얼로그',
                          content: const Text('이제 async/await를 사용할 수 있습니다.'),
                        ).show(context);

                        if (result == VulcanCloseDialogType.ok) {
                          debugPrint('사용자가 확인을 선택했습니다.');
                        } else if (result == VulcanCloseDialogType.cancel) {
                          debugPrint('사용자가 취소를 선택했습니다.');
                        } else if (result == VulcanCloseDialogType.close) {
                          debugPrint('다이얼로그가 닫혔습니다.');
                        }
                      }),
                  VulcanXSvgLabelIconButton(
                    icon: CommonAssets.icon.animatedImages,
                    label: '애니메이션',
                    isSelected: true,
                    onPressed: () => {},
                    selectedColor: Colors.red,
                    unselectedColor: Colors.black,
                  ),
                  VulcanXRoundedContainer.grey(
                    width: 238,
                    height: 160,
                    child: Center(
                      child: VulcanXSvgLabelIconButton(
                        icon: CommonAssets.icon.animatedImages,
                        label: '애니메이션',
                        isSelected: false,
                        onPressed: () => {},
                        selectedColor: Colors.red,
                        unselectedColor: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('VulcanX two svg icon  OutlinedButton',
                      style: context.titleSmall),
                  VulcanXTwoSvgIconOutlinedButton(
                      height: 56,
                      iconWidth: 24,
                      iconHeight: 24,
                      text: '새프로젝트 만들기',
                      prefixIcon: CommonAssets.icon.newProjectIcon,
                      suffixIcon: CommonAssets.icon.add,
                      onPressed: () => {}),
                  const SizedBox(height: 10),
                  Text('VulcanX two svg icon  OutlinedButton',
                      style: context.titleSmall),
                  VulcanXRectangleIconButton.outlined(
                    width: 34,
                    height: 34,
                    tooltip: 'add_new_page',
                    icon: CommonAssets.icon.add.svg(),
                    onPressed: () {},
                  ),
                  const SizedBox(height: 10),
                  VulcanXRectangleIconButton.filled(
                    width: 34,
                    height: 34,
                    tooltip: 'add_new_page',
                    icon: CommonAssets.icon.formatListBulletedSvg.svg(),
                    onPressed: () {},
                  ),
                  VulcanXElevatedButton(
                      onPressed: () => {},
                      child: Text('로그인', style: context.bodyLarge)),
                  const SizedBox(height: 8),
                  VulcanXOutlinedButton(
                      onPressed: () => {},
                      child: Text('회원가입', style: context.bodyLarge)),
                  const SizedBox(height: 8),
                  Text('VulcanX Image Chip', style: context.titleSmall),
                  const VulcanXImageChip(
                    chipLabel: Text('고정 레이아웃'),
                    isBookmark: true,
                    isCrownBadge: true,
                  ),
                  const SizedBox(height: 8),
                  Text('VulcanX Label More Menu', style: context.titleSmall),
                  const VulcanXLabelMoreMenu(
                    label: '시민 정책 참여',
                    items: [
                      PopupMenuItem(
                        value: 'copy',
                        child: Text('프로젝트 복제'),
                      ),
                      PopupMenuItem(
                        value: 'move',
                        child: Text('프로젝트 이동'),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('프로젝트 편집'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('VulcanX switch', style: context.titleSmall),
                  VulcanXSwitch(
                    label: 'test',
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 8),
                  Text('VulcanX Hover Thumbnail', style: context.titleSmall),
                  VulcanXHoverThumbnail(
                    onApply: () {},
                    onPreview: () {},
                    text: '잡지',
                    child: CommonAssets.image.testBookCover.image(),
                  ),
                  const SizedBox(height: 8),
                  Text('counter widget', style: context.titleSmall),
                  CounterWidget(
                    initialValue: '1px',
                    onChanged: (value) {
                      debugPrint('Counter value changed to: $value');
                    },
                  ),
                  const SizedBox(height: 8),
                  Text('VulcanX InkWell', style: context.titleSmall),
                  VulcanXInkWell(
                    child: CommonAssets.image.fontEffect01.image(),
                    onTap: () {},
                  ),
                  VulcanXInkWell(
                    isCircle: true,
                    child: CommonAssets.image.kakao.svg(),
                    onTap: () {},
                  ),
                  VulcanXExpansionPanelList(
                    expansionCallback: (panelIndex, isExpanded) {},
                    children: [
                      VulcanXExpansionPanel(
                        isExpanded: true,
                        headerBuilder: (context, isExpanded) {
                          return const Text('data');
                        },
                        body: const Text('-------'),
                      ),
                    ],
                  )
                ],
              ),
            )),
          ),
        ],
      ));
}

Widget laelCheckBox() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text('label Check Box'),
      LabelCheckBox(
        isPrefixIcon: true,
        label: const Text('label'),
        onChanged: (isChecked) {
          debugPrint('isChecked: $isChecked');
        },
      ),
      LabelCheckBox(
        isSuffixIcon: true,
        label: const Text('label'),
        onChanged: (isChecked) {
          debugPrint('isChecked: $isChecked');
        },
      ),
    ],
  );
}

Widget elevation() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      ElevationWiddget.elevation2(),
      const SizedBox(width: 10),
      ElevationWiddget.elevation3(),
      const SizedBox(width: 10),
      ElevationWiddget.elevation4(),
    ],
  );
}

Widget tabBar() {
  return const SizedBox(
    height: 500,
    child: BtoTabBarView(
      tabs: ['TabA', 'TabB', 'TabC'],
      children: [
        SizedBox(height: 100, child: Text('data')),
        SizedBox(
          height: 1,
        ),
        SizedBox(
          height: 1,
        )
      ],
    ),
  );
}

Widget menuList() {
  return const Column(
    children: [
      Text('Menu List Button'),
      SizedBox(height: 16),
      VulcanXMoreMenu(
        items: [
          PopupMenuItem(
            value: 'delete',
            child: Text('value 1'),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Text('value 2'),
          ),
        ],
      ),
      SizedBox(height: 16),
    ],
  );
}

Widget navIcon() {
  return Column(
    children: [
      const Text('Nav Icon'),
      const SizedBox(height: 8),
      NavIcon(
          icon: CommonAssets.icon.accountBox.svg(),
          // image: Assets.icon.bookUser,
          size: 40),
      const SizedBox(height: 16),
    ],
  );
}

Widget textFiled() {
  final TextEditingController textController = TextEditingController();
  return Column(
    children: [
      const Text('Text Form Field'),
      const SizedBox(height: 8),
      SizedBox(
        width: 200,
        child: BtoTextField(
          controller: textController,
          hintText: 'Hint',
          onClickClear: () {
            textController.clear();
          },
          expands: false,
        ),
      ),
      const SizedBox(height: 16),
    ],
  );
}

Widget rectangleRadio(BuildContext context) {
  return Column(
    children: [
      const Text('Rectangle Radio Button'),
      const SizedBox(height: 8),
      RectangleRadioBtn(
        context: context,
        buttonIndex: 4,
        onChanged: (index) {},
        buttonSize: 20,
        iconSize: 15,
        buttonPadding: 5,
      ),
      const SizedBox(height: 16),
    ],
  );
}

Widget circleRadio(BuildContext context) {
  return Column(
    children: [
      const Text('Circle Radio Button'),
      const SizedBox(height: 8),
      CircleRadioBtn(
        context: context,
        buttonIndex: 4,
        onChanged: (index) {},
        buttonSize: 10,
        iconSize: 10,
        buttonPadding: 5,
      ),
      const SizedBox(height: 16),
    ],
  );
}

Widget dialog(BuildContext context) {
  return Column(children: [
    const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Dialog'),
        SizedBox(
          width: 16,
        ),
        Text('Bottom sheet'),
      ],
    ),
    const SizedBox(height: 8),
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: () {
              Get.dialog(AlertDialog(
                elevation: 8,
                contentPadding: EdgeInsets.zero,
                backgroundColor: context.background,
                content: BtoDialog(
                  title: 'title',
                  message: const Text('content'),
                  textCancel: '취소',
                  textConfirm: '저장',
                  contentPadding: const EdgeInsets.all(20),
                  onCancel: () {
                    Navigator.of(context).pop();
                  },
                  onConfirm: () {
                    Get.back();
                  },
                ),
              ));
            },
            icon: const Icon(Icons.handshake)),
        const SizedBox(width: 16),
        IconButton(
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                enableDrag: true,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                useSafeArea: false,
                builder: (context) {
                  return BtoBottomSheet(
                    header: const Text('header'),
                    body: Column(
                        children: List.generate(
                            20, (index) => Text('content $index'))),
                    isClosedBtn: true,
                    isDraggable: true,
                    // automaticallyImplyHeader: false,
                  );
                },
              );
            },
            icon: const Icon(Icons.handshake)),
      ],
    ),
    const SizedBox(height: 16),
  ]);
}

Stream<int> changeNumber() async* {
  for (int i = 1; i <= 100; i++) {
    await Future.delayed(const Duration(milliseconds: 50));
    yield i;
  }
}

Widget toggleBtn(BuildContext context) {
  return Column(
    children: [
      const Text('Toggle Button'),
      const SizedBox(height: 8),
      BtoSwitchBtn(
        initValue: true,
        onChanged: (value) {},
        // disabled: true,
      ),
      const SizedBox(height: 16),
    ],
  );
}

Widget fabBtn(BuildContext context) {
  return Column(
    children: [
      const Text('Fab Button'),
      const SizedBox(height: 8),
      FabButton(
        size: 30,
        onTap: () {},
        icon: CommonAssets.icon.add.svg(),
        // icon: Icon(
        //   Icons.menu,
        //   color: context.primary,
        // ),
      ),
      const SizedBox(height: 16),
    ],
  );
}

Widget downloadBtn(BuildContext context) {
  final index = 0.obs;
  changeNumber().listen((int number) {
    index.value = number;
  });
  return Column(
    children: [
      const Text('Download Button'),
      const SizedBox(height: 8),
      Obx(
        () => DownloadIcon(
          icon: CommonAssets.icon.download.svg(width: 24, height: 24),
          color: context.onSurface,
          borderColor: context.primary,
          size: 44,
          onTap: () {
            index.value = 0;
          },
          progress: index.value.toDouble(),
        ),
      ),
      const SizedBox(width: 8),
      const SizedBox(height: 16),
    ],
  );
}

Widget iconBtn(BuildContext context) {
  return Column(
    children: [
      const Text('Icon Button'),
      const SizedBox(height: 8),
      BtoIconButton(
        icon: CommonAssets.icon.settings.svg(width: 24, height: 24),
        color: context.onSurface,
        size: 24,
        onTap: () {},
      ),
      const SizedBox(width: 8),
      const SizedBox(height: 16),
    ],
  );
}

Widget labelBtn(BuildContext context) {
  return Column(
    children: [
      const Text('Label Button'),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LabelButton(
            label: 'Label',
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          LabelButton(
            label: 'Label',
            backgroundColor: context.onPrimary,
            onPressed: () {},
            textColor: context.primary,
          ),
          const SizedBox(width: 8),
          LabelButton(
            label: 'Label',
            backgroundColor: context.onPrimary,
            onPressed: () {},
            textColor: context.primary,
            isBorder: false,
          ),
        ],
      ),
    ],
  );
}

Widget dropDown(BuildContext context) {
  String selected = 'Label';
  dynamic itmes = <String>['Label', 'B', 'C', 'D'].map((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList();
  return Column(
    children: [
      const Text('Drop Down Button'),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BtoDropDownBtn(
            items: itmes,
            value: selected,
            onChanged: (v) {},
          ),
          const SizedBox(width: 3),
          BtoDropDownBtn(
            items: itmes,
            value: selected,
            backgroundColor: context.onSurface.withAlpha(21),
            onChanged: (v) {},
          ),
          const SizedBox(width: 3),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BtoDropDownBtn(
            items: itmes,
            value: selected,
            backgroundColor: context.onSurface.withAlpha(31),
            onChanged: (v) {},
          ),
          const SizedBox(width: 3),
          BtoDropDownBtn(
            items: itmes,
            value: selected,
            backgroundColor: context.onSurface.withAlpha(31),
            onChanged: (v) {},
          ),
          const SizedBox(width: 3),
          BtoDropDownBtn(
            items: itmes,
            value: selected,
            onChanged: (v) {},
            isDisabled: true,
            backgroundColor: context.onSurface.withAlpha(31),
          ),
        ],
      ),
      const SizedBox(height: 16),
    ],
  );
}
