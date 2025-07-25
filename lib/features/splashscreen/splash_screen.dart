import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lottie/lottie.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:uni_connect/features/frontpage/front_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _popController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool showText = false;

  @override
  void initState() {
    super.initState();

    _popController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _popController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _popController, curve: Curves.easeIn));

    // Trigger pop-in after splash hits (frame 48 ~1600ms)
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) {
        _popController.forward();
        setState(() => showText = true);
      }
    });

    // Go to front page after ~3.5s
    // After delay, check auth state and navigate
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Not logged in
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // Logged in
        navigateToFrontPage(context);
      }
    });
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0e0e2c),
      body: Stack(
        children: [
          // Splash animation (non-looping)
          Center(
            child: Lottie.asset(
              'assets/animations/intro.json',
              width: 400,
              height: 400,
              fit: BoxFit.contain,
              repeat: false,
            ),
          ),

          // Bouncy UniConnect text
          if (showText)
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Uni',
                        style: GoogleFonts.poppins(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 20,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Connect',
                        style: GoogleFonts.poppins(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyanAccent,
                          shadows: [
                            Shadow(
                              blurRadius: 20,
                              color: Colors.cyanAccent.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Go to front page
void navigateToFrontPage(BuildContext context) {
  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const FrontPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeIn,
        );

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    ),
  );
}
