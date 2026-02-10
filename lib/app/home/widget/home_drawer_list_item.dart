import 'package:app_ui/app_ui.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/widgets.dart';

class HomeDrawerListItem extends StatelessWidget {
  final Widget? prefixIcon;
  final String title;
  final VoidCallback onTap;
  final Widget? suffixIcon;

  const HomeDrawerListItem({
    this.prefixIcon,
    required this.title,
    required this.onTap,
    this.suffixIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWellContainer(
        onTap: onTap,
        width: double.infinity,
        height: 40,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              if (prefixIcon != null) prefixIcon!,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AutoSizeText(
                    title,
                    style: context.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (suffixIcon != null) suffixIcon!,
            ],
          ),
        ),
      ),
    );
  }
}
