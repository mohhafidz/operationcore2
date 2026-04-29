import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:operationcore2/model/appuser.dart';
import 'package:operationcore2/repository/authrepository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// FIRESTORE
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// REPOSITORY
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(firestoreProvider));
});

/// STATE
class AuthState {
  final AppUser? user;
  final bool isLoading;

  AuthState({this.user, this.isLoading = false});

  AuthState copyWith({AppUser? user, bool? isLoading}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// NOTIFIER
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthNotifier(this.repository) : super(AuthState());

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true);

    final user = await repository.login(username: username, password: password);

    if (user == null) {
      state = state.copyWith(isLoading: false);
      return false;
    }

    state = AuthState(user: user, isLoading: false);

    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_username');
    await prefs.remove('saved_password');
    await prefs.remove('remember_me');
    state = AuthState();
  }
}

/// PROVIDER
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});
