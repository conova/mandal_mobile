import 'package:flutter/material.dart';
import '../widgets/auth/auth_app_bar.dart';
import 'components/login/login_header.dart';
import 'components/login/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AuthAppBar(
        showLogo: true,
        onClose: () {}, 
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LoginHeader(),
            SizedBox(height: 32),
            Expanded(
              child: LoginForm(),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
