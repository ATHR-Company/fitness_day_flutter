import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/shared/conversations/domain/usecases/get_user_chat_usecase.dart';
import 'package:fitness_day/features/user/support/presentation/manager/contact_us_state.dart';

class ContactUsCubit extends Cubit<ContactUsState> {
  final GetUserChatUseCase _getUserChatUseCase;

  ContactUsCubit({
    required GetUserChatUseCase getUserChatUseCase,
  })  : _getUserChatUseCase = getUserChatUseCase,
        super(const ContactUsInitial());

  /// Calls GET /chat to fetch the active conversation for the user.
  Future<void> fetchUserChat() async {
    emit(const ContactUsLoading());
    final result = await _getUserChatUseCase();
    if (result is Success) {
      final conv = (result as Success).data;
      emit(ContactUsLoaded(conversation: conv));
    } else if (result is FailureResult) {
      // In case of error (e.g. 404 or network), assume no conversation so AI stays accessible
      emit(const ContactUsLoaded(conversation: null));
    }
  }
}
