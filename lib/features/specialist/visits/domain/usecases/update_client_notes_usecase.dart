import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_update_client_notes_model.dart';
import 'package:fitness_day/features/specialist/visits/domain/repositories/specialist_visits_repository.dart';

class UpdateClientNotesUseCase {
  final SpecialistVisitsRepository repository;

  UpdateClientNotesUseCase(this.repository);

  Future<ApiResult<SpecialistUpdateClientNotesResponseModel>> call({
    required String assessmentId,
    required String clientNotes,
  }) {
    return repository.updateClientNotes(
      assessmentId: assessmentId,
      clientNotes: clientNotes,
    );
  }
}
