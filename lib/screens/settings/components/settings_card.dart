import 'package:flutter/material.dart';
import 'package:hashed/components/divider_jungle.dart';
import 'package:hashed/components/notification_badge.dart';
import 'package:hashed/domain-shared/ui_constants.dart';
import 'package:hashed/utils/ThemeBuildContext.dart';

class SettingsCard extends StatelessWidget {
  /// Card icon
  final Widget icon;

  /// The text title in the first row
  final String title;

  /// The description text in the second row
  final String description;

  /// The widget in the right side of the title
  final Widget? titleWidget;

  final GestureTapCallback? onTap;

  final bool hasNotification;
  final Color? backgroundColor;
  final Color? textColor;

  const SettingsCard({
    super.key,
    required this.icon,
    required this.title,
    this.description = '',
    this.titleWidget,
    this.onTap,
    this.hasNotification = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor ?? context.colorScheme.surface,
            borderRadius: BorderRadius.circular(defaultCardBorderRadius),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 8.0),
                    child: icon,
                  ),
                ],
              ),
              Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0, bottom: 10.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        color: textColor ?? context.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  if (hasNotification) const NotificationBadge()
                                ],
                              ),
                            ),
                          ),
                          if (titleWidget != null) titleWidget!,
                        ],
                      ),
                      const DividerJungle(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16, top: 6),
                        child: Row(
                          children: [
                            Flexible(
                                child: Text(
                              description,
                              style: context.textTheme.titleSmall!.copyWith(
                                color: (textColor ?? context.colorScheme.onSurface).withAlpha(180),
                              ),
                            ))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
