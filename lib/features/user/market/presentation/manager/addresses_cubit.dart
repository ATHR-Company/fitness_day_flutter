import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/market/domain/entities/address_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_address_usecase.dart';
import '../../domain/usecases/delete_address_usecase.dart';
import '../../domain/usecases/get_addresses_usecase.dart';
import '../../domain/usecases/update_address_usecase.dart';
import 'package:fitness_day/core/errors/app_error.dart';

sealed class AddressesState {
  const AddressesState();
}

class AddressesInitial extends AddressesState {
  const AddressesInitial();
}

class AddressesLoading extends AddressesState {
  const AddressesLoading();
}

class AddressesSuccess extends AddressesState {
  final List<AddressData> addresses;
  final String? selectedAddressId;
  final bool isMutating;

  const AddressesSuccess(
    this.addresses, {
    this.selectedAddressId,
    this.isMutating = false,
  });

  AddressesSuccess copyWith({
    List<AddressData>? addresses,
    String? selectedAddressId,
    bool? isMutating,
  }) {
    return AddressesSuccess(
      addresses ?? this.addresses,
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
      isMutating: isMutating ?? this.isMutating,
    );
  }
}

class AddressesFailure extends AddressesState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const AddressesFailure(this.message, {this.error});
}

class AddressesCubit extends Cubit<AddressesState> {
  final GetAddressesUseCase _getAddressesUseCase;
  final CreateAddressUseCase _createAddressUseCase;
  final UpdateAddressUseCase _updateAddressUseCase;
  final DeleteAddressUseCase _deleteAddressUseCase;

  AddressesCubit({
    required GetAddressesUseCase getAddressesUseCase,
    required CreateAddressUseCase createAddressUseCase,
    required UpdateAddressUseCase updateAddressUseCase,
    required DeleteAddressUseCase deleteAddressUseCase,
  })  : _getAddressesUseCase = getAddressesUseCase,
        _createAddressUseCase = createAddressUseCase,
        _updateAddressUseCase = updateAddressUseCase,
        _deleteAddressUseCase = deleteAddressUseCase,
        super(const AddressesInitial());

  Future<void> load() async {
    emit(const AddressesLoading());
    final result = await _getAddressesUseCase();
    if (result is Success<List<AddressData>>) {
      final addresses = result.data;
      String? selectedId;
      if (addresses.isNotEmpty) {
        final defaults = addresses.where((a) => a.isDefault);
        selectedId = defaults.isNotEmpty ? defaults.first.id : addresses.first.id;
      }
      emit(AddressesSuccess(addresses, selectedAddressId: selectedId));
    } else if (result is FailureResult<List<AddressData>>) {
      emit(AddressesFailure(result.failure.message, error: AppError.from(result.failure)));
    }
  }

  void selectAddress(String id) {
    final current = state;
    if (current is AddressesSuccess) {
      emit(current.copyWith(selectedAddressId: id));
    }
  }

  Future<bool> createAddress(AddressInput input) async {
    final current = state;
    if (current is AddressesSuccess) emit(current.copyWith(isMutating: true));

    final result = await _createAddressUseCase(input);
    if (result is Success<AddressData>) {
      await load();
      selectAddress(result.data.id);
      return true;
    }
    if (current is AddressesSuccess) emit(current.copyWith(isMutating: false));
    return false;
  }

  Future<bool> updateAddress(String id, AddressInput input) async {
    final current = state;
    if (current is AddressesSuccess) emit(current.copyWith(isMutating: true));

    final result = await _updateAddressUseCase(id, input);
    if (result is Success<AddressData>) {
      await load();
      return true;
    }
    if (current is AddressesSuccess) emit(current.copyWith(isMutating: false));
    return false;
  }

  Future<bool> deleteAddress(String id) async {
    final current = state;
    if (current is AddressesSuccess) emit(current.copyWith(isMutating: true));

    final result = await _deleteAddressUseCase(id);
    if (result is Success<void>) {
      await load();
      return true;
    }
    if (current is AddressesSuccess) emit(current.copyWith(isMutating: false));
    return false;
  }
}
