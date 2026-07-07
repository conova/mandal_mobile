import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mandal_capital/screens/components/register/register_contact_info.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/custom_input.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../common/validators.dart';

class RegisterForm extends StatefulWidget {
  final VoidCallback onRegister;
  final TextEditingController regNoController;
  final TextEditingController phoneController;
  final TextEditingController lastNameController;
  final TextEditingController firstNameController;
  final bool isLoading;

  const RegisterForm({
    super.key,
    required this.onRegister,
    required this.regNoController,
    required this.phoneController,
    required this.lastNameController,
    required this.firstNameController,
    this.isLoading = false,
  });

  @override
  State<RegisterForm> createState() => RegisterFormState();
}

class RegisterFormState extends State<RegisterForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
    final filled =
        widget.regNoController.text.trim().isNotEmpty &&
        widget.phoneController.text.trim().isNotEmpty &&
        widget.lastNameController.text.trim().isNotEmpty &&
        widget.firstNameController.text.trim().isNotEmpty;
    if (filled != _isButtonEnabled) {
      setState(() => _isButtonEnabled = filled);
    }
  }

  void _handleSubmit() {
    if (widget.isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onRegister();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomInput(
            label: l10n.registrationNumber,
            controller: widget.regNoController,
            keyboardType: TextInputType.text,
            inputFormatters: [
              // 10 оронгоор хязгаарлах: 2 үсэг + 8 хүртэл тоо
              LengthLimitingTextInputFormatter(10),
              FilteringTextInputFormatter.allow(
                RegExp(r'[А-ЯӨҮЁа-яөүёA-Za-z0-9]'),
              ),
            ],
            validator: (v) => Validators.validateMongolianRegister(v, l10n),
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: l10n.phoneNumber,
            controller: widget.phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              LengthLimitingTextInputFormatter(8),
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: (v) => Validators.validateMongolianPhone(v, l10n),
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: l10n.lastName,
            hint: '',
            controller: widget.lastNameController,
            validator: (v) =>
                Validators.validateName(v, l10n, fieldName: l10n.lastName),
          ),
          const SizedBox(height: 16),
          CustomInput(
            label: l10n.firstName,
            hint: '',
            controller: widget.firstNameController,
            validator: (v) =>
                Validators.validateName(v, l10n, fieldName: l10n.firstName),
          ),
          const SizedBox(height: 24),
          const RegisterContactInfo(),
          const SizedBox(height: 24),
          CustomButton(
            label: l10n.register,
            onPressed: _isButtonEnabled && !widget.isLoading
                ? _handleSubmit
                : null,
            isLoading: widget.isLoading,
            variant: CustomButtonVariant.primary,
          ),
        ],
      ),
    );
  }
}
