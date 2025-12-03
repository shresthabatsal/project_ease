import 'package:flutter/material.dart';
import 'package:project_ease/screens/login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        backgroundColor: Colors.yellow,
      ),
      body: Padding(padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                }, child: Text("Login", style: TextStyle(fontSize: 20),)),
            )
          ],
        ),
      ),),
    );
  }
}