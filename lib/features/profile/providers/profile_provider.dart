import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/models/user_model.dart';

// ── Profile State ──────────────────────────────────────────────────────
class ProfileState {
  final UserModel? user;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  const ProfileState({
    this.user,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  ProfileState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

// ── Profile Notifier ───────────────────────────────────────────────────
class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState()) {
    loadUser();
  }

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // ── Load user from Firestore ───────────────────────────────────
  Future<void> loadUser() async {
    state = state.copyWith(isLoading: true);
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        state = state.copyWith(
          isLoading: false,
          user: UserModel.fromMap(doc.data()!),
        );
      } else {
        // Fallback from Firebase Auth
        final fbUser = _auth.currentUser!;
        state = state.copyWith(
          isLoading: false,
          user: UserModel(
            uid: fbUser.uid,
            fullName: fbUser.displayName ?? 'Farmer',
            email: fbUser.email ?? '',
            createdAt: DateTime.now(),
          ),
        );
      }
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load profile.',
      );
    }
  }

  // ── Update farm name ───────────────────────────────────────────
  Future<void> updateFarmName(String farmName) async {
    if (state.user == null) return;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _firestore
          .collection('users')
          .doc(state.user!.uid)
          .update({'farmName': farmName.trim()});

      state = state.copyWith(
        isSaving: false,
        user: state.user!.copyWith(farmName: farmName.trim()),
        successMessage: 'Farm name updated!',
      );
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Could not update farm name.',
      );
    }
  }

  // ── Logout ─────────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
    state = const ProfileState();
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

// ── Provider ───────────────────────────────────────────────────────────
final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(),
);
