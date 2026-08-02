import 'package:fitness_day/features/user/auth/data/models/user_lookups_model.dart';
import 'package:fitness_day/features/user/auth/data/models/health_questions_model.dart';
import 'package:fitness_day/features/user/auth/data/models/submit_health_answers_models.dart';
import 'package:fitness_day/features/user/auth/domain/entities/profile_validation_key.dart';
import 'package:fitness_day/core/errors/app_error.dart';

sealed class UserSetupState {
  const UserSetupState();
}

class UserSetupInitial extends UserSetupState {
  const UserSetupInitial();
}

class UserSetupLoading extends UserSetupState {
  const UserSetupLoading();
}

class UserLookupsLoadSuccess extends UserSetupState {
  final List<LookupItem> goals;
  final List<LookupItem> activityLevels;
  final List<LookupItem> branches;
  const UserLookupsLoadSuccess({
    required this.goals,
    required this.activityLevels,
    required this.branches,
  });
}

class CompletePersonalDataSuccess extends UserSetupState {
  final String message;
  const CompletePersonalDataSuccess(this.message);
}

class HealthQuestionsLoadSuccess extends UserSetupState {
  final List<HealthQuestion> questions;
  const HealthQuestionsLoadSuccess(this.questions);
}

class SubmitHealthAnswersSuccess extends UserSetupState {
  final BodyReportModel bodyReport;
  final bool isSubscribed;
  final String message;
  const SubmitHealthAnswersSuccess({
    required this.bodyReport,
    required this.isSubscribed,
    required this.message,
  });
}

class UserSetupFailure extends UserSetupState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  /// Set when the backend rejected one specific field (`key` in the error
  /// body). The screen that owns that field shows [message] under it instead
  /// of a generic snack bar.
  final ProfileValidationKey? fieldKey;

  const UserSetupFailure(this.message, {this.fieldKey, this.error});
}
