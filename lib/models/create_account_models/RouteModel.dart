class RouteModel {
  final String uid;
  final String username;
  final String name;
  final String email;
  final String address;
  final String phone;
  final String role;
  final String profilePicture;
  final String documents_url;
  final String is_documents_verified;
  final String createdAt;
  final String updatedAt;
  final String isPhoneVerified;
  final String isEmailVerified;
  final String isAdminApproved;
  final String isProfileCompleted;

  RouteModel({
    required this.uid,
    required this.username,
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
    required this.role,
    required this.profilePicture,
    this.documents_url = "0",
    this.is_documents_verified = "0",
    required this.createdAt,
    required this.updatedAt,
    this.isPhoneVerified = "0",
    this.isEmailVerified = "0",
    this.isAdminApproved = "0",
    this.isProfileCompleted = "0",
  });

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "username": username,
      "name": name,
      "email": email,
      "address" : address,
      "phone": phone,
      "role": role,
      "profile_picture": profilePicture,
      "documents_url": documents_url,
      "is_documents_verified" : is_documents_verified,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "is_phone_verified": isPhoneVerified,
      "is_email_verified": isEmailVerified,
      "is_admin_approved": isAdminApproved,
      "is_profile_completed": isProfileCompleted,

    };
  }
}
