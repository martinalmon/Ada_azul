class AppUser {
  const AppUser({required this.email, required this.displayName, this.photoUrl});
  final String email;
  final String displayName;
  final String? photoUrl;
}
