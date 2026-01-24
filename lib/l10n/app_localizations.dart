import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_mn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('mn'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Antigravity'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @portfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolio;

  /// No description provided for @bonds.
  ///
  /// In en, this message translates to:
  /// **'Bonds'**
  String get bonds;

  /// No description provided for @stocks.
  ///
  /// In en, this message translates to:
  /// **'Stocks'**
  String get stocks;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @myAssets.
  ///
  /// In en, this message translates to:
  /// **'My Assets'**
  String get myAssets;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @mandalSavings.
  ///
  /// In en, this message translates to:
  /// **'MANDAL SAVINGS'**
  String get mandalSavings;

  /// No description provided for @mySavings.
  ///
  /// In en, this message translates to:
  /// **'My Savings'**
  String get mySavings;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @searchByName.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get searchByName;

  /// No description provided for @dividendPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Dividend Portfolio'**
  String get dividendPortfolio;

  /// No description provided for @recommendedStocks.
  ///
  /// In en, this message translates to:
  /// **'Recommended Stocks'**
  String get recommendedStocks;

  /// No description provided for @viewPortfolio.
  ///
  /// In en, this message translates to:
  /// **'View Portfolio'**
  String get viewPortfolio;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @ipo.
  ///
  /// In en, this message translates to:
  /// **'IPO'**
  String get ipo;

  /// No description provided for @gainers.
  ///
  /// In en, this message translates to:
  /// **'Gainers'**
  String get gainers;

  /// No description provided for @losers.
  ///
  /// In en, this message translates to:
  /// **'Losers'**
  String get losers;

  /// No description provided for @market.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get market;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @lastPrice24h.
  ///
  /// In en, this message translates to:
  /// **'Last Price (24h)'**
  String get lastPrice24h;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// No description provided for @activeOrders.
  ///
  /// In en, this message translates to:
  /// **'Active Orders'**
  String get activeOrders;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get orderHistory;

  /// No description provided for @executionQuantity.
  ///
  /// In en, this message translates to:
  /// **'Execution/Qty'**
  String get executionQuantity;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPrice;

  /// No description provided for @sellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Selling Price'**
  String get sellingPrice;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get open;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'CLOSED'**
  String get closed;

  /// No description provided for @foreign.
  ///
  /// In en, this message translates to:
  /// **'FOREIGN'**
  String get foreign;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'BUY'**
  String get buy;

  /// No description provided for @sell.
  ///
  /// In en, this message translates to:
  /// **'SELL'**
  String get sell;

  /// No description provided for @bond.
  ///
  /// In en, this message translates to:
  /// **'BOND'**
  String get bond;

  /// No description provided for @orderUpdated.
  ///
  /// In en, this message translates to:
  /// **'Order Updated'**
  String get orderUpdated;

  /// No description provided for @totalAssets.
  ///
  /// In en, this message translates to:
  /// **'Total Assets'**
  String get totalAssets;

  /// No description provided for @last1Month.
  ///
  /// In en, this message translates to:
  /// **'Last 1 month'**
  String get last1Month;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @assetBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Asset Breakdown'**
  String get assetBreakdown;

  /// No description provided for @tugrik.
  ///
  /// In en, this message translates to:
  /// **'Tugrik'**
  String get tugrik;

  /// No description provided for @dollar.
  ///
  /// In en, this message translates to:
  /// **'Dollar'**
  String get dollar;

  /// No description provided for @orderCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Orders'**
  String orderCount(String count);

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailHint;

  /// No description provided for @phonePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Phone number entry section'**
  String get phonePlaceholder;

  /// No description provided for @forgotPasswordBtn.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordBtn;

  /// No description provided for @noCompletedSavings.
  ///
  /// In en, this message translates to:
  /// **'No completed savings found.'**
  String get noCompletedSavings;

  /// No description provided for @tenureLabel.
  ///
  /// In en, this message translates to:
  /// **'Tenure'**
  String get tenureLabel;

  /// No description provided for @interestRate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get interestRate;

  /// No description provided for @endDateLabel.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDateLabel;

  /// No description provided for @uiComponentsShowcase.
  ///
  /// In en, this message translates to:
  /// **'UI Components Showcase'**
  String get uiComponentsShowcase;

  /// No description provided for @uiComponentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View all available components'**
  String get uiComponentsSubtitle;

  /// No description provided for @themeColorsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover the design system palette'**
  String get themeColorsSubtitle;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Enable Darkmode'**
  String get darkMode;

  /// No description provided for @myInfo.
  ///
  /// In en, this message translates to:
  /// **'My Information'**
  String get myInfo;

  /// No description provided for @myInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Email, Phone Number, Address'**
  String get myInfoSubtitle;

  /// No description provided for @incomeAccount.
  ///
  /// In en, this message translates to:
  /// **'Income Account'**
  String get incomeAccount;

  /// No description provided for @incomeAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Golomt Bank - MN650039008000110...'**
  String get incomeAccountSubtitle;

  /// No description provided for @summaryReport.
  ///
  /// In en, this message translates to:
  /// **'Summary Report'**
  String get summaryReport;

  /// No description provided for @summaryReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly and annual reports'**
  String get summaryReportSubtitle;

  /// No description provided for @childAccount.
  ///
  /// In en, this message translates to:
  /// **'Child Account'**
  String get childAccount;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get createNewAccount;

  /// No description provided for @createNewAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invest in your future'**
  String get createNewAccountSubtitle;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @biometric.
  ///
  /// In en, this message translates to:
  /// **'Biometric'**
  String get biometric;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'INACTIVE'**
  String get inactive;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @lastChanged.
  ///
  /// In en, this message translates to:
  /// **'Changed on 2025.10.20'**
  String get lastChanged;

  /// No description provided for @connectedDevices.
  ///
  /// In en, this message translates to:
  /// **'Connected Devices'**
  String get connectedDevices;

  /// No description provided for @devicesCount.
  ///
  /// In en, this message translates to:
  /// **'2 devices'**
  String get devicesCount;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @allNotifications.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allNotifications;

  /// No description provided for @trading.
  ///
  /// In en, this message translates to:
  /// **'Trading'**
  String get trading;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// No description provided for @markAllReadTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllReadTitle;

  /// No description provided for @markAllReadDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to mark all notifications as read and remove the unread indicators?'**
  String get markAllReadDesc;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, mark as read'**
  String get confirm;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @surname.
  ///
  /// In en, this message translates to:
  /// **'Surname'**
  String get surname;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @regNo.
  ///
  /// In en, this message translates to:
  /// **'Registration No'**
  String get regNo;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @otherAccounts.
  ///
  /// In en, this message translates to:
  /// **'Other Accounts'**
  String get otherAccounts;

  /// No description provided for @incomeAccBenefitPrompt.
  ///
  /// In en, this message translates to:
  /// **'Profit from your trades will be transferred to this account.'**
  String get incomeAccBenefitPrompt;

  /// No description provided for @addIncomeAccPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please enter an income account'**
  String get addIncomeAccPrompt;

  /// No description provided for @iban.
  ///
  /// In en, this message translates to:
  /// **'IBAN Number'**
  String get iban;

  /// No description provided for @bank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bank;

  /// No description provided for @receiver.
  ///
  /// In en, this message translates to:
  /// **'Receiver'**
  String get receiver;

  /// No description provided for @receiverHint.
  ///
  /// In en, this message translates to:
  /// **'Write in Surname Name order'**
  String get receiverHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @growth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last 1 month'**
  String get lastMonth;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @incomeExpense.
  ///
  /// In en, this message translates to:
  /// **'Income/Expense'**
  String get incomeExpense;

  /// No description provided for @incomeSalary.
  ///
  /// In en, this message translates to:
  /// **'Income/Salary'**
  String get incomeSalary;

  /// No description provided for @stockProfit.
  ///
  /// In en, this message translates to:
  /// **'Stock Profit'**
  String get stockProfit;

  /// No description provided for @interestIncome.
  ///
  /// In en, this message translates to:
  /// **'Interest Income'**
  String get interestIncome;

  /// No description provided for @bondPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Bond Principal Payment'**
  String get bondPrincipal;

  /// No description provided for @dividendProfit.
  ///
  /// In en, this message translates to:
  /// **'Dividend Profit'**
  String get dividendProfit;

  /// No description provided for @downloadReport.
  ///
  /// In en, this message translates to:
  /// **'Download Report'**
  String get downloadReport;

  /// No description provided for @oneDay.
  ///
  /// In en, this message translates to:
  /// **'1D'**
  String get oneDay;

  /// No description provided for @threeDays.
  ///
  /// In en, this message translates to:
  /// **'3C'**
  String get threeDays;

  /// No description provided for @sixDays.
  ///
  /// In en, this message translates to:
  /// **'6C'**
  String get sixDays;

  /// No description provided for @oneYear.
  ///
  /// In en, this message translates to:
  /// **'1Ж'**
  String get oneYear;

  /// No description provided for @selectedPeriod.
  ///
  /// In en, this message translates to:
  /// **'Selected Period'**
  String get selectedPeriod;

  /// No description provided for @connectedDevicesDesc.
  ///
  /// In en, this message translates to:
  /// **'List of devices connected to your Mandal Capital app. Please remove any unrecognized devices.'**
  String get connectedDevicesDesc;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get active;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @ipAddress.
  ///
  /// In en, this message translates to:
  /// **'IP Address'**
  String get ipAddress;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout from App'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out from Mandal Capital app?'**
  String get logoutConfirmDesc;

  /// No description provided for @yesLogout.
  ///
  /// In en, this message translates to:
  /// **'Yes, Logout'**
  String get yesLogout;

  /// No description provided for @selectVerifyChannel.
  ///
  /// In en, this message translates to:
  /// **'Select verification channel'**
  String get selectVerifyChannel;

  /// No description provided for @verifyChannelPrompt.
  ///
  /// In en, this message translates to:
  /// **'A 4-digit code will be sent to your selected phone number or email address.'**
  String get verifyChannelPrompt;

  /// No description provided for @sms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get sms;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @enterCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter 4-digit code'**
  String get enterCodeTitle;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'A code was sent to your {channel} {value}.'**
  String codeSentTo(Object channel, Object value);

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @noCodeReceived.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive a code?'**
  String get noCodeReceived;

  /// No description provided for @createNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create new password'**
  String get createNewPassword;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @repeatPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat Password'**
  String get repeatPasswordHint;

  /// No description provided for @atLeast8Chars.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get atLeast8Chars;

  /// No description provided for @uppercaseLetter.
  ///
  /// In en, this message translates to:
  /// **'Uppercase (A-Z)'**
  String get uppercaseLetter;

  /// No description provided for @lowercaseLetter.
  ///
  /// In en, this message translates to:
  /// **'Lowercase (a-z)'**
  String get lowercaseLetter;

  /// No description provided for @numberDigit.
  ///
  /// In en, this message translates to:
  /// **'Number (0-9)'**
  String get numberDigit;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @incomeAccountDetail.
  ///
  /// In en, this message translates to:
  /// **'Income Account Detail'**
  String get incomeAccountDetail;

  /// No description provided for @incomeAccountDetailDesc.
  ///
  /// In en, this message translates to:
  /// **'Profits from your trades will be transferred to this account.'**
  String get incomeAccountDetailDesc;

  /// No description provided for @ibanNumber.
  ///
  /// In en, this message translates to:
  /// **'IBAN Number'**
  String get ibanNumber;

  /// No description provided for @accountChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Income account changed successfully.'**
  String get accountChangedSuccess;

  /// No description provided for @changeAccount.
  ///
  /// In en, this message translates to:
  /// **'Change Account'**
  String get changeAccount;

  /// No description provided for @setAsDefaultAccount.
  ///
  /// In en, this message translates to:
  /// **'Set as receiving account'**
  String get setAsDefaultAccount;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s decision, tomorrow\'s reward'**
  String get loginSubtitle;

  /// No description provided for @newToApp.
  ///
  /// In en, this message translates to:
  /// **'New user?'**
  String get newToApp;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered information'**
  String get forgotPasswordSubtitle;

  /// No description provided for @registrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Registration Number'**
  String get registrationNumber;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your personal information'**
  String get registerSubtitle;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @enterIncomeAccount.
  ///
  /// In en, this message translates to:
  /// **'Enter income account'**
  String get enterIncomeAccount;

  /// No description provided for @enterIncomeAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Profits from your trades will be transferred to this account'**
  String get enterIncomeAccountSubtitle;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bankName;

  /// No description provided for @recipientName.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get recipientName;

  /// No description provided for @lastNameOrFirstNameNote.
  ///
  /// In en, this message translates to:
  /// **'Write in last name, first name order'**
  String get lastNameOrFirstNameNote;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration Successful'**
  String get registrationSuccess;

  /// No description provided for @registrationSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your goals, our experience - we are confident that it will be full of trust, rewards, and opportunities.'**
  String get registrationSuccessMessage;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @selectYourBank.
  ///
  /// In en, this message translates to:
  /// **'Select your securities account'**
  String get selectYourBank;

  /// No description provided for @selectBankToContinue.
  ///
  /// In en, this message translates to:
  /// **'Check payment'**
  String get selectBankToContinue;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'mn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'mn':
      return AppLocalizationsMn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
