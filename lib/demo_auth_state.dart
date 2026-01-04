import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'api_client.dart';

class DemoAuthState {
  DemoAuthState._();

  static final DemoAuthState instance = DemoAuthState._();

  final ValueNotifier<bool> isSignedIn = ValueNotifier<bool>(false);
  final ValueNotifier<int> profileVersion = ValueNotifier<int>(0);
  String? lastEmail;
  int? userId;
  String firstName = 'Traveler';
  String lastName = '';
  String password = 'password';
  String? token;
  bool isAdmin = false;
  Uint8List? avatarBytes;

  String get displayName =>
      [firstName, lastName].where((part) => part.trim().isNotEmpty).join(' ').trim();

  void signIn({
    required String email,
    String? password,
    int? id,
    String? first,
    String? last,
    String? token,
    bool isAdmin = false,
  }) {
    lastEmail = email.trim();
    if (password != null) {
      this.password = password;
    }
    userId = id;
    this.token = token;
    this.isAdmin = isAdmin;
    if (first != null && first.trim().isNotEmpty) {
      firstName = first.trim();
    }
    if (last != null) {
      lastName = last.trim();
    }
    isSignedIn.value = true;
  }

  void signOut() {
    isSignedIn.value = false;
    lastEmail = null;
    userId = null;
    token = null;
    isAdmin = false;
    firstName = 'Traveler';
    lastName = '';
    ApiClient().saveToken(null);
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
