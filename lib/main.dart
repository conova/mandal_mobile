import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'l10n/app_localizations.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/components_screen.dart';
import 'screens/theme_colors_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/main_container.dart';
import 'screens/profile_screen.dart';
import 'screens/quick_login_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/notification_detail_screen.dart';
import 'screens/order_detail_screen.dart';
import 'screens/stock_detail_screen.dart';
import 'screens/stock_trading_screen.dart';
import 'screens/stock_success_screen.dart';
import 'screens/stock_confirmation_screen.dart';
import 'screens/currency_detail_screen.dart';
import 'screens/bond_portfolio_screen.dart';
import 'screens/stock_portfolio_screen.dart';
import 'screens/income_method_screen.dart';
import 'screens/income_amount_screen.dart';
import 'screens/income_success_screen.dart';
import 'screens/withdraw_method_screen.dart';
import 'screens/withdraw_amount_screen.dart';
import 'screens/withdraw_success_screen.dart';
import 'screens/transaction_history_screen.dart';
import 'screens/release_locked_amount_screen.dart';
import 'screens/my_info_screen.dart';
import 'screens/income_account_screen.dart';
import 'screens/add_income_account_screen.dart';
import 'screens/summary_report_screen.dart';
import 'screens/connected_devices_screen.dart';
import 'screens/change_password_verify_screen.dart';
import 'screens/change_password_code_screen.dart';
import 'screens/change_password_new_screen.dart';
import 'screens/income_account_detail_screen.dart';
import 'screens/login_verification_screen.dart';
import 'screens/login_otp_screen.dart';
import 'screens/new_device_screen.dart';
import 'screens/biometric_enrollment_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/forgot_password_verification_screen.dart';
import 'screens/forgot_password_otp_screen.dart';
import 'screens/forgot_password_new_screen.dart';
import 'screens/register_screen.dart';
import 'screens/register_otp_screen.dart';
import 'screens/register_password_screen.dart';
import 'screens/register_bank_selection_screen.dart';
import 'screens/register_income_account_screen.dart';
import 'screens/register_success_screen.dart';
import 'screens/bond/bond_detail_screen.dart';
import 'screens/bond/bond_main_screen.dart';
import 'screens/bond/bond_buy_screen.dart';
import 'screens/bond/bond_confirmation_screen.dart';
import 'screens/bond/pledge_bond_select_screen.dart';
import 'screens/bond/pledge_bond_order_screen.dart';
import 'screens/bond/pledge_bond_confirmation_screen.dart';
import 'screens/bond/bond_success_screen.dart';
import 'screens/bond/bond_sell_screen.dart';
import 'screens/bond/bond_sell_confirmation_screen.dart';
import 'screens/bond/bond_sell_success_screen.dart';
import 'screens/watchlist_detail_screen.dart';
import 'screens/add_watchlist_screen.dart';
import 'screens/pep_question_screen.dart';
import 'screens/dan_verification_screen.dart';
import 'screens/pep_definition_screen.dart';
import 'screens/securities_agreement_screen.dart';
import 'screens/document_verification_screen.dart';
import 'screens/camera_overlay_screen.dart';
import 'screens/onboarding_success_screen.dart';
import 'screens/payment_qpay_screen.dart';
import 'screens/payment_result_screen.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/notification_api_service.dart';
import 'services/payment_service.dart';
import 'services/dan_service.dart';
import 'screens/webview_screen.dart';
import 'theme/app_colors.dart';
import 'theme/extended_colors.dart';
import 'theme/app_state_manager.dart';
import 'theme/app_text_styles.dart';
import 'package:provider/provider.dart';

