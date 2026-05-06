import 'package:flutter/material.dart';
import 'package:fourtheplot/pages/landing/landing_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile page")),
      body: Center(
        child: TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LandingPage()),
              (route) => false,
            );
          },
          child: const Text("Logout"),
        ),
      ),
    );
  }
}
