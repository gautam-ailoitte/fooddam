// lib/src/presentation/cubits/profile/profile_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';

enum ProfileStatus { initial, loading, loaded, updating, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final User? user;
  final List<Address> addresses;
  final bool isUpdating;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.addresses = const [],
    this.isUpdating = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    User? user,
    List<Address>? addresses,
    bool? isUpdating,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      addresses: addresses ?? this.addresses,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => status == ProfileStatus.loading || isUpdating;

  @override
  List<Object?> get props => [status, user, addresses, isUpdating, errorMessage];
}