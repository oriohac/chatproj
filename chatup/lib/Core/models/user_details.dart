class Userdetails {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String? token;

  Userdetails({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.token
  });
  factory Userdetails.fromJson(Map<String, dynamic> json) {
    return Userdetails(
      id: json['id'],
      email: json['email'],
      firstname: json['first_name'],
      lastname: json['last_name'],
      token: json['token']
    );
  }
}
