import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';
import '../widgets/auth/auth_app_bar.dart';
import '../widgets/auth/auth_footer.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _regNoController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _regNoController.addListener(_checkFields);
    _phoneController.addListener(_checkFields);
    _lastNameController.addListener(_checkFields);
    _firstNameController.addListener(_checkFields);
  }

  @override
  void dispose() {
    _regNoController.dispose();
    _phoneController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    super.dispose();
  }

  void _checkFields() {
    setState(() {
      _isButtonEnabled = _regNoController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty &&
          _lastNameController.text.isNotEmpty &&
          _firstNameController.text.isNotEmpty;
    });
  }

  void _handleRegister() {
    if (!_isButtonEnabled) return;
    // Navigate to OTP verification
    Navigator.pushNamed(context, '/register_otp', arguments: {
      'phone': _phoneController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Unused isDark check removed as AuthAppBar handles it via theme
    // final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AuthAppBar(
        showLogo: true,
        onClose: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              l10n.registerTitle,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.registerSubtitle,
              style: TextStyle(color: theme.disabledColor, fontSize: 16),
            ),
            const SizedBox(height: 48),
            CustomInput(
              label: l10n.registrationNumber,
              hint: '',
              controller: _regNoController,
            ),
            const SizedBox(height: 16),
            CustomInput(
              label: l10n.phoneNumber,
              hint: '',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            CustomInput(
              label: l10n.lastName,
              hint: '',
              controller: _lastNameController,
            ),
            const SizedBox(height: 16),
            CustomInput(
              label: l10n.firstName,
              hint: '',
              controller: _firstNameController,
            ),
            const SizedBox(height: 24),
            Text(
              'Та байгууллагаар бүртгүүлэх бол',
              style: TextStyle(color: theme.disabledColor, fontSize: 14),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'info@mandal.capital',
                style: TextStyle(
                  color: Color(0xFF1E8675),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'хаягт хүсэлтээ илгээнэ үү.',
              style: TextStyle(color: theme.disabledColor, fontSize: 14),
            ),
            const SizedBox(height: 48),
            CustomButton(
              label: l10n.register,
              onPressed: _isButtonEnabled ? _handleRegister : null,
              variant: CustomButtonVariant.primary,
            ),
            const SizedBox(height: 16),
            AuthFooter(
              questionText: 'Нэвтэх хаяг байгаа?',
              actionText: 'Нэвтрэх',
              onAction: () => Navigator.pop(context),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
