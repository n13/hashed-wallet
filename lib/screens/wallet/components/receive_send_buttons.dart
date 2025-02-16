import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hashed/navigation/navigation_service.dart';
import 'package:hashed/screens/wallet/components/tokens_cards/interactor/viewmodels/token_balances_bloc.dart';
import 'package:hashed/utils/build_context_extension.dart';

// ignore: must_be_immutable
class ReceiveSendButtons extends StatelessWidget {
  const ReceiveSendButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TokenBalancesBloc, TokenBalancesState>(
      buildWhen: (previous, current) => previous.selectedIndex != current.selectedIndex,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: MaterialButton(
                  padding: const EdgeInsets.only(top: 14, bottom: 14),
                  onPressed: () => NavigationService.of(context).navigateTo(Routes.transfer),
                  // color: tokenColor ?? AppColors.green1,
                  // disabledColor: tokenColor ?? AppColors.green1,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(50),
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Center(
                    child: Wrap(
                      children: [
                        const Icon(Icons.arrow_upward),
                        Container(
                          padding: const EdgeInsets.only(left: 4, top: 4),
                          child: Text(context.loc.walletSendButtonTitle, style: Theme.of(context).textTheme.labelLarge),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: MaterialButton(
                  padding: const EdgeInsets.only(top: 14, bottom: 14),
                  onPressed: () => NavigationService.of(context).navigateTo(Routes.receiveEnterData),
                  // color: tokenColor ?? AppColors.green1,
                  // disabledColor: tokenColor ?? AppColors.green1,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Center(
                    child: Wrap(
                      children: [
                        const Icon(Icons.arrow_downward),
                        Container(
                          padding: const EdgeInsets.only(left: 4, top: 4),
                          child:
                              Text(context.loc.walletReceiveButtonTitle, style: Theme.of(context).textTheme.labelLarge),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
