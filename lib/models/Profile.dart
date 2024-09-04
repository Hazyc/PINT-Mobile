class EditProfileArguments {
  final String bannerImageUrl;
  final String avatarImageUrl;
  final String userName;
  final String userDescription;
  final Function(String, String, String, String, String) onSave;

  EditProfileArguments({
    required this.bannerImageUrl,
    required this.avatarImageUrl,
    required this.userName,
    required this.userDescription,
    required this.onSave,
  });
}