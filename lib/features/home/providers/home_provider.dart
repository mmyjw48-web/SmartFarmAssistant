import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/models/user_model.dart';

/// Fetches the current user's Firestore profile reactively.
/// Used by HomeScreen to show the greeting and user name.
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final firebaseUser = FirebaseAuth.instance.currentUser;
  if (firebaseUser == null) return null;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(firebaseUser.uid)
      .get();

  if (doc.exists && doc.data() != null) {
    return UserModel.fromMap(doc.data()!);
  }

  // Fallback: build from Firebase Auth data if Firestore doc missing
  return UserModel(
    uid: firebaseUser.uid,
    fullName: firebaseUser.displayName ?? 'Farmer',
    email: firebaseUser.email ?? '',
    createdAt: DateTime.now(),
  );
});

/// Tracks which bottom nav tab is currently selected (0–4).
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
