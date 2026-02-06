import 'package:flutter/material.dart';
import '../widgets/logo_full.dart';
import 'package:mandal_capital/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  void _startApp() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final bool isLoggedIn = authService.isAuthenticated;
    final bool hasShownStory = authService.hasShownStory;
    final bool hasSavedUser = authService.hasSavedUser;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      if (!hasShownStory) {
        // Navigate to login with a flag to show story
        Navigator.pushReplacementNamed(
          context,
          '/login',
          arguments: {'showStory': true},
        );
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Таны тодорхойлсон үндсэн өнгө
      backgroundColor: AppColors.primaryMain,
      body: const Center(
        child: AppLogoFull(
          width: 156, // Таны хүссэн хэмжээ
          color: Colors.white,
        ),
      ),
    );
  }
}
