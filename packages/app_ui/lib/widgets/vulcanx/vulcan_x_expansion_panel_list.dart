// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';

class _SaltedKey<S, V> extends LocalKey {
  const _SaltedKey(this.salt, this.value);

  final S salt;
  final V value;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _SaltedKey<S, V> &&
        other.salt == salt &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(runtimeType, salt, value);

  @override
  String toString() {
    final saltString = S == String ? "<'$salt'>" : '<$salt>';
    final valueString = V == String ? "<'$value'>" : '<$value>';
    return '[$saltString $valueString]';
  }
}

typedef ExpansionPanelCallback = void Function(int panelIndex, bool isExpanded);

typedef ExpansionPanelHeaderBuilder = Widget Function(
    BuildContext context, bool isExpanded);

class VulcanXExpansionPanel {
  VulcanXExpansionPanel({
    required this.headerBuilder,
    required this.body,
    this.isExpanded = false,
    this.backgroundColor,
    this.headerPadding,
  });

  final ExpansionPanelHeaderBuilder headerBuilder;
  final Widget body;
  final bool isExpanded;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? headerPadding;
}

class VulcanXExpansionPanelList extends StatefulWidget {
  const VulcanXExpansionPanelList({
    super.key,
    this.children = const <VulcanXExpansionPanel>[],
    this.expansionCallback,
    this.animationDuration = kThemeAnimationDuration,
    this.hasDividers,
    this.expandIconAlignment,
  });

  final List<VulcanXExpansionPanel> children;
  final ExpansionPanelCallback? expansionCallback;
  final Duration animationDuration;
  final AlignmentGeometry? expandIconAlignment;
  final bool? hasDividers;

  @override
  State<StatefulWidget> createState() => _VulcanXExpansionPanelListState();
}

class _VulcanXExpansionPanelListState extends State<VulcanXExpansionPanelList> {
  bool _isChildExpanded(int index) {
    return widget.children[index].isExpanded;
  }

  void _handlePressed(bool isExpanded, int index) {
    widget.expansionCallback?.call(index, !isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final items = <MergeableMaterialItem>[];

    for (var index = 0; index < widget.children.length; index += 1) {
      final child = widget.children[index];
      final headerWidget = child.headerBuilder(
        context,
        _isChildExpanded(index),
      );

      final header = MergeSemantics(
        child: InkWell(
          onTap: () => _handlePressed(_isChildExpanded(index), index),
          child: Padding(
            padding: child.headerPadding ?? EdgeInsets.zero,
            child: Row(
              children: <Widget>[
                if (widget.expandIconAlignment == Alignment.centerLeft)
                  VulcanXExpandIcon(isExpanded: _isChildExpanded(index)),
                Expanded(
                  child: AnimatedContainer(
                    duration: widget.animationDuration,
                    curve: Curves.fastOutSlowIn,
                    child: headerWidget,
                  ),
                ),
                if (widget.expandIconAlignment == Alignment.centerRight)
                  VulcanXExpandIcon(isExpanded: _isChildExpanded(index)),
              ],
            ),
          ),
        ),
      );

      items.add(
        MaterialSlice(
          key: _SaltedKey<BuildContext, int>(context, index * 2),
          color: child.backgroundColor,
          child: Column(
            children: <Widget>[
              header,
              AnimatedCrossFade(
                firstChild: Container(height: 0.0),
                secondChild: child.body,
                firstCurve:
                    const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
                secondCurve:
                    const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
                sizeCurve: Curves.fastOutSlowIn,
                crossFadeState: _isChildExpanded(index)
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: widget.animationDuration,
              ),
            ],
          ),
        ),
      );
    }

    return MergeableMaterial(
      hasDividers: widget.hasDividers ?? false,
      elevation: 0,
      children: items,
    );
  }
}

class VulcanXExpandIcon extends StatefulWidget {
  const VulcanXExpandIcon({
    super.key,
    this.isExpanded = false,
    this.onPressed,
  });

  final bool isExpanded;
  final ValueChanged<bool>? onPressed;

  @override
  State<VulcanXExpandIcon> createState() => _VulcanXExpandIconState();
}

class _VulcanXExpandIconState extends State<VulcanXExpandIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconTurns;

  static final Animatable<double> _iconTurnTween =
      Tween<double>(begin: 0.0, end: 0.5)
          .chain(CurveTween(curve: Curves.fastOutSlowIn));

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: kThemeAnimationDuration, vsync: this);
    _iconTurns = _controller.drive(_iconTurnTween);

    if (widget.isExpanded) {
      _controller.value = math.pi;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VulcanXExpandIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void _handlePressed() {
    widget.onPressed?.call(widget.isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      child: InkWell(
        onTap: widget.onPressed == null ? null : _handlePressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: RotationTransition(
            turns: _iconTurns,
            child: const Icon(Icons.expand_more),
          ),
        ),
      ),
    );
  }
}
