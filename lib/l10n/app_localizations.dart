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

  /// No description provided for @ipoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shares offered to the public for the first time'**
  String get ipoSubtitle;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @unitStockPrice.
  ///
  /// In en, this message translates to:
  /// **'Price per share'**
  String get unitStockPrice;

  /// No description provided for @topGainer.
  ///
  /// In en, this message translates to:
  /// **'Top gainer'**
  String get topGainer;

  /// No description provided for @topLoser.
  ///
  /// In en, this message translates to:
  /// **'Top loser'**
  String get topLoser;

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
  /// **'Market Value'**
  String get market;

  /// No description provided for @orderActive.
  ///
  /// In en, this message translates to:
  /// **'Trading Activity'**
  String get orderActive;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @pieceOfStock.
  ///
  /// In en, this message translates to:
  /// **'stocks'**
  String get pieceOfStock;

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
  /// **'Buy'**
  String get buy;

  /// No description provided for @sell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sell;

  /// No description provided for @bond.
  ///
  /// In en, this message translates to:
  /// **'Bond'**
  String get bond;

  /// No description provided for @term.
  ///
  /// In en, this message translates to:
  /// **'Term'**
  String get term;

  /// No description provided for @yield.
  ///
  /// In en, this message translates to:
  /// **'Yield'**
  String get yield;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

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
  /// **'Statement'**
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
  /// **'Inactive'**
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

  /// No description provided for @noConnectedDevices.
  ///
  /// In en, this message translates to:
  /// **'There is no Connected Devices'**
  String get noConnectedDevices;

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

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

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
  /// **'Active'**
  String get active;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @d1.
  ///
  /// In en, this message translates to:
  /// **'1D'**
  String get d1;

  /// No description provided for @d7.
  ///
  /// In en, this message translates to:
  /// **'7D'**
  String get d7;

  /// No description provided for @m1.
  ///
  /// In en, this message translates to:
  /// **'1M'**
  String get m1;

  /// No description provided for @m3.
  ///
  /// In en, this message translates to:
  /// **'3M'**
  String get m3;

  /// No description provided for @m6.
  ///
  /// In en, this message translates to:
  /// **'6M'**
  String get m6;

  /// No description provided for @y1.
  ///
  /// In en, this message translates to:
  /// **'1Y'**
  String get y1;

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

  /// No description provided for @askingWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Do you want to create a watchlist?'**
  String get askingWatchlist;

  /// No description provided for @watchlistDescription.
  ///
  /// In en, this message translates to:
  /// **'Save your favorite stocks and get real-time price updates instantly.'**
  String get watchlistDescription;

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

  /// No description provided for @noReportYet.
  ///
  /// In en, this message translates to:
  /// **'No report generated yet'**
  String get noReportYet;

  /// No description provided for @reportPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Select the period for the summary report'**
  String get reportPeriodTitle;

  /// No description provided for @periodOneMonth.
  ///
  /// In en, this message translates to:
  /// **'1 month'**
  String get periodOneMonth;

  /// No description provided for @periodThreeMonths.
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get periodThreeMonths;

  /// No description provided for @periodSixMonths.
  ///
  /// In en, this message translates to:
  /// **'6 months'**
  String get periodSixMonths;

  /// No description provided for @periodTwelveMonths.
  ///
  /// In en, this message translates to:
  /// **'12 months'**
  String get periodTwelveMonths;

  /// No description provided for @allTimeReport.
  ///
  /// In en, this message translates to:
  /// **'All-time report'**
  String get allTimeReport;

  /// No description provided for @emptyWatchlist.
  ///
  /// In en, this message translates to:
  /// **'No saved stocks'**
  String get emptyWatchlist;

  /// No description provided for @emptyWatchlistHint.
  ///
  /// In en, this message translates to:
  /// **'Add stocks using the + button'**
  String get emptyWatchlistHint;

  /// No description provided for @resultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String resultsCount(Object count);

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @noResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try changing your search keywords'**
  String get noResultsHint;

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
  /// **'View Bond Presentation'**
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

  /// No description provided for @marketPrice.
  ///
  /// In en, this message translates to:
  /// **'Market price'**
  String get marketPrice;

  /// No description provided for @tradeTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select order type'**
  String get tradeTypeTitle;

  /// No description provided for @limitPriceDesc.
  ///
  /// In en, this message translates to:
  /// **'You set the buy or sell price yourself. The order may not execute immediately — it fills when the market reaches your price.'**
  String get limitPriceDesc;

  /// No description provided for @marketPriceDesc.
  ///
  /// In en, this message translates to:
  /// **'Trades immediately at the best available price. The price may vary depending on market conditions.'**
  String get marketPriceDesc;

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

  /// No description provided for @signTitle.
  ///
  /// In en, this message translates to:
  /// **'Please sign here'**
  String get signTitle;

  /// No description provided for @signSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You only need to sign once. You will not be asked again.'**
  String get signSubtitle;

  /// No description provided for @signHere.
  ///
  /// In en, this message translates to:
  /// **'Sign here'**
  String get signHere;

  /// No description provided for @redraw.
  ///
  /// In en, this message translates to:
  /// **'Redraw'**
  String get redraw;

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

  /// No description provided for @registrationStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {num}: {title}'**
  String registrationStepLabel(int num, String title);

  /// No description provided for @registrationProgress.
  ///
  /// In en, this message translates to:
  /// **'Registration progress: {percent}%'**
  String registrationProgress(String percent);

  /// No description provided for @registrationProgressText.
  ///
  /// In en, this message translates to:
  /// **'Registration progress: '**
  String get registrationProgressText;

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

  /// No description provided for @depositSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select account to deposit'**
  String get depositSelectTitle;

  /// No description provided for @depositSelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the account depending on whether you are buying stocks or bonds'**
  String get depositSelectSubtitle;

  /// No description provided for @mntAccounts.
  ///
  /// In en, this message translates to:
  /// **'MNT accounts'**
  String get mntAccounts;

  /// No description provided for @usdAccounts.
  ///
  /// In en, this message translates to:
  /// **'USD accounts'**
  String get usdAccounts;

  /// No description provided for @availableBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get availableBalanceLabel;

  /// No description provided for @bondDepositTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit to bond account'**
  String get bondDepositTitle;

  /// No description provided for @depositInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please make the transfer using the details below.'**
  String get depositInfoSubtitle;

  /// No description provided for @receiverBank.
  ///
  /// In en, this message translates to:
  /// **'Receiving bank'**
  String get receiverBank;

  /// No description provided for @ibanAccountNo.
  ///
  /// In en, this message translates to:
  /// **'IBAN account number'**
  String get ibanAccountNo;

  /// No description provided for @transferAmount.
  ///
  /// In en, this message translates to:
  /// **'Transfer amount'**
  String get transferAmount;

  /// No description provided for @transactionMemo.
  ///
  /// In en, this message translates to:
  /// **'Transaction memo'**
  String get transactionMemo;

  /// No description provided for @copiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copiedLabel;

  /// No description provided for @definitionRequestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the language and specify what the statement is for'**
  String get definitionRequestSubtitle;

  /// No description provided for @purposeLabel.
  ///
  /// In en, this message translates to:
  /// **'What is it for'**
  String get purposeLabel;

  /// No description provided for @purposeExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. Embassy of Japan'**
  String get purposeExample;

  /// No description provided for @getDefinition.
  ///
  /// In en, this message translates to:
  /// **'Get statement'**
  String get getDefinition;

  /// No description provided for @definitionReceiveType.
  ///
  /// In en, this message translates to:
  /// **'Statement delivery type'**
  String get definitionReceiveType;

  /// No description provided for @agreementReceiveType.
  ///
  /// In en, this message translates to:
  /// **'Agreement delivery type'**
  String get agreementReceiveType;

  /// No description provided for @receiveTypeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A 4-digit code will be sent to your chosen phone number or email.'**
  String get receiveTypeSubtitle;

  /// No description provided for @directDownload.
  ///
  /// In en, this message translates to:
  /// **'Direct download'**
  String get directDownload;

  /// No description provided for @downloadAsPdfLabel.
  ///
  /// In en, this message translates to:
  /// **'Download as PDF'**
  String get downloadAsPdfLabel;

  /// No description provided for @langMongolian.
  ///
  /// In en, this message translates to:
  /// **'Mongolian'**
  String get langMongolian;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @currencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyLabel;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get termsOfService;

  /// No description provided for @securitiesStatement.
  ///
  /// In en, this message translates to:
  /// **'Securities statement'**
  String get securitiesStatement;

  /// No description provided for @securitiesStatementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Securities you own'**
  String get securitiesStatementSubtitle;

  /// No description provided for @agreementLabel.
  ///
  /// In en, this message translates to:
  /// **'Agreement'**
  String get agreementLabel;

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
  /// **'Total return'**
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
  /// **'Select an account to withdraw from'**
  String get withdrawMethodDesc;

  /// No description provided for @makeWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get makeWithdraw;

  /// No description provided for @addAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get addAccountLabel;

  /// No description provided for @receiveAccount.
  ///
  /// In en, this message translates to:
  /// **'Receiving account'**
  String get receiveAccount;

  /// No description provided for @withdrawAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal amount'**
  String get withdrawAmountTitle;

  /// No description provided for @withdrawSuccess.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal completed'**
  String get withdrawSuccess;

  /// No description provided for @withdrawSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Transactions are consolidated from multiple accounts, so please wait a moment.'**
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

  /// No description provided for @mandalCapital.
  ///
  /// In en, this message translates to:
  /// **'Mandal Capital'**
  String get mandalCapital;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @registerContactPrefix.
  ///
  /// In en, this message translates to:
  /// **'If you wish to register as an organization,'**
  String get registerContactPrefix;

  /// No description provided for @registerContactPostfix.
  ///
  /// In en, this message translates to:
  /// **' please send your request to '**
  String get registerContactPostfix;

  /// No description provided for @approxUsd.
  ///
  /// In en, this message translates to:
  /// **'≈{amount}\$'**
  String approxUsd(String amount);

  /// No description provided for @educationTitle.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get educationTitle;

  /// No description provided for @educationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Growing your financial knowledge brings more freedom to your life.'**
  String get educationSubtitle;

  /// No description provided for @eduCourseIntro.
  ///
  /// In en, this message translates to:
  /// **'Introduction to investing'**
  String get eduCourseIntro;

  /// No description provided for @eduCourseBond.
  ///
  /// In en, this message translates to:
  /// **'Bond course'**
  String get eduCourseBond;

  /// No description provided for @eduCourseStock.
  ///
  /// In en, this message translates to:
  /// **'Stock course'**
  String get eduCourseStock;

  /// No description provided for @eduCourseFund.
  ///
  /// In en, this message translates to:
  /// **'Investment fund course'**
  String get eduCourseFund;

  /// No description provided for @eduLessonProgress.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total}'**
  String eduLessonProgress(int done, int total);

  /// No description provided for @appGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'App user guide'**
  String get appGuideTitle;

  /// No description provided for @eduGeneralInfo.
  ///
  /// In en, this message translates to:
  /// **'General information'**
  String get eduGeneralInfo;

  /// No description provided for @eduGeneralInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'What every client should know'**
  String get eduGeneralInfoDesc;

  /// No description provided for @eduGeneral1.
  ///
  /// In en, this message translates to:
  /// **'Create an account and verify your identity'**
  String get eduGeneral1;

  /// No description provided for @eduGeneral2.
  ///
  /// In en, this message translates to:
  /// **'Home page dashboard'**
  String get eduGeneral2;

  /// No description provided for @eduGeneral3.
  ///
  /// In en, this message translates to:
  /// **'Portfolio: your assets and performance'**
  String get eduGeneral3;

  /// No description provided for @eduTradingTitle.
  ///
  /// In en, this message translates to:
  /// **'How to trade?'**
  String get eduTradingTitle;

  /// No description provided for @eduTradingDesc.
  ///
  /// In en, this message translates to:
  /// **'Bond and stock trading'**
  String get eduTradingDesc;

  /// No description provided for @eduTrading1.
  ///
  /// In en, this message translates to:
  /// **'Buying bonds'**
  String get eduTrading1;

  /// No description provided for @eduTrading2.
  ///
  /// In en, this message translates to:
  /// **'Buying stocks'**
  String get eduTrading2;

  /// No description provided for @eduTrading3.
  ///
  /// In en, this message translates to:
  /// **'Market order vs Limit order'**
  String get eduTrading3;

  /// No description provided for @eduSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get eduSecurityTitle;

  /// No description provided for @eduSecurityDesc.
  ///
  /// In en, this message translates to:
  /// **'How to protect your information?'**
  String get eduSecurityDesc;

  /// No description provided for @eduSecurity1.
  ///
  /// In en, this message translates to:
  /// **'Investment risks'**
  String get eduSecurity1;

  /// No description provided for @eduSecurity2.
  ///
  /// In en, this message translates to:
  /// **'Preventing fraud and protecting your account'**
  String get eduSecurity2;

  /// No description provided for @eduSecurity3.
  ///
  /// In en, this message translates to:
  /// **'Protecting your account (PIN, biometrics, two-factor authentication)'**
  String get eduSecurity3;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View more'**
  String get viewMore;

  /// No description provided for @searchByKeyword.
  ///
  /// In en, this message translates to:
  /// **'Search by keyword'**
  String get searchByKeyword;

  /// No description provided for @eduQuizLabel.
  ///
  /// In en, this message translates to:
  /// **'Knowledge check'**
  String get eduQuizLabel;

  /// No description provided for @eduNextCounter.
  ///
  /// In en, this message translates to:
  /// **'Next {current}/{total}'**
  String eduNextCounter(int current, int total);

  /// No description provided for @eduFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get eduFinish;

  /// No description provided for @eduCorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer'**
  String get eduCorrectAnswer;

  /// No description provided for @eduCorrectDesc.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You have completed this lesson.'**
  String get eduCorrectDesc;

  /// No description provided for @eduWrongAnswer.
  ///
  /// In en, this message translates to:
  /// **'Incorrect answer'**
  String get eduWrongAnswer;

  /// No description provided for @eduWrongDesc.
  ///
  /// In en, this message translates to:
  /// **'The lesson counts as completed only with a correct answer. Watch this lesson again?'**
  String get eduWrongDesc;

  /// No description provided for @eduRetryLesson.
  ///
  /// In en, this message translates to:
  /// **'Watch lesson again'**
  String get eduRetryLesson;

  /// No description provided for @eduLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get eduLater;

  /// No description provided for @eduCheckAnswer.
  ///
  /// In en, this message translates to:
  /// **'Check answer {current}/{total}'**
  String eduCheckAnswer(int current, int total);

  /// No description provided for @noBondsYet.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any bonds yet'**
  String get noBondsYet;

  /// No description provided for @noStocksYet.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any stocks yet'**
  String get noStocksYet;

  /// No description provided for @startInvestingPrompt.
  ///
  /// In en, this message translates to:
  /// **'Ready to start investing?'**
  String get startInvestingPrompt;

  /// No description provided for @timesReceived.
  ///
  /// In en, this message translates to:
  /// **'received {cnt}/{total} times'**
  String timesReceived(int cnt, int total);

  /// No description provided for @timesRemaining.
  ///
  /// In en, this message translates to:
  /// **'{cnt}/{total} times remaining'**
  String timesRemaining(int cnt, int total);

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @listUpdated.
  ///
  /// In en, this message translates to:
  /// **'List updated'**
  String get listUpdated;

  /// No description provided for @changed.
  ///
  /// In en, this message translates to:
  /// **'Changed'**
  String get changed;

  /// No description provided for @hasError.
  ///
  /// In en, this message translates to:
  /// **'Has error'**
  String get hasError;

  /// No description provided for @childRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your child\'s registration number'**
  String get childRegisterTitle;

  /// No description provided for @childRegisterDesc.
  ///
  /// In en, this message translates to:
  /// **'Only a legal guardian can open a child\'s account.'**
  String get childRegisterDesc;

  /// No description provided for @childDocTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload a photo of the birth certificate'**
  String get childDocTitle;

  /// No description provided for @birthCertificate.
  ///
  /// In en, this message translates to:
  /// **'Birth certificate'**
  String get birthCertificate;

  /// No description provided for @childSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'We are reviewing your child\'s information — the trading account will open within 2 business days.'**
  String get childSuccessDesc;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications at the moment.'**
  String get noNotifications;

  /// No description provided for @removeFromList.
  ///
  /// In en, this message translates to:
  /// **'Do you want to remove {name} stock from your watchlist?'**
  String removeFromList(String name);

  /// No description provided for @holdAmount.
  ///
  /// In en, this message translates to:
  /// **'Hold Amount'**
  String get holdAmount;

  /// No description provided for @holdAmountDesc.
  ///
  /// In en, this message translates to:
  /// **'The total amount ordered to purchase stocks and bonds is called the hold amount. If the order is not executed, the hold amount can be canceled to increase cash balance.'**
  String get holdAmountDesc;

  /// No description provided for @cashDesc.
  ///
  /// In en, this message translates to:
  /// **'It refers to the total available cash amount that can be used to purchase securities such as stocks and bonds.'**
  String get cashDesc;

  /// No description provided for @totalReturnReceivedInfo.
  ///
  /// In en, this message translates to:
  /// **'Bond interest income you have earned in the past.'**
  String get totalReturnReceivedInfo;

  /// No description provided for @futureReturnInfo.
  ///
  /// In en, this message translates to:
  /// **'Bond interest income you will earn in the future.'**
  String get futureReturnInfo;

  /// No description provided for @noActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'No active orders'**
  String get noActiveOrders;

  /// No description provided for @noActiveOrdersDesc.
  ///
  /// In en, this message translates to:
  /// **'To see completed or canceled orders, tap “Order History”'**
  String get noActiveOrdersDesc;

  /// No description provided for @noHistoryFound.
  ///
  /// In en, this message translates to:
  /// **'No history found'**
  String get noHistoryFound;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @canceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get canceled;

  /// No description provided for @cancelAllOrders.
  ///
  /// In en, this message translates to:
  /// **'Cancel all orders'**
  String get cancelAllOrders;

  /// No description provided for @dailyStockRate.
  ///
  /// In en, this message translates to:
  /// **'Daily stock rate'**
  String get dailyStockRate;

  /// No description provided for @last1Year.
  ///
  /// In en, this message translates to:
  /// **'Last 1 year'**
  String get last1Year;

  /// No description provided for @orderedDate.
  ///
  /// In en, this message translates to:
  /// **'Ordered date'**
  String get orderedDate;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @exchangeRateGain.
  ///
  /// In en, this message translates to:
  /// **'Exchange rate gain'**
  String get exchangeRateGain;

  /// No description provided for @bondsPiece.
  ///
  /// In en, this message translates to:
  /// **'bonds'**
  String get bondsPiece;

  /// No description provided for @lastInterestPaymentDate.
  ///
  /// In en, this message translates to:
  /// **'Last interest payment date'**
  String get lastInterestPaymentDate;

  /// No description provided for @nominal.
  ///
  /// In en, this message translates to:
  /// **'Nominal'**
  String get nominal;

  /// No description provided for @csd.
  ///
  /// In en, this message translates to:
  /// **'CSD'**
  String get csd;

  /// No description provided for @buyStock.
  ///
  /// In en, this message translates to:
  /// **'Buy stock'**
  String get buyStock;

  /// No description provided for @totalYield.
  ///
  /// In en, this message translates to:
  /// **'Total yield:'**
  String get totalYield;

  /// No description provided for @totalYieldGot.
  ///
  /// In en, this message translates to:
  /// **'Total yield (got):'**
  String get totalYieldGot;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'DAYS LEFT'**
  String get daysLeft;

  /// No description provided for @totalPriceBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Total price breakdown'**
  String get totalPriceBreakdown;

  /// No description provided for @unitPriceExplanation.
  ///
  /// In en, this message translates to:
  /// **'Unit price explanation'**
  String get unitPriceExplanation;

  /// No description provided for @unitPriceFormula.
  ///
  /// In en, this message translates to:
  /// **'Piece price + Accrued price = Unit price'**
  String get unitPriceFormula;

  /// No description provided for @piecePrice.
  ///
  /// In en, this message translates to:
  /// **'Piece price'**
  String get piecePrice;

  /// No description provided for @accruedInterest.
  ///
  /// In en, this message translates to:
  /// **'Accrued interest'**
  String get accruedInterest;

  /// No description provided for @returnBack.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returnBack;

  /// No description provided for @accruedInterestDescP1.
  ///
  /// In en, this message translates to:
  /// **'Interest on bonds accrues daily, but the payout schedule varies—such as monthly, quarterly, or semi-annually.'**
  String get accruedInterestDescP1;

  /// No description provided for @accruedInterestDescP2.
  ///
  /// In en, this message translates to:
  /// **'For example, suppose the bond you are looking to buy pays interest quarterly. However, what if there is only one month remaining until the next coupon payment date?'**
  String get accruedInterestDescP2;

  /// No description provided for @accruedInterestDescP3.
  ///
  /// In en, this message translates to:
  /// **'You cannot receive a full three months\' worth of interest when you have only held the bond for one month. Therefore, you must pay the seller the accrued interest for the two months during which you did not own the bond. Then, on the next coupon payment date—one month later—you will be entitled to receive the full three-month interest payment.'**
  String get accruedInterestDescP3;

  /// No description provided for @prevInterestPaidDate.
  ///
  /// In en, this message translates to:
  /// **'Previous interest\n payment date'**
  String get prevInterestPaidDate;

  /// No description provided for @nextInterestPayDueDate.
  ///
  /// In en, this message translates to:
  /// **'Next interest\n payment date'**
  String get nextInterestPayDueDate;

  /// No description provided for @todayBondBuyDate.
  ///
  /// In en, this message translates to:
  /// **'Today\n(Bond buy date)'**
  String get todayBondBuyDate;

  /// No description provided for @accruedInterestToSeller.
  ///
  /// In en, this message translates to:
  /// **'Accrued interest\n paid to seller'**
  String get accruedInterestToSeller;

  /// No description provided for @yourInterestToReceive.
  ///
  /// In en, this message translates to:
  /// **'YOUR INTEREST TO RECEIVE'**
  String get yourInterestToReceive;

  /// No description provided for @stockTradingNoPowerTitle.
  ///
  /// In en, this message translates to:
  /// **'Please make a deposit into your business account'**
  String get stockTradingNoPowerTitle;

  /// No description provided for @stockTradingNoPowerDesc.
  ///
  /// In en, this message translates to:
  /// **'To buy domestic and international stocks, you first need to deposit funds into your trading account.'**
  String get stockTradingNoPowerDesc;

  /// No description provided for @marketClosedNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'The market is closed'**
  String get marketClosedNotifTitle;

  /// No description provided for @marketClosedNotifDesc.
  ///
  /// In en, this message translates to:
  /// **'Mongolian Stock Exchange trading hours are from {startDate} to {endDate}. You can only trade at market price during this period.'**
  String marketClosedNotifDesc(String startDate, String endDate);

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// No description provided for @stockTradingMarketPriceNotify.
  ///
  /// In en, this message translates to:
  /// **'Please note that the total amount of market orders may vary depending on the market price at execution.'**
  String get stockTradingMarketPriceNotify;
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
