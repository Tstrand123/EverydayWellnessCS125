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
//Add exercise data from prev day as well?
class SleepLog {
  DateTime bedTime; //when they go to bed
  DateTime awakeTime; //when they wake up
  double rating;

  SleepLog({
    required this.bedTime, //date from
    required this.awakeTime, //date to
    required this.rating,
  });

  Map<String, dynamic> toJson() => {
    'bedTime': bedTime,
    'awakeTime': awakeTime,
    'rating': rating,
  };
  
  static SleepLog fromJson(Map<String, dynamic> json) => SleepLog(
      bedTime: DateTime.parse(json['bedTime']),
      awakeTime: DateTime.parse(json['awakeTime']),
      rating: double.parse(json['rating']));
}