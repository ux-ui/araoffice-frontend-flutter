import 'package:flutter/material.dart';

import '../theme/theme_extension.dart';
import '../typography/app_text_styles.dart';

class SectionCard extends StatelessWidget {
  /// {@macro section_card}
  const SectionCard({
    required this.title,
    required this.child,
    this.description,
    this.titleStyle = TextStyles.titleMedium,
    this.actions = const [],
    this.isRequired = false,
    super.key,
  });

  /// {@macro isRequired}
  final bool isRequired;

  /// {@macro title}
  final String title;

  /// {@macro description}
  final String? description;

  /// {@macro titleStyle}
  final TextStyle titleStyle;

  /// {@macro child}
  final Widget child;

  /// {@macro actions}
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                EdgeInsets.fromLTRB(16, 10, actions.isNotEmpty ? 4 : 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: titleStyle.apply(
                                color: context.onBackground,
                              ),
                            ),
                          ),
                          if (isRequired)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                '*',
                                style: TextStyles.bodyMedium.apply(
                                  color: context.error,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (description != null)
                        SizedBox(
                          child: Text(
                            description!,
                            style: TextStyles.bodySmall.apply(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ...actions,
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: child,
          ),
        ],
      ),
    );
  }
}
