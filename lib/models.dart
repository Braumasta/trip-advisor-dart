class User {
  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isAdmin,
    this.token,
    this.profilePicUrl,
    this.dob,
  });

  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final bool isAdmin;
  final String? token;
  final String? profilePicUrl;
  final String? dob;

  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    return User(
      id: (json['id'] ?? 0) as int,
      email: (json['email'] ?? '') as String,
      firstName: (json['first_name'] ?? '') as String,
      lastName: (json['last_name'] ?? '') as String,
      isAdmin: (json['is_admin'] ?? 0) == 1,
      profilePicUrl: json['profile_pic_url'] as String?,
      dob: json['dob'] as String?,
      token: token,
    );
  }
}

class Country {
  Country({
    required this.id,
    required this.name,
    required this.description,
    required this.flagAsset,
    required this.accentHex,
  });

  final int id;
  final String name;
  final String description;
  final String flagAsset;
  final String accentHex;

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      flagAsset: (json['flag_asset'] ?? '') as String,
      accentHex: (json['accent_hex'] ?? '000000') as String,
    );
  }
}

class Tip {
  Tip({
    required this.id,
    required this.kind,
    required this.tip,
    required this.position,
  });

  final int id;
  final String kind;
  final String tip;
  final int position;

  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      id: (json['id'] ?? 0) as int,
      kind: (json['kind'] ?? '') as String,
      tip: (json['tip'] ?? '') as String,
      position: (json['position'] ?? 0) as int,
    );
  }
}
