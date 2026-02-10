import 'package:flutter/material.dart';

import '../../app_ui.dart';

class BtoTabBarView extends StatefulWidget {
  final List<String> tabs;
  final List<Widget> children;
  final int? initialIndex;
  final double? height;
  final double? tabWidth;
  final double? tabPadding;
  final Alignment? tabsAlignment;
  final ScrollPhysics? physics;
  final TabBarIndicatorSize? indicatorSize;
  final Function(int)? tabChanged;
  final Color? backgroundColor;

  const BtoTabBarView({
    super.key,
    required this.tabs,
    required this.children,
    this.initialIndex = 0,
    this.tabsAlignment,
    this.physics,
    this.height,
    this.tabWidth,
    this.tabPadding,
    this.indicatorSize,
    this.tabChanged,
    this.backgroundColor,
  });

  @override
  State<StatefulWidget> createState() => _STabBarViewViewState();
}

class _STabBarViewViewState extends State<BtoTabBarView>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.children.length,
      initialIndex: widget.initialIndex ?? 0,
      child: Builder(
        builder: (BuildContext context) {
          final TabController tabController = DefaultTabController.of(context);
          tabController.addListener(() {
            if (!tabController.indexIsChanging) {
              widget.tabChanged?.call(tabController.index);
            }
          });
          return Scaffold(
            backgroundColor: widget.backgroundColor,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(widget.height ?? 60.0),
              child: Align(
                alignment: widget.tabsAlignment ?? Alignment.center,
                child: SizedBox(
                  width: widget.tabWidth,
                  child: TabBar(
                    labelPadding: (widget.tabPadding != null)
                        ? EdgeInsets.symmetric(
                            horizontal: widget.tabPadding ?? 10)
                        : null,
                    indicatorSize:
                        widget.indicatorSize ?? TabBarIndicatorSize.tab,
                    indicatorColor: context.primary,
                    isScrollable: false,
                    dividerHeight: 0,
                    labelStyle: context.titleMedium,
                    unselectedLabelColor: context.surfaceDim,
                    tabs: widget.tabs.map((text) {
                      return Tab(text: text);
                    }).toList(),
                  ),
                ),
              ),
            ),
            body: TabBarView(
              physics: widget.physics,
              children: widget.children,
            ),
          );
        },
      ),
    );
  }
}
