import 'package:dota2_quiz/screens/quizScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Dota 2 Quiz!',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: new QuizScreen(),
    );
  }
}
