import 'package:flutter/material.dart';
import '../../common/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/extended_colors.dart';
import '../../widgets/circle_back_button.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

/// Хүүхдийн данс нээх — 1-р алхам: хүүхдийн регистрийн дугаар оруулах.
class ChildAccountRegisterScreen extends StatefulWidget {
  const ChildAccountRegisterScreen({super.key});

  @override
  State<ChildAccountRegisterScreen> createState() =>
      _ChildAccountRegisterScreenState();
}

class _ChildAccountRegisterScreenState
    extends State<ChildAccountRegisterScreen> {
  final TextEditingController _registerController = TextEditingController();

  @override
  void dispose() {
    _registerController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _registerController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Back товч + алхмын заалт
              Row(
                children: [
                  const CircleBackButton(),
                  const Spacer(),
                  _StepChip(label: '1/3', extendedColors: extendedColors),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                l10n.childRegisterTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: extendedColors.neutral100,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.childRegisterDesc,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w200,
                  color: extendedColors.neutral200,
                ),
              ),
              const SizedBox(height: 24),
              CustomInput(
                label: l10n.registrationNumber,
                controller: _registerController,
                validator: (v) =>
                    Validators.validateMongolianRegister(v, l10n),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (_) => setState(() {}),
              ),
              const Spacer(),
              CustomButton(
                label: l10n.register,
                onPressed: _isValid
                    ? () => Navigator.pushNamed(
                          context,
                          '/child_account_document',
                          arguments: {
                            'register': _registerController.text.trim(),
                          },
                        )
                    : null,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Баруун дээд булангийн алхмын товч (1/3)
class _StepChip extends StatelessWidget {
  final String label;
  final ExtendedColors extendedColors;
  const _StepChip({required this.label, required this.extendedColors});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400,
          color: extendedColors.neutral100,
        ),
      ),
    );
  }
}
