class UserCredentials {
  final String id;
  final String token;

  UserCredentials({
    required this.id,
    required this.token,
  });

  static UserCredentials empty = UserCredentials(
    id: '',
    token: '',
  );
}
