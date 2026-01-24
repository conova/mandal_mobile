import 'package:flutter/material.dart';
import '../widgets/logo_full.dart';
import 'package:mandal_capital/theme/app_colors.dart';

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
  
  final bool isLoggedIn = false; 

  if (mounted) {
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/main');
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
