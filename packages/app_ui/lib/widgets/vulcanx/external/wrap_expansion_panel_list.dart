import 'package:flutter/material.dart';

class WrapExpanstionPanelItem {
  String headerValue;
  Widget child;
  bool isExpanded;

  WrapExpanstionPanelItem({
    required this.headerValue,
    required this.child,
    this.isExpanded = true,
  });
}

class WrapExpansionPanelList extends StatefulWidget {
  final List<WrapExpanstionPanelItem> data;

  const WrapExpansionPanelList({super.key, required this.data});

  @override
  State<WrapExpansionPanelList> createState() => _WrapExpansionPanelListState();
}

class _WrapExpansionPanelListState extends State<WrapExpansionPanelList> {
  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      expandIconColor: Colors.black,
      materialGapSize: 2,
      dividerColor: Colors.black12,
      expandedHeaderPadding: EdgeInsets.zero,
      elevation: 1,
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          widget.data[index].isExpanded = isExpanded;
        });
      },
      children: widget.data.map<ExpansionPanel>((WrapExpanstionPanelItem item) {
        return ExpansionPanel(
          canTapOnHeader: true,
          backgroundColor: Colors.white,
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(
                item.headerValue,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          },
          body: item.child,
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}
