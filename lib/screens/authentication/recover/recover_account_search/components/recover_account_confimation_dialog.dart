import 'package:flutter/material.dart';
import 'package:hashed/components/custom_dialog.dart';

class RecoverAccountConfirmationDialog extends StatelessWidget {
  final GestureTapCallback? onDismiss;
  final GestureTapCallback? onConfirm;
  final String account;

  const RecoverAccountConfirmationDialog({
    super.key,
    this.onConfirm,
    this.onDismiss,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      iconPadding: 0,
      rightButtonTitle: "Yes",
      onRightButtonPressed: onConfirm,
      leftButtonTitle: "Cancel",
      onLeftButtonPressed: onDismiss,
      children: [
        const SizedBox(height: 20),
        Text("Recover Account?", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text('Are you sure you want to recover\n$account'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
