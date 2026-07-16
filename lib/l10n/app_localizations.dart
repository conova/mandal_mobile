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

  /// No description provided for @useAnotherAccount.
  ///
  /// In en, this message translates to:
  /// **'Use another account'**
  String get useAnotherAccount;

  /// No description provided for @loginErrorPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number or password is incorrect.'**
  String get loginErrorPhone;

  /// No description provided for @loginErrorEmail.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get loginErrorEmail;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get connectionError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @attemptsRemaining.
  ///
  /// In en, this message translates to:
  /// **'Incorrect phone number or password. \n{count} attempt(s) remaining.'**
  String attemptsRemaining(Object count);

  /// No description provided for @attemptsRemainingEmail.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password. \n{count} attempt(s) remaining.'**
  String attemptsRemainingEmail(Object count);

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get validationEmailRequired;

  /// No description provided for @validationInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid or incomplete format'**
  String get validationInvalidFormat;

  /// No description provided for @validationThisField.
  ///
  /// In en, this message translates to:
  /// **'This field'**
  String get validationThisField;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'{field} is empty'**
  String validationRequired(Object field);

  /// No description provided for @validationRegisterRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter registration number'**
  String get validationRegisterRequired;

  /// No description provided for @validationRegisterInvalid.
  ///
  /// In en, this message translates to:
  /// **'Registration number is invalid'**
  String get validationRegisterInvalid;

  /// No description provided for @validationPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get validationPhoneRequired;

  /// No description provided for @validationEnterField.
  ///
  /// In en, this message translates to:
  /// **'Enter {field}'**
  String validationEnterField(Object field);

  /// No description provided for @validationLettersOnly.
  ///
  /// In en, this message translates to:
  /// **'{field} must contain only letters'**
  String validationLettersOnly(Object field);

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

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Enable Lightmode'**
  String get lightMode;

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

  /// No description provided for @passwordChangedOn.
  ///
  /// In en, this message translates to:
  /// **'Changed on {date}'**
  String passwordChangedOn(Object date);

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

  /// No description provided for @deviceCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} devices'**
  String deviceCountLabel(Object count);

  /// No description provided for @biometricFaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Face ID?'**
  String get biometricFaceTitle;

  /// No description provided for @biometricFingerprintTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Fingerprint?'**
  String get biometricFingerprintTitle;

  /// No description provided for @biometricEnrollDesc.
  ///
  /// In en, this message translates to:
  /// **'This lets you log in quickly using biometrics next time.'**
  String get biometricEnrollDesc;

  /// No description provided for @biometricEnrollConfirm.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get biometricEnrollConfirm;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

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

  /// Section title on notification detail screen showing the data payload
  ///
  /// In en, this message translates to:
  /// **'Related details'**
  String get notificationRelatedInfo;

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
  /// **'A 6-digit code will be sent to your selected phone number or email address.'**
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
  /// **'Enter 6-digit code'**
  String get enterCodeTitle;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'A code was sent to your {value}.'**
  String codeSentTo(Object value);

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

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @lockedAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Locked Amount'**
  String get lockedAmountLabel;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @receivableAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Receivable Amount'**
  String get receivableAmountLabel;

  /// No description provided for @sellPriceDesc.
  ///
  /// In en, this message translates to:
  /// **'The lower the selling price, the more likely your order will be executed quickly.'**
  String get sellPriceDesc;

  /// No description provided for @swipeUpToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Swipe up to confirm'**
  String get swipeUpToConfirm;

  /// No description provided for @orderPlacedSuccess.
  ///
  /// In en, this message translates to:
  /// **'ORDER\nPLACED'**
  String get orderPlacedSuccess;

  /// No description provided for @orderPlacedDesc.
  ///
  /// In en, this message translates to:
  /// **'We will notify you when the order is fulfilled and interest starts accruing.'**
  String get orderPlacedDesc;

  /// No description provided for @viewOrders.
  ///
  /// In en, this message translates to:
  /// **'View Orders'**
  String get viewOrders;

  /// No description provided for @sellOrderSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Please note that only the best selling price will be visible to other investors.'**
  String get sellOrderSuccessDesc;

  /// No description provided for @commissionLabel.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get commissionLabel;

  /// No description provided for @ownedAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Owned Amount'**
  String get ownedAmountLabel;

  /// No description provided for @pledgeBondDesc.
  ///
  /// In en, this message translates to:
  /// **'Solve your financial needs without selling your bonds.'**
  String get pledgeBondDesc;

  /// No description provided for @pledge.
  ///
  /// In en, this message translates to:
  /// **'Pledge'**
  String get pledge;

  /// No description provided for @newBond.
  ///
  /// In en, this message translates to:
  /// **'New Bond'**
  String get newBond;

  /// No description provided for @newBondDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn steady returns with our premium bond offerings. Start investing today.'**
  String get newBondDesc;

  /// No description provided for @watchlist.
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get watchlist;

  /// No description provided for @recommendationTitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t know which bond to choose?'**
  String get recommendationTitle;

  /// No description provided for @recommendationDesc.
  ///
  /// In en, this message translates to:
  /// **'We recommend the best bonds based on your interests.'**
  String get recommendationDesc;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading'**
  String get uploading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @addEmail.
  ///
  /// In en, this message translates to:
  /// **'Add email'**
  String get addEmail;

  /// No description provided for @annualYield.
  ///
  /// In en, this message translates to:
  /// **'Annual yield'**
  String get annualYield;

  /// No description provided for @nextInterestPayDate.
  ///
  /// In en, this message translates to:
  /// **'Next interest payment date'**
  String get nextInterestPayDate;

  /// No description provided for @bondMaturityDate.
  ///
  /// In en, this message translates to:
  /// **'Maturity date'**
  String get bondMaturityDate;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String daysCount(Object days);

  /// No description provided for @tradePlannedDate.
  ///
  /// In en, this message translates to:
  /// **'Planned trade execution date'**
  String get tradePlannedDate;

  /// No description provided for @buyRate.
  ///
  /// In en, this message translates to:
  /// **'Buy price'**
  String get buyRate;

  /// No description provided for @selectPledgeBond.
  ///
  /// In en, this message translates to:
  /// **'Select bond to pledge'**
  String get selectPledgeBond;

  /// No description provided for @pledgeBondSelectDesc.
  ///
  /// In en, this message translates to:
  /// **'Pledge your bond and pay +6.0% interest when releasing it. Just like a deposit-backed bank loan.'**
  String get pledgeBondSelectDesc;

  /// No description provided for @pledgeQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Pledge quantity'**
  String get pledgeQuantityLabel;

  /// No description provided for @availablePieces.
  ///
  /// In en, this message translates to:
  /// **'Available: {count} pcs'**
  String availablePieces(Object count);

  /// No description provided for @receiveAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Receive amount'**
  String get receiveAmountLabel;

  /// No description provided for @sorryTitle.
  ///
  /// In en, this message translates to:
  /// **'Sorry'**
  String get sorryTitle;

  /// No description provided for @noPledgeBondDesc.
  ///
  /// In en, this message translates to:
  /// **'You currently have no bonds available to pledge.'**
  String get noPledgeBondDesc;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'REQUEST SENT'**
  String get requestSent;

  /// No description provided for @requestSentDesc.
  ///
  /// In en, this message translates to:
  /// **'Our broker will contact you shortly at {phone}.'**
  String requestSentDesc(Object phone);

  /// No description provided for @closedBondInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Closed bond'**
  String get closedBondInfoTitle;

  /// No description provided for @closedBondInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'A bond traded over the counter with a 10% interest income tax, similar to a savings deposit.'**
  String get closedBondInfoDesc;

  /// No description provided for @openBondInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Open bond'**
  String get openBondInfoTitle;

  /// No description provided for @openBondInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'A bond openly traded on the exchange that can be bought or sold at any time.'**
  String get openBondInfoDesc;

  /// No description provided for @foreignBondInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Foreign bond'**
  String get foreignBondInfoTitle;

  /// No description provided for @foreignBondInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'A bond denominated in foreign currency and traded on international markets.'**
  String get foreignBondInfoDesc;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @stockRecommendationTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended stocks'**
  String get stockRecommendationTitle;

  /// No description provided for @stockRecommendationDesc.
  ///
  /// In en, this message translates to:
  /// **'We recommend the stocks with the highest trading value.'**
  String get stockRecommendationDesc;

  /// No description provided for @sellBond.
  ///
  /// In en, this message translates to:
  /// **'Sell Bond'**
  String get sellBond;

  /// No description provided for @mandalBond.
  ///
  /// In en, this message translates to:
  /// **'MANDAL BOND'**
  String get mandalBond;

  /// No description provided for @primaryMarket.
  ///
  /// In en, this message translates to:
  /// **'Primary Market'**
  String get primaryMarket;

  /// No description provided for @secondaryMarket.
  ///
  /// In en, this message translates to:
  /// **'Secondary Market'**
  String get secondaryMarket;

  /// No description provided for @myBond.
  ///
  /// In en, this message translates to:
  /// **'My Bond'**
  String get myBond;

  /// No description provided for @pledgeBond.
  ///
  /// In en, this message translates to:
  /// **'Pledge Bond'**
  String get pledgeBond;

  /// No description provided for @bondCollectionTarget.
  ///
  /// In en, this message translates to:
  /// **'Collection Target'**
  String get bondCollectionTarget;

  /// No description provided for @annualInterest.
  ///
  /// In en, this message translates to:
  /// **'Annual Interest'**
  String get annualInterest;

  /// No description provided for @paymentFrequency.
  ///
  /// In en, this message translates to:
  /// **'Payment Frequency'**
  String get paymentFrequency;

  /// No description provided for @availableCash.
  ///
  /// In en, this message translates to:
  /// **'Available Cash'**
  String get availableCash;

  /// No description provided for @buyQuantity.
  ///
  /// In en, this message translates to:
  /// **'Buy Quantity'**
  String get buyQuantity;

  /// No description provided for @availableQuantity.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availableQuantity;

  /// No description provided for @totalPayment.
  ///
  /// In en, this message translates to:
  /// **'Total Payment'**
  String get totalPayment;

  /// No description provided for @totalReturn.
  ///
  /// In en, this message translates to:
  /// **'Total Return'**
  String get totalReturn;

  /// No description provided for @lockedAmount.
  ///
  /// In en, this message translates to:
  /// **'Locked Amount'**
  String get lockedAmount;

  /// No description provided for @release.
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get release;

  /// No description provided for @orderRegistered.
  ///
  /// In en, this message translates to:
  /// **'ORDER REGISTERED'**
  String get orderRegistered;

  /// No description provided for @sellPrice.
  ///
  /// In en, this message translates to:
  /// **'Sell Price'**
  String get sellPrice;

  /// No description provided for @executionProbability.
  ///
  /// In en, this message translates to:
  /// **'Execution Probability'**
  String get executionProbability;

  /// No description provided for @orderBoard.
  ///
  /// In en, this message translates to:
  /// **'Order Board'**
  String get orderBoard;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @bondClosingDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Closing Date'**
  String get bondClosingDateLabel;

  /// No description provided for @viewBondPresentation.
  ///
  /// In en, this message translates to:
  /// **'View Presentation'**
  String get viewBondPresentation;

  /// No description provided for @buyBond.
  ///
  /// In en, this message translates to:
  /// **'Buy Bond'**
  String get buyBond;

  /// No description provided for @availableAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Available Amount'**
  String get availableAmountLabel;

  /// No description provided for @costLabel.
  ///
  /// In en, this message translates to:
  /// **'Interest Rate'**
  String get costLabel;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @tradeAmount.
  ///
  /// In en, this message translates to:
  /// **'Trade Amount'**
  String get tradeAmount;

  /// No description provided for @orderTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get orderTypeLabel;

  /// No description provided for @orderStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get orderStatusLabel;

  /// No description provided for @yieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Yield'**
  String get yieldLabel;

  /// No description provided for @settlementDate.
  ///
  /// In en, this message translates to:
  /// **'Settlement Date'**
  String get settlementDate;

  /// No description provided for @orderDate.
  ///
  /// In en, this message translates to:
  /// **'Order Date'**
  String get orderDate;

  /// No description provided for @executionHistory.
  ///
  /// In en, this message translates to:
  /// **'Execution History'**
  String get executionHistory;

  /// No description provided for @executedQuantity.
  ///
  /// In en, this message translates to:
  /// **'Executed Quantity'**
  String get executedQuantity;

  /// No description provided for @partiallyFilled.
  ///
  /// In en, this message translates to:
  /// **'Partially Filled'**
  String get partiallyFilled;

  /// No description provided for @limitPrice.
  ///
  /// In en, this message translates to:
  /// **'Limit Price'**
  String get limitPrice;

  /// No description provided for @generalInfo.
  ///
  /// In en, this message translates to:
  /// **'General Information'**
  String get generalInfo;

  /// No description provided for @marketCap.
  ///
  /// In en, this message translates to:
  /// **'Market Cap'**
  String get marketCap;

  /// No description provided for @avgVolume.
  ///
  /// In en, this message translates to:
  /// **'Avg Volume'**
  String get avgVolume;

  /// No description provided for @dividendYield.
  ///
  /// In en, this message translates to:
  /// **'Dividend Yield'**
  String get dividendYield;

  /// No description provided for @dailyVolume.
  ///
  /// In en, this message translates to:
  /// **'Daily Volume'**
  String get dailyVolume;

  /// No description provided for @pastDividends.
  ///
  /// In en, this message translates to:
  /// **'Past Dividends'**
  String get pastDividends;

  /// No description provided for @trade.
  ///
  /// In en, this message translates to:
  /// **'Trade'**
  String get trade;

  /// No description provided for @billion.
  ///
  /// In en, this message translates to:
  /// **'billion'**
  String get billion;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @stockTrading.
  ///
  /// In en, this message translates to:
  /// **'Stock Trading'**
  String get stockTrading;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @buyTab.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buyTab;

  /// No description provided for @sellTab.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sellTab;

  /// No description provided for @totalPaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Payment'**
  String get totalPaymentLabel;

  /// No description provided for @totalReceivableLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Receivable'**
  String get totalReceivableLabel;

  /// No description provided for @orderBoardTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Board'**
  String get orderBoardTitle;

  /// No description provided for @buyAmount.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buyAmount;

  /// No description provided for @sellAmount.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sellAmount;

  /// No description provided for @releaseLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Release Locked Amount'**
  String get releaseLockedTitle;

  /// No description provided for @releaseLockedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can increase your cash by canceling active orders (locked amount).'**
  String get releaseLockedSubtitle;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @acceptTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the terms of the agreement'**
  String get acceptTerms;

  /// No description provided for @agree.
  ///
  /// In en, this message translates to:
  /// **'Agree'**
  String get agree;

  /// No description provided for @agreed.
  ///
  /// In en, this message translates to:
  /// **'Agreed'**
  String get agreed;

  /// No description provided for @securitiesAgreementContent.
  ///
  /// In en, this message translates to:
  /// **'This agreement is entered into between \"Mongolian Stock Exchange\" JSC /hereinafter referred to as the Exchange/, represented by ................................................, and \"................................................\" JSC /hereinafter referred to as the Issuer, collectively the Parties/, represented by ........................................... on the following terms and conditions.\n\n1.1 This agreement defines the rights, duties, and responsibilities of the parties in relation to the Exchange\'s actions of registering the Issuer and its securities, organizing the trading of securities in accordance with the relevant rules and regulations, and the Issuer\'s obligation to be registered with the Exchange in accordance with relevant procedures and pay service fees.'**
  String get securitiesAgreementContent;

  /// No description provided for @khurSystem.
  ///
  /// In en, this message translates to:
  /// **'KHUR system'**
  String get khurSystem;

  /// No description provided for @registrationProgress.
  ///
  /// In en, this message translates to:
  /// **'Registration progress: {percent}%'**
  String registrationProgress(String percent);

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @preparationWork.
  ///
  /// In en, this message translates to:
  /// **'Preparation work'**
  String get preparationWork;

  /// No description provided for @preparationDesc.
  ///
  /// In en, this message translates to:
  /// **'You will be ready to trade after completing the following steps.'**
  String get preparationDesc;

  /// No description provided for @danSystem.
  ///
  /// In en, this message translates to:
  /// **'DAN identification system'**
  String get danSystem;

  /// No description provided for @danSystemDesc.
  ///
  /// In en, this message translates to:
  /// **'Information verification'**
  String get danSystemDesc;

  /// No description provided for @addressInfo.
  ///
  /// In en, this message translates to:
  /// **'Address information'**
  String get addressInfo;

  /// No description provided for @addressInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Your residential address'**
  String get addressInfoDesc;

  /// No description provided for @securitiesAgreement.
  ///
  /// In en, this message translates to:
  /// **'Securities agreement'**
  String get securitiesAgreement;

  /// No description provided for @securitiesAgreementDesc.
  ///
  /// In en, this message translates to:
  /// **'Read and agree to terms'**
  String get securitiesAgreementDesc;

  /// No description provided for @document.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get document;

  /// No description provided for @documentDesc.
  ///
  /// In en, this message translates to:
  /// **'ID card, selfie photo'**
  String get documentDesc;

  /// No description provided for @idFront.
  ///
  /// In en, this message translates to:
  /// **'ID Card - Front'**
  String get idFront;

  /// No description provided for @idBack.
  ///
  /// In en, this message translates to:
  /// **'ID Card - Back'**
  String get idBack;

  /// No description provided for @selfiePhoto.
  ///
  /// In en, this message translates to:
  /// **'Selfie Photo'**
  String get selfiePhoto;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @editPhoto.
  ///
  /// In en, this message translates to:
  /// **'Edit Photo'**
  String get editPhoto;

  /// No description provided for @photoRequirements.
  ///
  /// In en, this message translates to:
  /// **'Photo Requirements'**
  String get photoRequirements;

  /// No description provided for @reqCorner.
  ///
  /// In en, this message translates to:
  /// **'All 4 corners of the ID must be visible'**
  String get reqCorner;

  /// No description provided for @reqValid.
  ///
  /// In en, this message translates to:
  /// **'Use a valid document'**
  String get reqValid;

  /// No description provided for @reqClear.
  ///
  /// In en, this message translates to:
  /// **'No blur or glare'**
  String get reqClear;

  /// No description provided for @reqReadable.
  ///
  /// In en, this message translates to:
  /// **'Information must be clearly readable'**
  String get reqReadable;

  /// No description provided for @sendPhoto.
  ///
  /// In en, this message translates to:
  /// **'Send Photo'**
  String get sendPhoto;

  /// No description provided for @cameraInstructionId.
  ///
  /// In en, this message translates to:
  /// **'Fit the document within the frame'**
  String get cameraInstructionId;

  /// No description provided for @cameraInstructionSelfie.
  ///
  /// In en, this message translates to:
  /// **'Fit your face within the frame'**
  String get cameraInstructionSelfie;

  /// No description provided for @readyToTrade.
  ///
  /// In en, this message translates to:
  /// **'Ready to Trade'**
  String get readyToTrade;

  /// No description provided for @readyToTradeDesc.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start your investment journey together!'**
  String get readyToTradeDesc;

  /// No description provided for @pepQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you, a family member, or a close associate a Politically Exposed Person (PEP)?'**
  String get pepQuestion;

  /// No description provided for @pepDefinition.
  ///
  /// In en, this message translates to:
  /// **'Who is a PEP?'**
  String get pepDefinition;

  /// No description provided for @pepDefinitionFull.
  ///
  /// In en, this message translates to:
  /// **'A Politically Exposed Person (PEP) is defined as an individual who is or has been entrusted with a prominent public function. This includes:\n\nPresident of Mongolia, Members of Parliament, Prime Minister, Cabinet Members, Members of the Constitutional Court, Chief Justice and Judges of the Supreme Court, Prosecutor General, Heads of organizations directly accountable to Parliament, Governors of Aimags and the Capital city, Chairmen of Citizens\' Representative Khurals of Aimags and the Capital city, State Secretaries of Ministries, Heads of government agencies, and Heads/Directors of state-owned companies and international organizations.'**
  String get pepDefinitionFull;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @newDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'New device'**
  String get newDeviceTitle;

  /// No description provided for @newDeviceDesc.
  ///
  /// In en, this message translates to:
  /// **'You are logging in from this device for the first time. To keep your account secure, please complete verification to continue.'**
  String get newDeviceDesc;

  /// No description provided for @danVerificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Verify your personal information using the system.'**
  String get danVerificationDesc;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @myStocks.
  ///
  /// In en, this message translates to:
  /// **'My Stocks'**
  String get myStocks;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @totalProfit.
  ///
  /// In en, this message translates to:
  /// **'Total Profit'**
  String get totalProfit;

  /// No description provided for @realizedProfit.
  ///
  /// In en, this message translates to:
  /// **'Realized Profit'**
  String get realizedProfit;

  /// No description provided for @unrealizedProfit.
  ///
  /// In en, this message translates to:
  /// **'Unrealized Profit'**
  String get unrealizedProfit;

  /// No description provided for @futureReturn.
  ///
  /// In en, this message translates to:
  /// **'Future Return'**
  String get futureReturn;

  /// No description provided for @totalReturnReceived.
  ///
  /// In en, this message translates to:
  /// **'Total Return Received'**
  String get totalReturnReceived;

  /// No description provided for @bondName.
  ///
  /// In en, this message translates to:
  /// **'Bond Name'**
  String get bondName;

  /// No description provided for @amountPieces.
  ///
  /// In en, this message translates to:
  /// **'Amount | Pieces'**
  String get amountPieces;

  /// No description provided for @profitPlusMinus.
  ///
  /// In en, this message translates to:
  /// **'Profit (+ -)'**
  String get profitPlusMinus;

  /// No description provided for @historyAll.
  ///
  /// In en, this message translates to:
  /// **'History (All)'**
  String get historyAll;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @pieces.
  ///
  /// In en, this message translates to:
  /// **'pieces'**
  String get pieces;

  /// No description provided for @interestRateShort.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get interestRateShort;

  /// No description provided for @incomeMethod.
  ///
  /// In en, this message translates to:
  /// **'Income Method'**
  String get incomeMethod;

  /// No description provided for @incomeMethodDesc.
  ///
  /// In en, this message translates to:
  /// **'You can buy bonds or stocks with your deposited money.'**
  String get incomeMethodDesc;

  /// No description provided for @qpay.
  ///
  /// In en, this message translates to:
  /// **'Qpay'**
  String get qpay;

  /// No description provided for @qpayAndCard.
  ///
  /// In en, this message translates to:
  /// **'Qpay and card'**
  String get qpayAndCard;

  /// No description provided for @recommend.
  ///
  /// In en, this message translates to:
  /// **'Recommend'**
  String get recommend;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// No description provided for @makeIncome.
  ///
  /// In en, this message translates to:
  /// **'Make Income'**
  String get makeIncome;

  /// No description provided for @million.
  ///
  /// In en, this message translates to:
  /// **'сая'**
  String get million;

  /// No description provided for @incomeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Income completed'**
  String get incomeSuccess;

  /// No description provided for @incomeSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'You are ready to invest!'**
  String get incomeSuccessDesc;

  /// No description provided for @withdrawMethod.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Method'**
  String get withdrawMethod;

  /// No description provided for @withdrawMethodDesc.
  ///
  /// In en, this message translates to:
  /// **'You can withdraw money from your account.'**
  String get withdrawMethodDesc;

  /// No description provided for @makeWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get makeWithdraw;

  /// No description provided for @withdrawSuccess.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal completed'**
  String get withdrawSuccess;

  /// No description provided for @withdrawSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Your withdrawal has been processed successfully!'**
  String get withdrawSuccessDesc;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// No description provided for @bankTransferDesc.
  ///
  /// In en, this message translates to:
  /// **'Transfer to bank account'**
  String get bankTransferDesc;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @filterAction.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterAction;

  /// No description provided for @clearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearFilter;

  /// No description provided for @selectPeriod.
  ///
  /// In en, this message translates to:
  /// **'Select period'**
  String get selectPeriod;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @last1MonthFilter.
  ///
  /// In en, this message translates to:
  /// **'Last 1 month'**
  String get last1MonthFilter;

  /// No description provided for @last3Months.
  ///
  /// In en, this message translates to:
  /// **'Last 3 months'**
  String get last3Months;

  /// No description provided for @last6Months.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get last6Months;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select start and end date'**
  String get selectDateRange;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @cashSection.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cashSection;

  /// No description provided for @boughtType.
  ///
  /// In en, this message translates to:
  /// **'Bought'**
  String get boughtType;

  /// No description provided for @soldType.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get soldType;

  /// No description provided for @bondReturnType.
  ///
  /// In en, this message translates to:
  /// **'Bond return'**
  String get bondReturnType;

  /// No description provided for @stockTransferType.
  ///
  /// In en, this message translates to:
  /// **'Stock transfer received'**
  String get stockTransferType;

  /// No description provided for @monthLabel.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get monthLabel;

  /// No description provided for @approxUsd.
  ///
  /// In en, this message translates to:
  /// **'≈{amount}\$'**
  String approxUsd(String amount);
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
