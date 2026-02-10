import 'package:flutter/material.dart';

import '../../../app_ui.dart';

class DefineTabBar extends StatefulWidget {
  final List<String> tabs;
  final List<Widget> children;
  final int? initialIndex;
  final double? height;
  final double? tabPadding;
  final TabBarIndicatorSize? indicatorSize;
  final Function(int)? tabChanged;
  final Color? backgroundColor;
  final List<int>? enabledIndices; // 활성화할 탭 인덱스 리스트 추가

  const DefineTabBar({
    super.key,
    required this.tabs,
    required this.children,
    this.initialIndex = 0,
    this.height,
    this.tabPadding,
    this.indicatorSize,
    this.tabChanged,
    this.backgroundColor,
    this.enabledIndices, // 새로운 파라미터
  });

  @override
  State<StatefulWidget> createState() => _STabBarViewViewState();
}

class _STabBarViewViewState extends State<DefineTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    // enabledIndices가 있는 경우 첫 번째 활성화된 인덱스를 initialIndex로 사용
    final initialIndex =
        (widget.enabledIndices != null && widget.enabledIndices!.isNotEmpty)
            ? widget.enabledIndices!.first
            : widget.initialIndex ?? 0;

    _tabController = TabController(
      length: widget.children.length,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isTabEnabled(int index) {
    // enabledIndices가 null이거나 비어있으면 모든 탭 활성화
    if (widget.enabledIndices == null || widget.enabledIndices!.isEmpty) {
      return true;
    }
    // enabledIndices에 포함된 탭만 활성화
    return widget.enabledIndices!.contains(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(widget.height ?? 60.0),
        child: Align(
          alignment: Alignment.center,
          child: TabBar(
            controller: _tabController,
            labelPadding: (widget.tabPadding != null)
                ? EdgeInsets.symmetric(horizontal: widget.tabPadding ?? 10)
                : null,
            indicatorSize: widget.indicatorSize ?? TabBarIndicatorSize.tab,
            indicatorColor: context.primary,
            isScrollable: false,
            dividerHeight: 0,
            labelStyle: context.titleMedium,
            unselectedLabelColor: context.surfaceDim,
            onTap: (index) {
              if (!_isTabEnabled(index)) {
                // 비활성화된 탭을 클릭하면 이전 탭으로 돌아감
                _tabController.animateTo(_tabController.previousIndex);
                // 선택적: 사용자에게 피드백 제공
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(content: Text('이 탭은 사용할 수 없습니다.')),
                // );
              } else {
                widget.tabChanged?.call(index);
              }
            },
            tabs: List.generate(widget.tabs.length, (index) {
              bool isEnabled = _isTabEnabled(index);
              return Tab(
                child: Opacity(
                  opacity: isEnabled ? 1.0 : 0.5,
                  child: Text(widget.tabs[index],
                      style: context.titleSmall
                          ?.apply(color: isEnabled ? null : Colors.grey)),
                ),
              );
            }),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: widget.enabledIndices == null || widget.enabledIndices!.isEmpty
            ? null // 모든 탭이 활성화된 경우 기본 스크롤 동작 허용
            : const NeverScrollableScrollPhysics(), // 비활성화된 탭이 있는 경우 스크롤 비활성화
        children: widget.children,
      ),
    );
  }
}
