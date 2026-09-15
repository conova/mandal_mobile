import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/api_config.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_button.dart';
import 'components/shared/deposit_info_row.dart';

/// Долларын данс цэнэглэх — банкны шилжүүлгийн мэдээлэл.
///
/// Мандал Капиталын хоёр банкны данснаас сонгож шилжүүлэх боломжтой;
/// дансны дугаар хоёуланд нь ижил бөгөөд гүйлгээний утгаар (uid +
/// регистрийн дугаар) харилцагчийг ялгана.
class UsdDepositInfoScreen extends StatefulWidget {
  const UsdDepositInfoScreen({super.key});

  @override
  State<UsdDepositInfoScreen> createState() => _UsdDepositInfoScreenState();
}

class _UsdDepositInfoScreenState extends State<UsdDepositInfoScreen> {
  /// Хүлээн авах данс — банк солигдсон ч дугаар ижил
  static const String _accountNo = '5055224020';

  /// Худалдаа хөгжлийн банк — 04, Голомт банк — 15 (лого server-ээс)
  static const String _tdbCode = '04';
  static const String _golomtCode = '15';

  /// 0 — Худалдаа хөгжлийн банк, 1 — Голомт банк
  int _selectedBank = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedBank);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    final info = context.read<AuthService>().userInfo;
    final auth = context.read<AuthService>();
    // Гүйлгээний утга — uid болон регистрийн дугаарын нийлбэр
    final memo =
        '${info?['registerNumber']?.toString() ?? ''}, ${auth.uid ?? ''}';

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CircleBackButton(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        l10n.usdDepositTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: extendedColors.neutral100,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          l10n.depositInfoSubtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: extendedColors.neutral200,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildBankTabs(theme, l10n, extendedColors),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 290,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _selectedBank = index;
                          });
                        },
                        children: [
                          _buildBankInfo(0, theme, l10n, extendedColors, memo),
                          _buildBankInfo(1, theme, l10n, extendedColors, memo),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: extendedColors.neutral500),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: l10n.finish,
                  onPressed: () => _finish(context),
                  variant: CustomButtonVariant.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Банк сонгох segmented control — сонгосон нь цагаан дэвсгэртэй
  Widget _buildBankTabs(
    ThemeData theme,
    AppLocalizations l10n,
    ExtendedColors extendedColors,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          _buildBankTab(0, l10n.bankTdbShort, theme, extendedColors),
          _buildBankTab(1, l10n.bankGolomt, theme, extendedColors),
        ],
      ),
    );
  }

  Widget _buildBankTab(
    int index,
    String label,
    ThemeData theme,
    ExtendedColors extendedColors,
  ) {
    final isSelected = _selectedBank == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _pageController.jumpToPage(
            index,
          );
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          decoration: BoxDecoration(
            color: isSelected ? extendedColors.bgBase : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? extendedColors.neutral100
                    : extendedColors.neutral200,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBankInfo(
    int bankIndex,
    ThemeData theme,
    AppLocalizations l10n,
    ExtendedColors extendedColors,
    String memo,
  ) {
    final isTdb = bankIndex == 0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DepositInfoRow(
            label: l10n.receiverBank,
            value: isTdb ? l10n.bankTdb : l10n.bankGolomt,
            trailing: ClipOval(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(4),
                child: Image.network(
                  ApiConfig.bankLogoUrl(
                    isTdb ? _tdbCode : _golomtCode,
                  ),
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.account_balance,
                    size: 32,
                    color: extendedColors.neutral200,
                  ),
                ),
              ),
            ),
          ),
          DepositInfoRow(
            label: l10n.accountNo,
            value: _accountNo,
            copyValue: _accountNo,
          ),
          DepositInfoRow(
            label: l10n.receiver,
            value: l10n.mandalCapital,
            copyValue: l10n.mandalCapital,
          ),
          DepositInfoRow(
            label: l10n.transactionMemo,
            value: memo.isNotEmpty ? memo : '-',
            copyValue: memo,
            isLast: true,
          ),
        ],
      ),
    );
  }

  /// Үндсэн дэлгэц рүү буцна (stack-д /main байвал popUntil)
  void _finish(BuildContext context) {
    var mainFound = false;
    Navigator.popUntil(context, (route) {
      if (route.settings.name == '/main') {
        mainFound = true;
        return true;
      }
      return route.isFirst;
    });
    if (!mainFound) {
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
    }
  }
}
