class AppUser {
  String userID;
  String firstName;
  String lastName;
  int heightFeet;
  int heightInches;
  int weight;

  AppUser({
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
        'heightFeet': heightFeet,
        'heightInches': heightInches,
        'weight': weight,
      };

  static AppUser fromJson(Map<String, dynamic> json) => AppUser(
        userID: json['userID'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        heightFeet: json['heightFeet'],
        heightInches: json['heightInches'],
        weight: json['weight'],
      );
}

//Will be auto collected
class SleepLog {

}