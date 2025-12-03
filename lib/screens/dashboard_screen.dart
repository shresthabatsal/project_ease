import 'package:flutter/material.dart';
import 'package:project_ease/screens/login_screen.dart';
import 'package:project_ease/widgets/custom_button.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        backgroundColor: Colors.yellow,
      ),
      body: Padding(padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: CustomButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              }, text: "Login Screen")
            )
          ],
        ),
      ),),
    );
  }
}