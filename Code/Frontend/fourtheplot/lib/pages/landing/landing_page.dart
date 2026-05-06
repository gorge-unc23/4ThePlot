import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fourtheplot/pages/login/login_page.dart';
import 'package:fourtheplot/pages/signup/signup_page.dart';
import 'package:fourtheplot/widgets/glassmorphism.dart';
import 'package:fourtheplot/widgets/gradient_text.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final List<String> _taglines = [
    'Vibe with us',
    'Plot your events',
    'Party on',
    'Find your crowd',
    'Make tonight count',
  ];

  final Duration _taglineInterval = Duration(seconds: 4);
  final Duration _taglineSwitchDuration = Duration(seconds: 1);

  int _taglineIndex = 0;
  Timer? _taglineTimer;

  @override
  void initState() {
    super.initState();
    _taglineTimer = Timer.periodic(_taglineInterval, (_) {
      if (!mounted) return;
      setState(() {
        _taglineIndex = (_taglineIndex + 1) % _taglines.length;
      });
    });
  }

  @override
  void dispose() {
    _taglineTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background/partyVibe.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 120),
                child: AnimatedSwitcher(
                  duration: _taglineSwitchDuration,
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final isIncoming = child.key == ValueKey(_taglines[_taglineIndex]);
                    final offsetTween = Tween<Offset>(
                      begin: isIncoming ? const Offset(1, 0) : const Offset(-1, 0),
                      end: Offset.zero,
                    ).chain(CurveTween(curve: Curves.easeInOut));

                    return ClipRect(
                      child: SlideTransition(
                        position: animation.drive(offsetTween),
                        child: child,
                      ),
                    );
                  },
                  child: SizedBox(
                    key: ValueKey(_taglines[_taglineIndex]),
                    width: double.infinity,
                    height: 150,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GradientText(
                            _taglines[_taglineIndex],
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade700, Colors.purple.shade600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 70),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: TextStyle(letterSpacing: 0),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => LoginPage()),
                              );
                            },
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[300],
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.blue[300],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Glassmorphism(
                      color: Colors.white,
                      child: TextButton(
                        style: ButtonStyle(
                          overlayColor: WidgetStateProperty.all(
                            Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => SignupPage()),
                          );
                        },
                        child: Text("Sign up with email"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
