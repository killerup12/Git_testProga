import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dota2_quiz/models/questionModel.dart';
import 'package:dota2_quiz/tools/networkTools.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'answerScreen.dart';

int questionIndex = 0;
int countQuestions;

bool isFree = false;
bool isMultipleChoice = false;
bool isOneOfSeveral = true;
bool isYN = false;

String futureType;


//Для множ ответов используются числа:
int textForSwitch1 = 1; //23
int textForSwitch2 = 2; //29
int textForSwitch3 = 3; //31
int textForSwitch4 = 4; //2

double localAnswerForMultipleChoice = 1;


var answer;

String govnoAnswer;

class QuizScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dota 2 Quiz!"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.assignment),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AnswerScreen()));
              }),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                "Question",
                style: TextStyle(fontSize: 32),
              ),
              QuestionWindow(),
              // SkipButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionWindow extends StatefulWidget {
  getLocalVar() {}
  @override
  _QuestionWindowState createState() => _QuestionWindowState();
}

class _QuestionWindowState extends State<QuestionWindow> {
  var dataBase = FirebaseFirestore.instance.collection("questions").snapshots();

  List<QuestionModel> questions;
  static int questionIndexLocal;

  @override
  void initState() {
    super.initState();
    checkInternet().checkConnection(context);
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });
    questionIndexLocal = questionIndex;
    for (int i = 0; i < 10; i++) {
      //todo Костыль!!!!
      CheckList.isAnswered[i] = "N";
    }
  }

  // @override
  // void dispose() {
  //   checkInternet().listener.cancel();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            // height: 200,
            width: MediaQuery.of(context).size.width - 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade300,
              border: Border.all(color: Colors.red.shade300),
            ),

            child: StreamBuilder(
              stream: dataBase,
              builder: (context, snapshot) {
                try {
                if (!snapshot.hasData) return CircularProgressIndicator();

                countQuestions = snapshot.data.documents.length;
                answer = snapshot.data.documents[questionIndexLocal]['answer'];
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      snapshot.data.documents[questionIndexLocal]["question"],
                      //todo
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Langar",
                        fontSize: 18,
                      ),
                    ),
                  ),
                ); //todo add шрифт
                } catch (Exception) {
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
          Container(
            // height: 200,
            width: MediaQuery.of(context).size.width - 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade300,
              border: Border.all(color: Colors.red.shade300),
            ),

            child: StreamBuilder(
              stream: dataBase,
              builder: (context, snapshot) {
                try {
                  if (!snapshot.hasData) return CircularProgressIndicator();

                  String answerOptions = snapshot
                      .data.documents[questionIndexLocal]["answerOptions"];
                  int localIndex = 0;
                  String localAnswer = "";
                  int numberOfAnswerOption = 1;

                  futureType = snapshot.data
                      .documents[(questionIndexLocal + 1) % countQuestions]
                  ["type"];

                  while (localIndex != answerOptions.length) {
                    if (localIndex == 0) {
                      localAnswer +=
                      "$numberOfAnswerOption)  ${answerOptions[localIndex]}";
                      numberOfAnswerOption++;
                    } else if (answerOptions[localIndex] == ";") {
                      localAnswer += "\n$numberOfAnswerOption) ";
                      numberOfAnswerOption++;
                    } else {
                      localAnswer += answerOptions[localIndex];
                    }
                    localIndex++;
                  }
                  numberOfAnswerOption = 1;

                  if (localAnswer.isEmpty) {
                    localAnswer = "Free answer!";
                  }

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      localAnswer,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ); //todo add шрифт
                } catch (Exception) {
                  return CircularProgressIndicator();
                }
              },
            ),
          ),







          Visibility(
              visible: isFree,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width - 200,
                      child: TextField(
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(prefixText: "Answer..."),
                        onChanged: (String usersAnswer) {
                          govnoAnswer = usersAnswer;
                        },
                      ),
                    ),
                    IconButton(
                        icon: Icon(Icons.arrow_forward_rounded),
                        onPressed: () {
                          setState(() {
                            CheckList.usersAnswers[questionIndex] = govnoAnswer;
                            CheckList.isAnswered[questionIndex] = "T";
                            checkAnswer(context, govnoAnswer, answer.toString());

                            skipQuestion(context);
                          });
                        }),
                    IconButton(
                        icon: Icon(Icons.next_plan),
                        onPressed: () {
                          setState(() {
                            skipQuestion(context);
                          });
                        })
                  ])),











          Visibility(
            visible: isOneOfSeveral,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 20),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3,
                        height: 80,
                        color: Colors.red, //todo передалать для темы!

                        child: InkWell(
                          child: Center(
                              child: Text(
                            "1",
                            style: TextStyle(fontSize: 30, color: Colors.white),
                          )),
                          onTap: () {
                            CheckList.usersAnswers[questionIndex] = "1";
                            checkAnswer(context, "1", answer.toString());

                            setState(() {
                              skipQuestion(context);
                            });
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 20),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3,
                        height: 80,
                        color: Colors.red, //todo передалать для темы!

                        child: InkWell(
                          child: Center(
                              child: Text(
                            "2",
                            style: TextStyle(fontSize: 30, color: Colors.white),
                          )),
                          onTap: () {
                            CheckList.usersAnswers[questionIndex] = "2";
                            checkAnswer(context, "2", answer.toString());

                            setState(() {
                              skipQuestion(context);
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 20),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3,
                        height: 80,
                        color: Colors.red, //todo передалать для темы!

                        child: InkWell(
                          child: Center(
                              child: Text(
                            "3",
                            style: TextStyle(fontSize: 30, color: Colors.white),
                          )),
                          onTap: () {
                            CheckList.usersAnswers[questionIndex] = "3";
                            checkAnswer(context, "3", answer.toString());

                            setState(() {
                              skipQuestion(context);
                            });
                          },
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 30, horizontal: 20),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 3,
                          height: 80,
                          color: Colors.red, //todo передалать для темы!

                          child: InkWell(
                            child: Center(
                                child: Text(
                              "4",
                              style:
                                  TextStyle(fontSize: 30, color: Colors.white),
                            )),
                            onTap: () {
                              CheckList.usersAnswers[questionIndex] = "4";
                              checkAnswer(context, "4", answer.toString());

                              setState(() {
                                skipQuestion(context);
                              });
                            },
                          ),
                        )),
                  ],
                ),
                IconButton(
                    icon: Icon(
                      Icons.next_plan,
                      size: 50,
                    ),
                    onPressed: () {
                      setState(() {
                        //todo add check заверешшные вопросы
                        skipQuestion(context);
                      });
                    })
              ],
            ),
          ),











          Visibility(
            visible: isMultipleChoice,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 20),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3,
                        height: 80,
                        color: Colors.red, //todo передалать для темы!

                        child: InkWell(
                          child: Center(
                              child: _checkMark(textForSwitch1),
                          ),
                          onTap: () {
                            setState(() {
                              textForSwitch1 = (textForSwitch1-1).abs();
                              if (textForSwitch1 == 0) {
                                localAnswerForMultipleChoice =
                                    localAnswerForMultipleChoice * 23;
                              } else {
                                localAnswerForMultipleChoice =
                                    localAnswerForMultipleChoice / 23;
                              }

                            });
                            }
                            )
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 20),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3,
                        height: 80,
                        color: Colors.red, //todo передалать для темы!

                        child: InkWell(
                          child: Center(
                            child: _checkMark(textForSwitch2),
                          ),
                          onTap: () {
                            setState(() {
                              textForSwitch2 = (textForSwitch2-2).abs();
                              if (textForSwitch2 == 0) {
                                localAnswerForMultipleChoice =
                                    localAnswerForMultipleChoice * 29;
                              } else {
                                localAnswerForMultipleChoice =
                                    localAnswerForMultipleChoice / 29;
                              }

                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 20),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3,
                        height: 80,
                        color: Colors.red, //todo передалать для темы!

                        child: InkWell(
                          child: Center(
                            child: _checkMark(textForSwitch3),
                          ),
                          onTap: () {
                            setState(() {
                              textForSwitch3 = (textForSwitch3-3).abs();
                              if (textForSwitch3 == 0) {
                                localAnswerForMultipleChoice =
                                    localAnswerForMultipleChoice * 31;
                              } else {
                                localAnswerForMultipleChoice =
                                    localAnswerForMultipleChoice / 31;
                              }

                            });
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 20),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3,
                        height: 80,
                        color: Colors.red, //todo передалать для темы!

                        child: InkWell(
                          child: Center(
                            child: _checkMark(textForSwitch4),
                          ),
                          onTap: () {
                            setState(() {
                              textForSwitch4 = (textForSwitch4-4).abs();
                              if (textForSwitch4 == 0) {
                                localAnswerForMultipleChoice =
                                    localAnswerForMultipleChoice * 31;
                              } else {
                                localAnswerForMultipleChoice =
                                localAnswerForMultipleChoice / 31;
                              }

                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 4,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(width: 5, color: Colors.black)
                      ),

                      child: InkWell(
                          child: Text("Ok", textAlign: TextAlign.center, style: TextStyle(fontSize: 40)),
                          onTap: () {
                            setState(() {
                              CheckList.usersAnswers[questionIndex] = localAnswerForMultipleChoice.toString();
                              checkAnswer(context, localAnswerForMultipleChoice.toString(), answer.toString());
                              skipQuestion(context);
                            });
                          }
                      ),
                    ),

                    IconButton(
                        icon: Icon(
                          Icons.next_plan,
                          size: 50,
                        ),
                        onPressed: () {
                          setState(() {
                            //todo add check заверешшные вопросы
                            skipQuestion(context);
                          });
                        }),
                  ],
                )
              ],
            ),
          ),








          Visibility(
              visible: isYN,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 30, horizontal: 20),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 3,
                          height: 80,
                          color: Colors.red, //todo передалать для темы!

                          child: InkWell(
                            child: Center(
                                child: Text(
                                  "Yes",
                                  style: TextStyle(fontSize: 30, color: Colors.white),
                                )),
                            onTap: () {
                              CheckList.usersAnswers[questionIndex] = "1";
                              checkAnswer(context, "1", answer.toString());

                              setState(() {
                                skipQuestion(context);
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 30, horizontal: 20),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 3,
                          height: 80,
                          color: Colors.red, //todo передалать для темы!

                          child: InkWell(
                            child: Center(
                                child: Text(
                                  "No",
                                  style: TextStyle(fontSize: 30, color: Colors.white),
                                )),
                            onTap: () {
                              CheckList.usersAnswers[questionIndex] = "2";
                              checkAnswer(context, "2", answer.toString());

                              setState(() {
                                skipQuestion(context);
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          )
        ],
      ),
    );
  }

  void doSetStateWithoutAnything() {
    setState(() {});
  }

  Widget _checkMark(int number) {
    if (number != 0) {
      return Text("$number",
        style: TextStyle(fontSize: 30, color: Colors.white),);
    } else {
      return Icon(Icons.add, color: Colors.white,);
    }
  }
}

void skipQuestion(BuildContext context) {
  // questionIndex = (questionIndex + 1) % countQuestions;
  int localVar = 0;

  do {
    localVar++;
    questionIndex = (questionIndex + 1) % countQuestions;
  } while (CheckList.isIn(questionIndex) & (localVar != countQuestions));

  if (localVar == countQuestions) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AnswerScreen()));
  }

  print(questionIndex);
  print(CheckList.usersAnswers.toString());
  _QuestionWindowState.questionIndexLocal = questionIndex;

  switch (futureType) {
    case "oneOfSeveral":
      {
        isFree = false;
        isMultipleChoice = false;
        isOneOfSeveral = true;
        isYN = false;
        break;
      }
    case "free":
      {
        isFree = true;
        isMultipleChoice = false;
        isOneOfSeveral = false;
        isYN = false;
        break;
      }
    case "multipleChoice":
      {
        isFree = false;
        isMultipleChoice = true;
        isOneOfSeveral = false;
        isYN = false;
        break;
        
        
      }
    case "yN":
      {
        isFree = false;
        isMultipleChoice = false;
        isOneOfSeveral = false;
        isYN = true;
        break;
      }
  }
}

void checkAnswer(BuildContext context, String usersAnswer, String answer) {
  if (usersAnswer == answer) {
    Scaffold.of(context).showSnackBar(new SnackBar(
      duration: Duration(milliseconds: 400),
      content: Text("Correct!"),
      backgroundColor: Colors.green,
    ));
    CheckList.isAnswered[questionIndex] = "T";
  } else {
    Scaffold.of(context).showSnackBar(new SnackBar(
      duration: Duration(milliseconds: 400),
      content: Text("Wrong!"),
      backgroundColor: Colors.red,
    ));
    CheckList.isAnswered[questionIndex] = "F";
  }
}