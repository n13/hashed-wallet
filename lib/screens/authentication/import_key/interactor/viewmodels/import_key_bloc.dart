import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hashed/datasource/local/models/auth_data_model.dart';
import 'package:hashed/domain-shared/page_command.dart';
import 'package:hashed/domain-shared/page_state.dart';
import 'package:hashed/navigation/navigation_service.dart';
import 'package:hashed/screens/authentication/import_key/interactor/usecases/check_private_key_use_case.dart';

part 'import_key_event.dart';

part 'import_key_state.dart';

const int wordsMax = 12;

class ImportKeyBloc extends Bloc<ImportKeyEvent, ImportKeyState> {
  ImportKeyBloc() : super(ImportKeyState.initial()) {
    on<OnMnemonicPhraseChange>(_onMnemonicPhraseChange);
    on<GetAccountByKey>(_findAccountByKey);

    on<AccountSelected>((event, emit) => emit(state.copyWith(accountSelected: event.account)));
    on<ClearPageCommand>((event, emit) => emit(state.copyWith()));
  }

  void _onMnemonicPhraseChange(OnMnemonicPhraseChange event, Emitter<ImportKeyState> emit) {
    emit(state.copyWith(enableButton: event.newMnemonicPhrase.isNotEmpty, mnemonicPhrase: event.newMnemonicPhrase));
  }

  Future<void> _findAccountByKey(GetAccountByKey event, Emitter<ImportKeyState> emit) async {
    emit(state.copyWith(isButtonLoading: true));
    final publicKeyValdiation = await CheckPrivateKeyUseCase().isKeyValid(state.mnemonicPhrase);

    if (publicKeyValdiation.isError) {
      emit(state.copyWith(
        error: "Invalid mnemonic: ${publicKeyValdiation.errorMessage}",
        isButtonLoading: false,
        enableButton: false,
      ));
    } else {
      final publicKey = publicKeyValdiation.publicKey!;
      final autData = AuthDataModel.fromString(state.mnemonicPhrase);
      emit(state.copyWith(
        isButtonLoading: false,
        accounts: [publicKey],
        authData: autData,
        pageCommand: NavigateToRouteWithArguments(route: Routes.createNickname, arguments: [publicKey, autData]),
      ));
    }
  }
}
