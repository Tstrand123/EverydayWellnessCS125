class appUser {
  String userID;
  String firstName;
  String lastName;
  int heightFeet;
  int heightInches;
  int weight;

  appUser ({
    required this.userID,
    required this.firstName,
    required this.lastName,
    required this.heightFeet,
    required this.heightInches,
    required this.weight,
  });

  Map<String, dynamic> toJson() => {
    'userID': userID,
    'firstName': firstName,
    'lastName': lastName,
    'heightFeet':heightFeet,
    'heightInches':heightInches,
    'weight': weight,
  };

  static appUser fromJson(Map<String,dynamic> json) => appUser(
    userID: json['userID'],
    firstName: json['firstName'],
    lastName: json['lastName'],
    heightFeet: json['heightFeet'],
    heightInches: json['heightInches'],
    weight: json['weight'],
  );

}