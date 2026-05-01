import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/custom_input.dart';
import '../../../../widgets/custom_button.dart';

class ForgotPasswordForm extends StatefulWidget {
  final VoidCallback onContinue;
  final TextEditingController regNoController;
  final TextEditingController phoneController;
  final bool isLoading;

  const ForgotPasswordForm({
    super.key,
    required this.onContinue,
    required this.regNoController,
    required this.phoneController,
    this.isLoading = false,
  });

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    widget.regNoController.addListener(_checkFields);
    widget.phoneController.addListener(_checkFields);
  }

  @override
  void dispose() {
    widget.regNoController.removeListener(_checkFields);
    widget.phoneController.removeListener(_checkFields);
    super.dispose();
  }

  void _checkFields() {
    setState(() {
      _isButtonEnabled =
          widget.regNoController.text.isNotEmpty &&
          widget.phoneController.text.isNotEmpty;
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
        const SizedBox(height: 48),
        CustomButton(
          label: l10n.continueBtn,
          onPressed: _isButtonEnabled && !widget.isLoading ? widget.onContinue : null,
          isLoading: widget.isLoading,
          variant: CustomButtonVariant.primary,
        ),
      ],
    );
  }
}
