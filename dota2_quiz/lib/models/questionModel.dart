import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dota2_quiz/main.dart';

class QuestionModel {
  String question;
  String answerOptions;
  String answer;

  List<QuestionModel> questionsList;

  QuestionModel(this.question, this.answerOptions, this.answer);
}

class CheckList {
  static Map usersAnswers = new Map<int, String>();

  static Map isAnswered = new Map<int, String>();



  static bool isIn(int questionNumber) {
    bool answer;

    usersAnswers.keys.forEach((element) {
      if (element == questionNumber) {
        print("Повторение!");
        print("Ключ: $element");
        print("true");
        answer = true;
      }
    });

    if (answer == null) {
      answer = false;
    }
    return answer;
  }
}