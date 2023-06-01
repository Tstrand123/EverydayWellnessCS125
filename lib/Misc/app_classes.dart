import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String userID;
  String firstName;
  String lastName;
  String birthDate;
  int heightFeet;
  int heightInches;
  int weight;
  List<MealRating> ratings;

  AppUser({
    required this.userID,
    required this.firstName,
    required this.lastName,
    required this.heightFeet,
    required this.heightInches,
    required this.weight,
    required this.birthDate,
    required this.ratings,
  });

  Map<String, dynamic> toJson() => {
        'userID': userID,
        'firstName': firstName,
        'lastName': lastName,
        'heightFeet': heightFeet,
        'heightInches': heightInches,
        'weight': weight,
    'birthDate': birthDate,
    'ratings': [],
      };

  static AppUser fromJson(Map<String, dynamic> json) {
    var tempLoop = json['ratings'] ?? [];
    List<MealRating> newList = [];
    for (var subjson in tempLoop) {
      newList.add(subjson);
    }

    return AppUser(
      userID: json['userID'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      heightFeet: json['heightFeet'],
      heightInches: json['heightInches'],
      weight: json['weight'],
      birthDate: json['birthDate'],
      ratings: newList, //TODO: This may not work to get all the ratings - do a separate loop
    );
  }
}

//Will be auto collected
//Add exercise data from prev day as well?
class SleepLog {
  String userID;
  DateTime bedTime; //when they go to bed
  DateTime awakeTime; //when they wake up
  double rating;

  SleepLog({
    required this.userID,
    required this.bedTime, //date from
    required this.awakeTime, //date to
    required this.rating,
  });

  Map<String, dynamic> toJson() => {
        'userID': userID,
        'bedTime': bedTime,
        'awakeTime': awakeTime,
        'rating': rating,
      };

  static SleepLog fromJson(Map<String, dynamic> json) => SleepLog(
        userID: json['userID'],
        bedTime: json['bedTime'].toDate(),
        awakeTime: json['awakeTime'].toDate(),
        rating: json['rating'],
      );
}

class ExerciseLog {
  int hours;
  int minutes;
  int seconds;
  String startTime;
  String type;

  ExerciseLog({
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.startTime,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'hours': hours,
        'minutes': minutes,
        'seconds': seconds,
        'startTime': startTime,
        'type': type, // Walk, run, or bicycle.
      };

  static ExerciseLog fromJson(Map<String, dynamic> json) => ExerciseLog(
        hours: int.parse(json['hours']),
        minutes: int.parse(json['minutes']),
        seconds: int.parse(json['seconds']),
        startTime: json['startTime'],
        type: json['type'],
      );
}

class MealData { //TODO: add meal id
  int calories;
  int carbs;
  int fat;
  String main_flavors;
  String meal_type;
  String name;
  int protein;
  String tags;

  MealData({
    required this.calories,
    required this.carbs,
    required this.fat,
    required this.main_flavors,
    required this.meal_type,
    required this.name,
    required this.protein,
    required this.tags,
  });

  Map<String, dynamic> toJson() => {
    'calories': calories,
    'carbs': carbs,
    'fat': fat,
    'main_flavors': main_flavors,
    'meal_type': meal_type,
    'name': name,
    'protein': protein,
    'tags': tags,
  };
  
  static MealData fromJson(Map<String,dynamic> json) => MealData(
      calories: int.parse(json['calories']),
      carbs: int.parse(json['carbs']),
      fat: int.parse(json['fat']),
      main_flavors: json['main_flavors'],
      meal_type: json['meal_type'],
      name: json['name'],
      protein: int.parse(json['protein']),
      tags: json['tags']);
}

class MealRating{
  // preset value not incorporated, currently, only rate preset meals
 // bool preset; // indicates if it was a preset meal (non-presets should not be used by the ML)
  String meal_id;
  double rating;

  MealRating({
    //required this.preset,
    required this.meal_id,
    required this.rating
  });

  Map<String, dynamic> toJson() => {
    //'preset': preset,
    'meal_id': meal_id,
    'rating': rating
  };
  
  static MealRating fromJson(Map<String,dynamic> json) => MealRating(
      meal_id: json['meal_id'],
      rating: double.parse(json['rating']));
}

// NOTE: ratings and nutrition data *could* be merged into a single collection, indexed by userID, keeping separate for now
class NutritionData{
  DateTime mealTime; // this is the index of the meals subcollection
  String name;
  int calories;
  int fat;
  int carbs;
  int protein;
  // TODO? add (optional) reference to rating?

  NutritionData({
    required this.mealTime,
    required this.name,
    required this.calories,
    required this.fat,
    required this.carbs,
    required this.protein,
});

  Map<String, dynamic> toJson() =>{
    'mealTime': mealTime,
    'name': name,
    'calories': calories,
    'fat': fat,
    'carbs': carbs,
    'protein': protein
  };
}