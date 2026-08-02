import 'package:equatable/equatable.dart';
import 'package:fitness_day/features/shared/conversations/data/models/user_conversation_model.dart';
import 'package:fitness_day/core/errors/app_error.dart';

sealed class ContactUsState extends Equatable {
  const ContactUsState();

  @override
  List<Object?> get props => [];
}

class ContactUsInitial extends ContactUsState {
  const ContactUsInitial();
}

class ContactUsLoading extends ContactUsState {
  const ContactUsLoading();
}

class ContactUsLoaded extends ContactUsState {
  final UserConversation? conversation;

  const ContactUsLoaded({this.conversation});

  bool get hasSpecialistChat => conversation != null && conversation!.otherParty != null;

  @override
  List<Object?> get props => [conversation];
}

class ContactUsError extends ContactUsState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const ContactUsError(this.message, {this.error});

  @override
  List<Object?> get props => [message, error];
}
