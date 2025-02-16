import 'package:hashed/blocs/deeplink/viewmodels/deeplink_bloc.dart';
import 'package:hashed/datasource/local/account_service.dart';
import 'package:hashed/datasource/local/models/scan_qr_code_result_data.dart';
import 'package:hashed/domain-shared/result_to_state_mapper.dart';
import 'package:hashed/utils/string_extension.dart';

class ScanQRCodeStateMapper extends StateMapper {
  DeeplinkState mapSigningRequestToState(DeeplinkState currentState, Result result) {
    if (result.isError) {
      return currentState;
    } else {
      final esr = result.asValue!.value as ScanQrCodeResultData;
      if (!accountService.currentAccount.address.isNullOrEmpty) {
        // handle invite link. Send user to memonic screen.
        return currentState.copyWith(signingRequest: esr);
      } else {
        //  If user is not logged in, Ignore esr link
        return currentState;
      }
    }
  }
}
