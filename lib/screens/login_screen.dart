import 'package:flutter/material.dart';
import '../widgets/auth/auth_app_bar.dart';
import 'components/login/login_header.dart';
import 'components/login/login_form.dart';
import '../widgets/auth/story_carousel.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoStory();
    });
  }

  void _checkAutoStory() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['showStory'] == true) {
      _showStory();
    } else {
      final authService = Provider.of<AuthService>(context, listen: false);
      final bool hasSavedUser = authService.hasSavedUser;
      if (hasSavedUser) {
        Navigator.pushReplacementNamed(context, '/quick_login');
      }
    }
  }

  void _showStory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => StoryCarousel(
          onClose: () {
            Navigator.of(context).pop();
            _markStoryAsShown();
          },
          onLoginPressed: () {
            Navigator.of(context).pop();
            _markStoryAsShown();
          },
          onRegisterPressed: () {
            Navigator.of(context).popAndPushNamed('/register');
            _markStoryAsShown();
          },
        ),
      ),
    );
  }

  void _markStoryAsShown() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.setStoryShown();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AuthAppBar(
        showLogo: true,
        onClose: () {
          _showStory();
        },
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LoginHeader(),
            SizedBox(height: 32),
            Expanded(child: LoginForm()),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
