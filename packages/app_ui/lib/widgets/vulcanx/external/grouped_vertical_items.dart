import 'package:flutter/material.dart';

class GroupedVerticalItems<T> extends StatefulWidget {
  final double? width;
  final double? height;
  final List<List<T>> itemGroups;
  final Widget Function(BuildContext, T, bool, VoidCallback) itemBuilder;

  ///
  /// 그룹별로 선을 그려준다.
  ///
  const GroupedVerticalItems({
    super.key,
    this.width,
    this.height,
    required this.itemGroups,
    required this.itemBuilder,
  });

  @override
  State<GroupedVerticalItems<T>> createState() =>
      _GroupedVerticalItemsState<T>();
}

class _GroupedVerticalItemsState<T> extends State<GroupedVerticalItems<T>> {
  int selectedGroupIndex = -1;
  int selectedItemIndex = -1;

  void _onItemSelected(int groupIndex, int itemIndex) {
    setState(() {
      selectedGroupIndex = groupIndex;
      selectedItemIndex = itemIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: widget.itemGroups.length,
        separatorBuilder: (context, index) =>
            const Divider(color: Colors.black12, height: 1),
        itemBuilder: (context, groupIndex) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.itemGroups[groupIndex].map((itemData) {
                int itemIndex = widget.itemGroups[groupIndex].indexOf(itemData);
                bool isSelected = selectedGroupIndex == groupIndex &&
                    selectedItemIndex == itemIndex;
                return widget.itemBuilder(
                  context,
                  itemData,
                  isSelected,
                  () => _onItemSelected(groupIndex, itemIndex),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
