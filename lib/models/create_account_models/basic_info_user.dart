
class UserBasicDetailsModel {
  final String uid;
  final String name;
  final String email;
  final String address;
  final String phone;
  final String profilePicture;

  UserBasicDetailsModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
    required this.profilePicture,
  });

  Map<String, dynamic> toJson() {
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
