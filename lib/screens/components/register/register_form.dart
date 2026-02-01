import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/custom_input.dart';
import '../../../../widgets/custom_button.dart';

class RegisterForm extends StatefulWidget {
  final VoidCallback onRegister;
  final TextEditingController regNoController;
  final TextEditingController phoneController;
  final TextEditingController lastNameController;
  final TextEditingController firstNameController;

  const RegisterForm({
    super.key,
    required this.onRegister,
    required this.regNoController,
    required this.phoneController,
    required this.lastNameController,
    required this.firstNameController,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    widget.regNoController.addListener(_checkFields);
    widget.phoneController.addListener(_checkFields);
    widget.lastNameController.addListener(_checkFields);
    widget.firstNameController.addListener(_checkFields);
  }

  @override
  void dispose() {
    widget.regNoController.removeListener(_checkFields);
    widget.phoneController.removeListener(_checkFields);
    widget.lastNameController.removeListener(_checkFields);
    widget.firstNameController.removeListener(_checkFields);
    super.dispose();
  }

  void _checkFields() {
    setState(() {
      _isButtonEnabled =
          widget.regNoController.text.isNotEmpty &&
          widget.phoneController.text.isNotEmpty &&
          widget.lastNameController.text.isNotEmpty &&
          widget.firstNameController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        CustomInput(
          label: l10n.registrationNumber,
          hint: '',
          controller: widget.regNoController,
        ),
        const SizedBox(height: 16),
        CustomInput(
          label: l10n.phoneNumber,
          hint: '',
          controller: widget.phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        CustomInput(
          label: l10n.lastName,
          hint: '',
          controller: widget.lastNameController,
        ),
        const SizedBox(height: 16),
        CustomInput(
          label: l10n.firstName,
          hint: '',
          controller: widget.firstNameController,
        ),
        const SizedBox(height: 24),
        CustomButton(
          label: l10n.register,
          onPressed: _isButtonEnabled ? widget.onRegister : null,
          variant: CustomButtonVariant.primary,
        ),
      ],
    );
  }
}