/// Глобал navigatorKey — widget tree-ийн гаднаас navigation хийхэд ашиглана
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Нэвтрэлт шаардахгүй нээлттэй route-ууд
const Set<String> _publicRoutes = {
  '/',
  '/login',
  '/quick_login',
  '/login_verification',
  '/login_otp',
  '/new_device',
  '/biometric_enrollment',
  '/forgot_password',
  '/forgot_password_verification',
  '/forgot_password_otp',
  '/forgot_password_new',
  '/register',
  '/register_otp',
  '/register_password',
  '/register_bank_selection',
  '/register_income_account',
  '/register_success',
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init — бодит config байхгүй бол алдааг бариж app ажиллуулна
  NotificationService? notificationService;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Background message handler бүртгэх
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Notification service init
    notificationService = NotificationService();
    await notificationService.init();
  } catch (e) {
    debugPrint('[Firebase] Init алдаа (mock config?): $e');
  }

  final authService = AuthService();
  await authService.init();

  // FCM token → deviceId
  if (notificationService != null) {
    final fcmToken = notificationService.fcmToken;
    if (fcmToken != null) {
      await authService.setDeviceId(fcmToken);
    }

    // Token шинэчлэгдэхэд deviceId-г бас шинэчлэх
    notificationService.onTokenRefresh = (newToken) {
      authService.setDeviceId(newToken);
    };
  }

  final apiService = ApiService(
    authService,
    onLogout: () {
      // Token refresh амжилтгүй → login руу шилжүүлэх
      authService.clearSession();
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    },
  );

  // Payment Gateway microservice client
  final paymentService = PaymentService(authService);

  // Notification Gateway microservice client
  final notificationApiService = NotificationApiService(authService);

  // DAN (E-Mongolia) verification microservice client
  final danService = DanService(authService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AppStateManager.instance),
        ChangeNotifierProvider.value(value: authService),
        Provider.value(value: apiService),
        Provider.value(value: paymentService),
        Provider.value(value: notificationApiService),
        Provider.value(value: danService),
        if (notificationService != null)
          Provider.value(value: notificationService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppStateManager.instance,
      builder: (context, child) {
        final state = AppStateManager.instance;

        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Mandal Capital',
          themeMode: state.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: AppColors.primaryMain,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryMain,
              primary: AppColors.primaryMain,
              secondary: AppColors.bgSecondary,
              onPrimary: AppColors.bgBase,
              surface: Colors.white,
              onSurface: AppColors.neutral200,
              background: Colors.white,
              onBackground: AppColors.neutral100,
              error: AppColors.redMain,
            ),
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: AppColors.neutral100),
              titleTextStyle: TextStyle(
                color: AppColors.neutral100,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            textTheme: TextTheme(
              displayLarge: AppTextStyles.display.copyWith(
                color: AppColors.neutral100,
              ),
              headlineLarge: AppTextStyles.h1.copyWith(
                color: AppColors.neutral100,
              ),
              headlineMedium: AppTextStyles.h2.copyWith(
                color: AppColors.neutral100,
              ),
              headlineSmall: AppTextStyles.h3.copyWith(
                color: AppColors.neutral100,
              ),
              bodyLarge: AppTextStyles.body1.copyWith(
                color: AppColors.neutral100,
              ),
              bodyMedium: AppTextStyles.body2.copyWith(
                color: AppColors.neutral200,
              ),
              labelLarge: AppTextStyles.paragraph1.copyWith(
                color: AppColors.neutral200,
              ),
              labelMedium: AppTextStyles.paragraph2.copyWith(
                color: AppColors.neutral200,
              ),
              labelSmall: AppTextStyles.caption.copyWith(
                color: AppColors.neutral300,
              ),
              titleLarge: AppTextStyles.h2.copyWith(
                color: AppColors.neutral100,
                fontWeight: FontWeight.bold,
              ),
            ),
            dividerTheme: const DividerThemeData(color: AppColors.bgTertiary),
            extensions: [
              ExtendedColors(
                primaryMain: AppColors.primaryMain,
                primary500: AppColors.primary500,
                primary400: AppColors.primary400,
                primary300: AppColors.primary300,
                primary200: AppColors.primary200,
                primary100: AppColors.primary100,
                footerColor: Color(0xCCF1F1F1),
                neutral100: AppColors.neutral100,
                neutral200: AppColors.neutral200,
                neutral300: AppColors.neutral300,
                neutral400: AppColors.neutral400,
                neutral500: AppColors.neutral500,
                bgBase: AppColors.bgBase,
                bgSecondary: AppColors.bgSecondary,
                bgTertiary: AppColors.bgTertiary,
                purple: AppColors.purpleMain,
                orange: AppColors.orangeMain,
                yellow: AppColors.yellowMain,
                red: AppColors.redMain,
                material: AppColors.materialLight,
              ),
            ],
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            primaryColor: AppColors.dpPrimaryMain,
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: AppColors.dpPrimaryMain,
              secondary: AppColors.dpBgSecondary,
              primary: AppColors.dpPrimaryMain,
              onPrimary: AppColors.dpBgBase,
              surface: AppColors.dpBgSecondary,
              onSurface: AppColors.dpNeutral200,
              background: AppColors.dpBgBase,
              onBackground: AppColors.dpNeutral100,
              error: AppColors.dpRedMain,
            ),
            scaffoldBackgroundColor: AppColors.dpBgBase,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.dpBgBase,
              elevation: 0,
              iconTheme: IconThemeData(color: AppColors.dpNeutral100),
              titleTextStyle: TextStyle(
                color: AppColors.dpNeutral100,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            textTheme: TextTheme(
              displayLarge: AppTextStyles.display.copyWith(
                color: AppColors.dpNeutral100,
              ),
              headlineLarge: AppTextStyles.h1.copyWith(
                color: AppColors.dpNeutral100,
              ),
              headlineMedium: AppTextStyles.h2.copyWith(
                color: AppColors.dpNeutral100,
              ),
              headlineSmall: AppTextStyles.h3.copyWith(
                color: AppColors.dpNeutral100,
              ),
              bodyLarge: AppTextStyles.body1.copyWith(
                color: AppColors.dpNeutral100,
              ),
              bodyMedium: AppTextStyles.body2.copyWith(
                color: AppColors.dpNeutral200,
              ),
              labelLarge: AppTextStyles.paragraph1.copyWith(
                color: AppColors.dpNeutral200,
              ),
              labelMedium: AppTextStyles.paragraph2.copyWith(
                color: AppColors.dpNeutral200,
              ),
              labelSmall: AppTextStyles.caption.copyWith(
                color: AppColors.dpNeutral300,
              ),
              titleLarge: AppTextStyles.h2.copyWith(
                color: AppColors.dpNeutral100,
                fontWeight: FontWeight.bold,
              ),
            ),
            dividerTheme: const DividerThemeData(color: AppColors.dpBgTertiary),
            extensions: [
              ExtendedColors(
                primaryMain: AppColors.dpPrimaryMain,
                primary500: AppColors.dpPrimary500,
                primary400: AppColors.dpPrimary400,
                primary300: AppColors.dpPrimary300,
                primary200: AppColors.dpPrimary200,
                primary100: AppColors.dpPrimary100,
                footerColor: Color(0x991E1E1E),
                neutral100: AppColors.dpNeutral100,
                neutral200: AppColors.dpNeutral200,
                neutral300: AppColors.dpNeutral300,
                neutral400: AppColors.dpNeutral400,
                neutral500: AppColors.dpNeutral500,
                bgBase: AppColors.dpBgBase,
                bgSecondary: AppColors.dpBgSecondary,
                bgTertiary: AppColors.dpBgTertiary,
                purple: AppColors.dpPurpleMain,
                orange: AppColors.dpOrangeMain,
                yellow: AppColors.dpYellowMain,
                red: AppColors.dpRedMain,
                material: AppColors.materialDark,
              ),
            ],
          ),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('mn')],
          locale: state.locale,
          home: const SplashScreen(),
          onGenerateRoute: (settings) {
            // Route map
            final routes = <String, WidgetBuilder>{
              '/login': (context) => const LoginScreen(),
              '/quick_login': (context) => const QuickLoginScreen(),
              '/main': (context) => const MainContainer(),
              '/home': (context) => const HomeScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/components': (context) => const ComponentsScreen(),
              '/theme_colors': (context) => const ThemeColorsScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/notifications': (context) => const NotificationScreen(),
              '/notification_detail': (context) =>
                  const NotificationDetailScreen(),
              '/my_info': (context) => const MyInfoScreen(),
              '/income_account': (context) => const IncomeAccountScreen(),
              '/add_income_account': (context) =>
                  const AddIncomeAccountScreen(),
              '/summary_report': (context) => const SummaryReportScreen(),
              '/connected_devices': (context) => const ConnectedDevicesScreen(),
              '/change_password_verify': (context) =>
                  const ChangePasswordVerifyScreen(),
              '/change_password_code': (context) =>
                  const ChangePasswordCodeScreen(),
              '/change_password_new': (context) =>
                  const ChangePasswordNewScreen(),
              '/income_account_detail': (context) =>
                  const IncomeAccountDetailScreen(),
              '/login_verification': (context) =>
                  const LoginVerificationScreen(),
              '/login_otp': (context) => const LoginOtpScreen(),
              '/new_device': (context) => const NewDeviceScreen(),
              '/biometric_enrollment': (context) =>
                  const BiometricEnrollmentScreen(),
              '/forgot_password': (context) => const ForgotPasswordScreen(),
              '/forgot_password_verification': (context) =>
                  const ForgotPasswordVerificationScreen(),
              '/forgot_password_otp': (context) =>
                  const ForgotPasswordOtpScreen(),
              '/forgot_password_new': (context) =>
                  const ForgotPasswordNewScreen(),
              '/register': (context) => const RegisterScreen(),
              '/pep_question': (context) => const PepQuestionScreen(),
              '/pep_definition': (context) => const PepDefinitionScreen(),
              '/securities_agreement': (context) =>
                  const SecuritiesAgreementScreen(),
              '/document_verification': (context) =>
                  const DocumentVerificationScreen(),
              '/camera_overlay': (context) => const CameraOverlayScreen(),
              '/onboarding_success': (context) =>
                  const OnboardingSuccessScreen(),
              '/dan_verification': (context) => const DanVerificationScreen(),
              '/register_otp': (context) => const RegisterOtpScreen(),
              '/register_password': (context) => const RegisterPasswordScreen(),
              '/register_bank_selection': (context) =>
                  const RegisterBankSelectionScreen(),
              '/register_income_account': (context) =>
                  const RegisterIncomeAccountScreen(),
              '/register_success': (context) => const RegisterSuccessScreen(),
              '/payment_qpay': (context) => const PaymentQpayScreen(),
              '/payment_result': (context) => const PaymentResultScreen(),
              '/bond_detail': (context) => const BondDetailScreen(),
              '/bond_main': (context) => const BondMainScreen(),
              '/bond_buy': (context) => const BondBuyScreen(),
              '/bond_confirmation': (context) => const BondConfirmationScreen(),
              '/pledge_bond_select': (context) =>
                  const PledgeBondSelectScreen(),
              '/pledge_bond_order': (context) => const PledgeBondOrderScreen(),
              '/pledge_bond_confirmation': (context) =>
                  const PledgeBondConfirmationScreen(),
              '/bond_success': (context) => const BondSuccessScreen(),
              '/bond_sell': (context) => const BondSellScreen(),
              '/bond_sell_confirmation': (context) =>
                  const BondSellConfirmationScreen(),
              '/bond_sell_success': (context) => const BondSellSuccessScreen(),
              '/order_detail': (context) => const OrderDetailScreen(),
              '/stock_detail': (context) => const StockDetailScreen(),
              '/stock_trading': (context) => const StockTradingScreen(),
              '/stock_success': (context) => const StockSuccessScreen(),
              '/stock_confirmation': (context) =>
                  const StockConfirmationScreen(),
              '/currency_detail': (context) => const CurrencyDetailScreen(),
              '/bond_portfolio': (context) => const BondPortfolioScreen(),
              '/stock_portfolio': (context) => const StockPortfolioScreen(),
              '/income_method': (context) => const IncomeMethodScreen(),
              '/income_amount': (context) => const IncomeAmountScreen(),
              '/income_success': (context) => const IncomeSuccessScreen(),
              '/withdraw_method': (context) => const WithdrawMethodScreen(),
              '/withdraw_amount': (context) => const WithdrawAmountScreen(),
              '/withdraw_success': (context) => const WithdrawSuccessScreen(),
              '/transaction_history': (context) =>
                  const TransactionHistoryScreen(),
              '/release_locked': (context) => const ReleaseLockedAmountScreen(),
              '/watchlist_detail': (context) => const WatchlistDetailScreen(),
              '/add_watchlist': (context) => const AddWatchlistScreen(),
              '/webview': (context) => const WebViewScreen(),
            };

            final routeName = settings.name;
            final builder = routes[routeName];

            if (builder == null) return null;

            // Public route → шууд нээх
            if (_publicRoutes.contains(routeName)) {
              return MaterialPageRoute(builder: builder, settings: settings);
            }

            // Protected route → auth шалгах
            final authService = Provider.of<AuthService>(
              navigatorKey.currentContext!,
              listen: false,
            );

            if (authService.isAuthenticated) {
              return MaterialPageRoute(builder: builder, settings: settings);
            }

            // Нэвтрээгүй → login руу шилжүүлэх
            return MaterialPageRoute(
              builder: (context) => const LoginScreen(),
              settings: const RouteSettings(name: '/login'),
            );
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
