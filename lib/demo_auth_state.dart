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
  String? dob;
  String? profilePicUrl;
  bool isAdmin = false;
  Uint8List? avatarBytes;

  String get displayName =>
      [firstName, lastName].where((part) => part.trim().isNotEmpty).join(' ').trim();

  void signIn({
    required String email,
    required int id,
    String? password,
    String? first,
    String? last,
    String? dob,
    String? profilePicUrl,
    bool isAdmin = false,
  }) {
    lastEmail = email.trim();
    if (password != null) {
      this.password = password;
    }
    userId = id;
    this.isAdmin = isAdmin;
    if (first != null && first.trim().isNotEmpty) {
      firstName = first.trim();
    }
    if (last != null) {
      lastName = last.trim();
    }
    this.dob = dob;
    this.profilePicUrl = profilePicUrl;
    isSignedIn.value = true;
  }

  void signOut() {
    isSignedIn.value = false;
    lastEmail = null;
    userId = null;
    dob = null;
    profilePicUrl = null;
    isAdmin = false;
    firstName = 'Traveler';
    lastName = '';
    avatarBytes = null;
  }

  void updateProfile({
    String? first,
    String? last,
    Uint8List? avatar,
    String? dob,
    String? profilePicUrl,
  }) {
    if (first != null && first.trim().isNotEmpty) {
      firstName = first.trim();
    }
    if (last != null) {
      lastName = last.trim();
    }
    if (dob != null) {
      this.dob = dob;
    }
    if (profilePicUrl != null) {
      this.profilePicUrl = profilePicUrl;
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
