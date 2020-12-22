import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dota2_quiz/models/questionModel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class AnswerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Results!"),
      ),

      body: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var dataBase = FirebaseFirestore.instance.collection("questions").snapshots();

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: dataBase,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width-30,


                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                          width: 3,
                          color: Colors.red
                      )
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                            width: MediaQuery.of(context).size.width-100,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(snapshot.data.documents[index]["question"],
                              style: TextStyle(fontSize: 20),),
                            )
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Text(CheckList.isAnswered[index]),
                        )
                      ],
                    ),
                  ),
                );
              },
          );
        }
    );
  }
}
