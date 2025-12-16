import 'dart:typed_data';

import 'package:flutter/foundation.dart';

class DemoAuthState {
  DemoAuthState._();

  static final DemoAuthState instance = DemoAuthState._();

  final ValueNotifier<bool> isSignedIn = ValueNotifier<bool>(false);
  final ValueNotifier<int> profileVersion = ValueNotifier<int>(0);
  String? lastEmail;
  String firstName = 'Traveler';
  String lastName = '';
  String password = 'password';
  Uint8List? avatarBytes;

  String get displayName =>
      [firstName, lastName].where((part) => part.trim().isNotEmpty).join(' ').trim();

  void signIn(String email, String password) {
    lastEmail = email.trim();
    this.password = password;
    isSignedIn.value = true;
  }

  void signOut() {
    isSignedIn.value = false;
    lastEmail = null;
  }

  void updateProfile({String? first, String? last, Uint8List? avatar}) {
    if (first != null && first.trim().isNotEmpty) {
      firstName = first.trim();
    }
    if (last != null) {
      lastName = last.trim();
    }
    if (avatar != null) {
      avatarBytes = avatar;
    }
    profileVersion.value++;
  }

  bool verifyPassword(String value) => value == password;

  void updatePassword(String newPassword) {
    password = newPassword;
    profileVersion.value++;
  }
}
