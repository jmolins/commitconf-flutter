import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() {
    return new SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('session').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return ListView(
          padding: const EdgeInsets.only(top: 20.0),
          children: snapshot.data.documents.map((data) {
            return Text(data['title']);
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: _buildBody(context),
        ),
      ),
    );
  }
}
