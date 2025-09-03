class UserModel {
  final String uid;
  final String name;
  final String email;
  final String address;
  final String phone;
  final String profilePicture;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
    required this.profilePicture,
  });

  // Factory method to create a UserModel from a Map
  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      uid: map["uid"] ?? "",
      name: map["name"] ?? "",
      email: map["email"] ?? "",
      address: map["address"] ?? "",
      phone: map["phone"] ?? "",
      profilePicture: map["profile_picture"] ?? "",
    );
  }

  // Convert UserModel to a Map
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "address": address,
      "phone": phone,
      "profile_picture": profilePicture,
    };
  }
}
