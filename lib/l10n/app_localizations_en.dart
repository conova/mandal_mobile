// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Antigravity';

  @override
  String get login => 'Login';

  @override
  String get useAnotherAccount => 'Use another account';

  @override
  String get loginErrorPhone => 'Phone number or password is incorrect.';

  @override
  String get loginErrorEmail => 'Email or password is incorrect.';

  @override
  String get connectionError => 'Something went wrong. Please try again.';

  @override
  String get tryAgain => 'Try again';

  @override
  String attemptsRemaining(Object count) {
    return 'Incorrect phone number or password. \n$count attempt(s) remaining.';
  }

  @override
  String attemptsRemainingEmail(Object count) {
    return 'Incorrect email or password. \n$count attempt(s) remaining.';
  }

  @override
  String get validationEmailRequired => 'Email is required';

  @override
  String get validationInvalidFormat => 'Invalid or incomplete format';

  @override
  String get validationThisField => 'This field';

  @override
  String validationRequired(Object field) {
    return '$field is empty';
  }

  @override
  String get validationRegisterRequired => 'Enter registration number';

  @override
  String get validationRegisterInvalid => 'Registration number is invalid';

  @override
  String get validationPhoneRequired => 'Enter phone number';

  @override
  String validationEnterField(Object field) {
    return 'Enter $field';
  }

  @override
  String validationLettersOnly(Object field) {
    return '$field must contain only letters';
  }

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get register => 'Register';

  @override
  String get portfolio => 'Portfolio';

  @override
  String get bonds => 'Bonds';

  @override
  String get stocks => 'Stocks';

  @override
  String get orders => 'Orders';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get myAssets => 'My Assets';

  @override
  String get viewAll => 'View All';

  @override
  String get mandalSavings => 'MANDAL SAVINGS';

  @override
  String get mySavings => 'My Savings';

  @override
  String get finished => 'Finished';

  @override
  String get add => 'Add';

  @override
  String get searchByName => 'Search by name';

  @override
  String get dividendPortfolio => 'Dividend Portfolio';

  @override
  String get recommendedStocks => 'Recommended Stocks';

  @override
  String get viewPortfolio => 'View Portfolio';

  @override
  String get all => 'All';

  @override
  String get ipo => 'IPO';

  @override
  String get ipoSubtitle => 'Shares offered to the public for the first time';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get unitStockPrice => 'Price per share';

  @override
  String get topGainer => 'Top gainer';

  @override
  String get topLoser => 'Top loser';

  @override
  String get gainers => 'Gainers';

  @override
  String get losers => 'Losers';

  @override
  String get market => 'Market Value';

  @override
  String get orderActive => 'Trading Activity';

  @override
  String get stock => 'Stock';

  @override
  String get saved => 'Saved';

  @override
  String get pieceOfStock => 'stocks';

  @override
  String get lastPrice24h => 'Last Price (24h)';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get activeOrders => 'Active Orders';

  @override
  String get orderHistory => 'Order History';

  @override
  String get executionQuantity => 'Execution/Qty';

  @override
  String get unitPrice => 'Unit Price';

  @override
  String get sellingPrice => 'Selling Price';

  @override
  String get open => 'OPEN';

  @override
  String get closed => 'CLOSED';

  @override
  String get foreign => 'FOREIGN';

  @override
  String get buy => 'Buy';

  @override
  String get sell => 'Sell';

  @override
  String get bond => 'Bond';

  @override
  String get term => 'Term';

  @override
  String get yield => 'Yield';

  @override
  String get balance => 'Balance';

  @override
  String get orderUpdated => 'Order Updated';

  @override
  String get totalAssets => 'Total Assets';

  @override
  String get last1Month => 'Last 1 month';

  @override
  String get history => 'Statement';

  @override
  String get assetBreakdown => 'Asset Breakdown';

  @override
  String get tugrik => 'Tugrik';

  @override
  String get dollar => 'Dollar';

  @override
  String orderCount(String count) {
    return '$count Orders';
  }

  @override
  String get emailHint => 'Please enter your email';

  @override
  String get phonePlaceholder => 'Phone number entry section';

  @override
  String get forgotPasswordBtn => 'Forgot password?';

  @override
  String get noCompletedSavings => 'No completed savings found.';

  @override
  String get tenureLabel => 'Tenure';

  @override
  String get interestRate => 'Rate';

  @override
  String get endDateLabel => 'End Date';

  @override
  String get uiComponentsShowcase => 'UI Components Showcase';

  @override
  String get uiComponentsSubtitle => 'View all available components';

  @override
  String get themeColorsSubtitle => 'Discover the design system palette';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get darkMode => 'Enable Darkmode';

  @override
  String get lightMode => 'Enable Lightmode';

  @override
  String get myInfo => 'My Information';

  @override
  String get myInfoSubtitle => 'Email, Phone Number, Address';

  @override
  String get incomeAccount => 'Income Account';

  @override
  String get incomeAccountSubtitle => 'Golomt Bank - MN650039008000110...';

  @override
  String get summaryReport => 'Summary Report';

  @override
  String get summaryReportSubtitle => 'Monthly and annual reports';

  @override
  String get childAccount => 'Child Account';

  @override
  String get createNewAccount => 'Create New Account';

  @override
  String get createNewAccountSubtitle => 'Invest in your future';

  @override
  String get security => 'Security';

  @override
  String get biometric => 'Biometric';

  @override
  String get inactive => 'Inactive';

  @override
  String get changePassword => 'Change Password';

  @override
  String get lastChanged => 'Changed on 2025.10.20';

  @override
  String passwordChangedOn(Object date) {
    return 'Changed on $date';
  }

  @override
  String get connectedDevices => 'Connected Devices';

  @override
  String get noConnectedDevices => 'There is no Connected Devices';

  @override
  String get devicesCount => '2 devices';

  @override
  String deviceCountLabel(Object count) {
    return '$count devices';
  }

  @override
  String get biometricFaceTitle => 'Enable Face ID?';

  @override
  String get biometricFingerprintTitle => 'Enable Fingerprint?';

  @override
  String get biometricEnrollDesc =>
      'This lets you log in quickly using biometrics next time.';

  @override
  String get biometricEnrollConfirm => 'Enable';

  @override
  String get skip => 'Skip';

  @override
  String get logout => 'Log Out';

  @override
  String get notifications => 'Notifications';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get allNotifications => 'All';

  @override
  String get trading => 'Trading';

  @override
  String get news => 'News';

  @override
  String get others => 'Others';

  @override
  String get markAllReadTitle => 'Mark all as read';

  @override
  String get markAllReadDesc =>
      'Are you sure you want to mark all notifications as read and remove the unread indicators?';

  @override
  String get confirm => 'Yes, mark as read';

  @override
  String get back => 'Back';

  @override
  String get notificationRelatedInfo => 'Related details';

  @override
  String get surname => 'Surname';

  @override
  String get firstName => 'First Name';

  @override
  String get regNo => 'Registration No';

  @override
  String get address => 'Address';

  @override
  String get otherAccounts => 'Other Accounts';

  @override
  String get incomeAccBenefitPrompt =>
      'Profit from your trades will be transferred to this account.';

  @override
  String get addIncomeAccPrompt => 'Please enter an income account';

  @override
  String get iban => 'IBAN Number';

  @override
  String get bank => 'Bank';

  @override
  String get receiver => 'Receiver';

  @override
  String get receiverHint => 'Write in Surname Name order';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving...';

  @override
  String get growth => 'Growth';

  @override
  String get lastMonth => 'Last 1 month';

  @override
  String get cash => 'Cash';

  @override
  String get type => 'Type';

  @override
  String get incomeExpense => 'Income/Expense';

  @override
  String get incomeSalary => 'Income/Salary';

  @override
  String get stockProfit => 'Stock Profit';

  @override
  String get interestIncome => 'Interest Income';

  @override
  String get bondPrincipal => 'Bond Principal Payment';

  @override
  String get dividendProfit => 'Dividend Profit';

  @override
  String get downloadReport => 'Download Report';

  @override
  String get oneDay => '1D';

  @override
  String get threeDays => '3C';

  @override
  String get sixDays => '6C';

  @override
  String get oneYear => '1Ж';

  @override
  String get selectedPeriod => 'Selected Period';

  @override
  String get connectedDevicesDesc =>
      'List of devices connected to your Mandal Capital app. Please remove any unrecognized devices.';

  @override
  String get active => 'Active';

  @override
  String get date => 'Date';

  @override
  String get d1 => '1D';

  @override
  String get d7 => '7D';

  @override
  String get m1 => '1M';

  @override
  String get m3 => '3M';

  @override
  String get m6 => '6M';

  @override
  String get y1 => '1Y';

  @override
  String get ipAddress => 'IP Address';

  @override
  String get remove => 'Remove';

  @override
  String get logoutConfirmTitle => 'Logout from App';

  @override
  String get logoutConfirmDesc =>
      'Are you sure you want to log out from Mandal Capital app?';

  @override
  String get yesLogout => 'Yes, Logout';

  @override
  String get selectVerifyChannel => 'Select verification channel';

  @override
  String get verifyChannelPrompt =>
      'A 4-digit code will be sent to your selected phone number or email address.';

  @override
  String get sms => 'SMS';

  @override
  String get emailLabel => 'Email';

  @override
  String get enterCodeTitle => 'Enter 4-digit code';

  @override
  String codeSentTo(Object value) {
    return 'A code was sent to your $value.';
  }

  @override
  String get resendCode => 'Resend code';

  @override
  String get noCodeReceived => 'Didn\'t receive a code?';

  @override
  String get createNewPassword => 'Create new password';

  @override
  String get passwordHint => 'Password';

  @override
  String get repeatPasswordHint => 'Repeat Password';

  @override
  String get atLeast8Chars => 'At least 8 characters';

  @override
  String get uppercaseLetter => 'Uppercase (A-Z)';

  @override
  String get lowercaseLetter => 'Lowercase (a-z)';

  @override
  String get numberDigit => 'Number (0-9)';

  @override
  String get continueLabel => 'Continue';

  @override
  String get incomeAccountDetail => 'Income Account Detail';

  @override
  String get incomeAccountDetailDesc =>
      'Profits from your trades will be transferred to this account.';

  @override
  String get ibanNumber => 'IBAN Number';

  @override
  String get accountChangedSuccess => 'Income account changed successfully.';

  @override
  String get changeAccount => 'Change Account';

  @override
  String get setAsDefaultAccount => 'Set as receiving account';

  @override
  String get loginSubtitle => 'Today\'s decision, tomorrow\'s reward';

  @override
  String get newToApp => 'New user?';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordSubtitle => 'Enter your registered information';

  @override
  String get registrationNumber => 'Registration Number';

  @override
  String get continueBtn => 'Continue';

  @override
  String get registerTitle => 'Register';

  @override
  String get registerSubtitle => 'Enter your personal information';

  @override
  String get lastName => 'Last Name';

  @override
  String get enterIncomeAccount => 'Enter income account';

  @override
  String get enterIncomeAccountSubtitle =>
      'Profits from your trades will be transferred to this account';

  @override
  String get bankName => 'Bank';

  @override
  String get recipientName => 'Recipient';

  @override
  String get lastNameOrFirstNameNote => 'Write in last name, first name order';

  @override
  String get registrationSuccess => 'Registration Successful';

  @override
  String get registrationSuccessMessage =>
      'Your goals, our experience - we are confident that it will be full of trust, rewards, and opportunities.';

  @override
  String get finish => 'Finish';

  @override
  String get selectYourBank => 'Select your securities account';

  @override
  String get selectBankToContinue => 'Check payment';

  @override
  String get amountLabel => 'Amount';

  @override
  String get lockedAmountLabel => 'Locked Amount';

  @override
  String get placeOrder => 'Place Order';

  @override
  String get receivableAmountLabel => 'Receivable Amount';

  @override
  String get sellPriceDesc =>
      'The lower the selling price, the more likely your order will be executed quickly.';

  @override
  String get swipeUpToConfirm => 'Swipe up to confirm';

  @override
  String get orderPlacedSuccess => 'ORDER\nPLACED';

  @override
  String get orderPlacedDesc =>
      'We will notify you when the order is fulfilled and interest starts accruing.';

  @override
  String get viewOrders => 'View Orders';

  @override
  String get sellOrderSuccessDesc =>
      'Please note that only the best selling price will be visible to other investors.';

  @override
  String get commissionLabel => 'Commission';

  @override
  String get ownedAmountLabel => 'Owned Amount';

  @override
  String get pledgeBondDesc =>
      'Solve your financial needs without selling your bonds.';

  @override
  String get pledge => 'Pledge';

  @override
  String get newBond => 'New Bond';

  @override
  String get newBondDesc =>
      'Earn steady returns with our premium bond offerings. Start investing today.';

  @override
  String get watchlist => 'Watchlist';

  @override
  String get askingWatchlist => 'Do you want to create a watchlist?';

  @override
  String get watchlistDescription =>
      'Save your favorite stocks and get real-time price updates instantly.';

  @override
  String get recommendationTitle => 'Don\'t know which bond to choose?';

  @override
  String get recommendationDesc =>
      'We recommend the best bonds based on your interests.';

  @override
  String get uploading => 'Uploading';

  @override
  String get noData => 'No data';

  @override
  String get addEmail => 'Add email';

  @override
  String get annualYield => 'Annual yield';

  @override
  String get nextInterestPayDate => 'Next interest payment date';

  @override
  String get bondMaturityDate => 'Maturity date';

  @override
  String daysCount(Object days) {
    return '$days days';
  }

  @override
  String get tradePlannedDate => 'Planned trade execution date';

  @override
  String get buyRate => 'Buy price';

  @override
  String get selectPledgeBond => 'Select bond to pledge';

  @override
  String get pledgeBondSelectDesc =>
      'Pledge your bond and pay +6.0% interest when releasing it. Just like a deposit-backed bank loan.';

  @override
  String get pledgeQuantityLabel => 'Pledge quantity';

  @override
  String availablePieces(Object count) {
    return 'Available: $count pcs';
  }

  @override
  String get receiveAmountLabel => 'Receive amount';

  @override
  String get noReportYet => 'No report generated yet';

  @override
  String get reportPeriodTitle => 'Select the period for the summary report';

  @override
  String get periodOneMonth => '1 month';

  @override
  String get periodThreeMonths => '3 months';

  @override
  String get periodSixMonths => '6 months';

  @override
  String get periodTwelveMonths => '12 months';

  @override
  String get allTimeReport => 'All-time report';

  @override
  String get emptyWatchlist => 'No saved stocks';

  @override
  String get emptyWatchlistHint => 'Add stocks using the + button';

  @override
  String resultsCount(Object count) {
    return '$count results';
  }

  @override
  String get noResults => 'No results';

  @override
  String get noResultsHint => 'Try changing your search keywords';

  @override
  String get sorryTitle => 'Sorry';

  @override
  String get noPledgeBondDesc =>
      'You currently have no bonds available to pledge.';

  @override
  String get requestSent => 'REQUEST SENT';

  @override
  String requestSentDesc(Object phone) {
    return 'Our broker will contact you shortly at $phone.';
  }

  @override
  String get closedBondInfoTitle => 'Closed bond';

  @override
  String get closedBondInfoDesc =>
      'A bond traded over the counter with a 10% interest income tax, similar to a savings deposit.';

  @override
  String get openBondInfoTitle => 'Open bond';

  @override
  String get openBondInfoDesc =>
      'A bond openly traded on the exchange that can be bought or sold at any time.';

  @override
  String get foreignBondInfoTitle => 'Foreign bond';

  @override
  String get foreignBondInfoDesc =>
      'A bond denominated in foreign currency and traded on international markets.';

  @override
  String get close => 'Close';

  @override
  String get stockRecommendationTitle => 'Recommended stocks';

  @override
  String get stockRecommendationDesc =>
      'We recommend the stocks with the highest trading value.';

  @override
  String get sellBond => 'Sell Bond';

  @override
  String get mandalBond => 'MANDAL BOND';

  @override
  String get primaryMarket => 'Primary Market';

  @override
  String get secondaryMarket => 'Secondary Market';

  @override
  String get myBond => 'My Bond';

  @override
  String get pledgeBond => 'Pledge Bond';

  @override
  String get bondCollectionTarget => 'Collection Target';

  @override
  String get annualInterest => 'Annual Interest';

  @override
  String get paymentFrequency => 'Payment Frequency';

  @override
  String get availableCash => 'Available Cash';

  @override
  String get buyQuantity => 'Buy Quantity';

  @override
  String get unrealizedProfitNote =>
      'Unrealized profit is calculated without fees and taxes; actual profit is determined after the securities are sold.';

  @override
  String get sellQuantity => 'Sell quantity';

  @override
  String get availableQuantity => 'Available';

  @override
  String get totalPayment => 'Total Payment';

  @override
  String get totalReturn => 'Total Return';

  @override
  String get lockedAmount => 'Locked Amount';

  @override
  String get release => 'Release';

  @override
  String get orderRegistered => 'ORDER REGISTERED';

  @override
  String get sellPrice => 'Sell Price';

  @override
  String get executionProbability => 'Execution Probability';

  @override
  String get orderBoard => 'Order Board';

  @override
  String get high => 'High';

  @override
  String get medium => 'Medium';

  @override
  String get low => 'Low';

  @override
  String get bondClosingDateLabel => 'Closing Date';

  @override
  String get viewBondPresentation => 'View Bond Presentation';

  @override
  String get buyBond => 'Buy Bond';

  @override
  String get availableAmountLabel => 'Available Amount';

  @override
  String get costLabel => 'Interest Rate';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get tradeAmount => 'Trade Amount';

  @override
  String get orderTypeLabel => 'Type';

  @override
  String get orderStatusLabel => 'Status';

  @override
  String get yieldLabel => 'Yield';

  @override
  String get settlementDate => 'Settlement Date';

  @override
  String get orderDate => 'Order Date';

  @override
  String get executionHistory => 'Execution History';

  @override
  String get executedQuantity => 'Executed Quantity';

  @override
  String get partiallyFilled => 'Partially Filled';

  @override
  String get limitPrice => 'Limit Price';

  @override
  String get marketPrice => 'Market price';

  @override
  String get tradeTypeTitle => 'Select order type';

  @override
  String get limitPriceDesc =>
      'You set the buy or sell price yourself. The order may not execute immediately — it fills when the market reaches your price.';

  @override
  String get marketPriceDesc =>
      'Trades immediately at the best available price. The price may vary depending on market conditions.';

  @override
  String get generalInfo => 'General Information';

  @override
  String get marketCap => 'Market Cap';

  @override
  String get avgVolume => 'Avg Volume';

  @override
  String get dividendYield => 'Dividend Yield';

  @override
  String get dailyVolume => 'Daily Volume';

  @override
  String get pastDividends => 'Past Dividends';

  @override
  String get trade => 'Trade';

  @override
  String get billion => 'billion';

  @override
  String get today => 'Today';

  @override
  String get stockTrading => 'Stock Trading';

  @override
  String get paste => 'Paste';

  @override
  String get buyTab => 'Buy';

  @override
  String get sellTab => 'Sell';

  @override
  String get totalPaymentLabel => 'Total Payment';

  @override
  String get totalReceivableLabel => 'Total Receivable';

  @override
  String get orderBoardTitle => 'Order Board';

  @override
  String get buyAmount => 'Buy';

  @override
  String get sellAmount => 'Sell';

  @override
  String get releaseLockedTitle => 'Release Locked Amount';

  @override
  String get releaseLockedSubtitle =>
      'You can increase your cash by canceling active orders (locked amount).';

  @override
  String get cancelOrder => 'Cancel Order';

  @override
  String get acceptTerms => 'I agree to the terms of the agreement';

  @override
  String get agree => 'Agree';

  @override
  String get signTitle => 'Please sign here';

  @override
  String get signSubtitle =>
      'You only need to sign once. You will not be asked again.';

  @override
  String get signHere => 'Sign here';

  @override
  String get redraw => 'Redraw';

  @override
  String get agreed => 'Agreed';

  @override
  String get securitiesAgreementContent =>
      'This agreement is entered into between \"Mongolian Stock Exchange\" JSC /hereinafter referred to as the Exchange/, represented by ................................................, and \"................................................\" JSC /hereinafter referred to as the Issuer, collectively the Parties/, represented by ........................................... on the following terms and conditions.\n\n1.1 This agreement defines the rights, duties, and responsibilities of the parties in relation to the Exchange\'s actions of registering the Issuer and its securities, organizing the trading of securities in accordance with the relevant rules and regulations, and the Issuer\'s obligation to be registered with the Exchange in accordance with relevant procedures and pay service fees.';

  @override
  String get khurSystem => 'KHUR system';

  @override
  String registrationStepLabel(int num, String title) {
    return 'Step $num: $title';
  }

  @override
  String registrationProgress(String percent) {
    return 'Registration progress: $percent%';
  }

  @override
  String get registrationProgressText => 'Registration progress: ';

  @override
  String get start => 'Start';

  @override
  String get preparationWork => 'Preparation work';

  @override
  String get preparationDesc =>
      'You will be ready to trade after completing the following steps.';

  @override
  String get danSystem => 'DAN identification system';

  @override
  String get danSystemDesc => 'Information verification';

  @override
  String get addressInfo => 'Address information';

  @override
  String get addressInfoDesc => 'Your residential address';

  @override
  String get securitiesAgreement => 'Securities agreement';

  @override
  String get securitiesAgreementDesc => 'Read and agree to terms';

  @override
  String get document => 'Documents';

  @override
  String get depositSelectTitle => 'Select account to deposit';

  @override
  String get depositSelectSubtitle =>
      'Choose the account depending on whether you are buying stocks or bonds';

  @override
  String get mntAccounts => 'MNT accounts';

  @override
  String get usdAccounts => 'USD accounts';

  @override
  String get availableBalanceLabel => 'Available balance';

  @override
  String get bondDepositTitle => 'Deposit to bond account';

  @override
  String get depositInfoSubtitle =>
      'Please make the transfer using the details below.';

  @override
  String get receiverBank => 'Receiving bank';

  @override
  String get ibanAccountNo => 'IBAN account number';

  @override
  String get transferAmount => 'Transfer amount';

  @override
  String get transactionMemo => 'Transaction memo';

  @override
  String get copiedLabel => 'Copied';

  @override
  String get definitionRequestSubtitle =>
      'Choose the language and specify what the statement is for';

  @override
  String get purposeLabel => 'What is it for';

  @override
  String get purposeExample => 'e.g. Embassy of Japan';

  @override
  String get getDefinition => 'Get statement';

  @override
  String get definitionReceiveType => 'Statement delivery type';

  @override
  String get agreementReceiveType => 'Agreement delivery type';

  @override
  String get receiveTypeSubtitle =>
      'A 4-digit code will be sent to your chosen phone number or email.';

  @override
  String get directDownload => 'Direct download';

  @override
  String get downloadAsPdfLabel => 'Download as PDF';

  @override
  String get langMongolian => 'Mongolian';

  @override
  String get langEnglish => 'English';

  @override
  String get downloadPdf => 'Download PDF';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get termsOfService => 'Terms of service';

  @override
  String get securitiesStatement => 'Securities statement';

  @override
  String get securitiesStatementSubtitle => 'Securities you own';

  @override
  String get agreementLabel => 'Agreement';

  @override
  String get documentDesc => 'ID card, selfie photo';

  @override
  String get idFront => 'ID Card - Front';

  @override
  String get idBack => 'ID Card - Back';

  @override
  String get selfiePhoto => 'Selfie Photo';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get editPhoto => 'Edit Photo';

  @override
  String get photoRequirements => 'Photo Requirements';

  @override
  String get reqCorner => 'All 4 corners of the ID must be visible';

  @override
  String get reqValid => 'Use a valid document';

  @override
  String get reqClear => 'No blur or glare';

  @override
  String get reqReadable => 'Information must be clearly readable';

  @override
  String get sendPhoto => 'Send Photo';

  @override
  String get cameraInstructionId => 'Fit the document within the frame';

  @override
  String get cameraInstructionSelfie => 'Fit your face within the frame';

  @override
  String get readyToTrade => 'Ready to Trade';

  @override
  String get readyToTradeDesc =>
      'Let\'s start your investment journey together!';

  @override
  String get pepQuestion =>
      'Are you, a family member, or a close associate a Politically Exposed Person (PEP)?';

  @override
  String get pepDefinition => 'Who is a PEP?';

  @override
  String get pepDefinitionFull =>
      'A Politically Exposed Person (PEP) is defined as an individual who is or has been entrusted with a prominent public function. This includes:\n\nPresident of Mongolia, Members of Parliament, Prime Minister, Cabinet Members, Members of the Constitutional Court, Chief Justice and Judges of the Supreme Court, Prosecutor General, Heads of organizations directly accountable to Parliament, Governors of Aimags and the Capital city, Chairmen of Citizens\' Representative Khurals of Aimags and the Capital city, State Secretaries of Ministries, Heads of government agencies, and Heads/Directors of state-owned companies and international organizations.';

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get verify => 'Verify';

  @override
  String get newDeviceTitle => 'New device';

  @override
  String get newDeviceDesc =>
      'You are logging in from this device for the first time. To keep your account secure, please complete verification to continue.';

  @override
  String get danVerificationDesc =>
      'Verify your personal information using the system.';

  @override
  String get success => 'Success';

  @override
  String get myStocks => 'My Stocks';

  @override
  String get statistics => 'Statistics';

  @override
  String get totalProfit => 'Total Profit';

  @override
  String get realizedProfit => 'Realized Profit';

  @override
  String get unrealizedProfit => 'Unrealized Profit';

  @override
  String get futureReturn => 'Future Return';

  @override
  String get totalReturnReceived => 'Total Return Received';

  @override
  String get bondName => 'Bond Name';

  @override
  String get amountPieces => 'Amount | Pieces';

  @override
  String get profitPlusMinus => 'Profit (+ -)';

  @override
  String get historyAll => 'Total return';

  @override
  String get view => 'View';

  @override
  String get pieces => 'pieces';

  @override
  String get interestRateShort => 'Interest';

  @override
  String get incomeMethod => 'Income Method';

  @override
  String get incomeMethodDesc =>
      'You can buy bonds or stocks with your deposited money.';

  @override
  String get qpay => 'Qpay';

  @override
  String get qpayAndCard => 'Qpay and card';

  @override
  String get recommend => 'Recommend';

  @override
  String get enterAmount => 'Enter amount';

  @override
  String get makeIncome => 'Make Income';

  @override
  String get million => 'сая';

  @override
  String get incomeSuccess => 'Income completed';

  @override
  String get incomeSuccessDesc => 'You are ready to invest!';

  @override
  String get withdrawMethod => 'Withdraw Method';

  @override
  String get withdrawMethodDesc => 'Select an account to withdraw from';

  @override
  String get makeWithdraw => 'Withdraw';

  @override
  String get addAccountLabel => 'Add account';

  @override
  String get receiveAccount => 'Receiving account';

  @override
  String get withdrawAmountTitle => 'Withdrawal amount';

  @override
  String get withdrawSuccess => 'Withdrawal completed';

  @override
  String get withdrawSuccessDesc =>
      'Transactions are consolidated from multiple accounts, so please wait a moment.';

  @override
  String get bankTransfer => 'Bank Transfer';

  @override
  String get bankTransferDesc => 'Transfer to bank account';

  @override
  String get filter => 'Filter';

  @override
  String get filterAction => 'Filter';

  @override
  String get clearFilter => 'Clear';

  @override
  String get selectPeriod => 'Select period';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get last1MonthFilter => 'Last 1 month';

  @override
  String get last3Months => 'Last 3 months';

  @override
  String get last6Months => 'Last 6 months';

  @override
  String get selectDateRange => 'Select start and end date';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get cashSection => 'Cash';

  @override
  String get boughtType => 'Bought';

  @override
  String get soldType => 'Sold';

  @override
  String get bondReturnType => 'Bond return';

  @override
  String get stockTransferType => 'Stock transfer received';

  @override
  String get monthLabel => 'month';

  @override
  String get mandalCapital => 'Mandal Capital';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signIn => 'Sign In';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get registerContactPrefix =>
      'If you wish to register as an organization,';

  @override
  String get registerContactPostfix => ' please send your request to ';

  @override
  String approxUsd(String amount) {
    return '≈$amount\$';
  }

  @override
  String get educationTitle => 'Education';

  @override
  String get educationSubtitle =>
      'Growing your financial knowledge brings more freedom to your life.';

  @override
  String get eduCourseIntro => 'Introduction to investing';

  @override
  String get eduCourseBond => 'Bond course';

  @override
  String get eduCourseStock => 'Stock course';

  @override
  String get eduCourseFund => 'Investment fund course';

  @override
  String eduLessonProgress(int done, int total) {
    return '$done/$total';
  }

  @override
  String get appGuideTitle => 'App user guide';

  @override
  String get eduGeneralInfo => 'General information';

  @override
  String get eduGeneralInfoDesc => 'What every client should know';

  @override
  String get eduGeneral1 => 'Create an account and verify your identity';

  @override
  String get eduGeneral2 => 'Home page dashboard';

  @override
  String get eduGeneral3 => 'Portfolio: your assets and performance';

  @override
  String get eduTradingTitle => 'How to trade?';

  @override
  String get eduTradingDesc => 'Bond and stock trading';

  @override
  String get eduTrading1 => 'Buying bonds';

  @override
  String get eduTrading2 => 'Buying stocks';

  @override
  String get eduTrading3 => 'Market order vs Limit order';

  @override
  String get eduSecurityTitle => 'Security';

  @override
  String get eduSecurityDesc => 'How to protect your information?';

  @override
  String get eduSecurity1 => 'Investment risks';

  @override
  String get eduSecurity2 => 'Preventing fraud and protecting your account';

  @override
  String get eduSecurity3 =>
      'Protecting your account (PIN, biometrics, two-factor authentication)';

  @override
  String get viewMore => 'View more';

  @override
  String get searchByKeyword => 'Search by keyword';

  @override
  String get eduQuizLabel => 'Knowledge check';

  @override
  String eduNextCounter(int current, int total) {
    return 'Next $current/$total';
  }

  @override
  String get eduFinish => 'Finish';

  @override
  String get eduCorrectAnswer => 'Correct answer';

  @override
  String get eduCorrectDesc =>
      'Congratulations! You have completed this lesson.';

  @override
  String get eduWrongAnswer => 'Incorrect answer';

  @override
  String get eduWrongDesc =>
      'The lesson counts as completed only with a correct answer. Watch this lesson again?';

  @override
  String get eduRetryLesson => 'Watch lesson again';

  @override
  String get eduLater => 'Later';

  @override
  String eduCheckAnswer(int current, int total) {
    return 'Check answer $current/$total';
  }

  @override
  String get noBondsYet => 'You don\'t have any bonds yet';

  @override
  String get noStocksYet => 'You don\'t have any stocks yet';

  @override
  String get startInvestingPrompt => 'Ready to start investing?';

  @override
  String timesReceived(int cnt, int total) {
    return 'received $cnt/$total times';
  }

  @override
  String timesRemaining(int cnt, int total) {
    return '$cnt/$total times remaining';
  }

  @override
  String get error => 'Error';

  @override
  String get listUpdated => 'List updated';

  @override
  String get changed => 'Changed';

  @override
  String get hasError => 'Has error';

  @override
  String get childRegisterTitle => 'Enter your child\'s registration number';

  @override
  String get childRegisterDesc =>
      'Only a legal guardian can open a child\'s account.';

  @override
  String get childDocTitle => 'Upload a photo of the birth certificate';

  @override
  String get birthCertificate => 'Birth certificate';

  @override
  String get childSuccessDesc =>
      'We are reviewing your child\'s information — the trading account will open within 2 business days.';

  @override
  String get information => 'Information';

  @override
  String get noNotifications => 'No notifications at the moment.';

  @override
  String removeFromList(String name) {
    return 'Do you want to remove $name stock from your watchlist?';
  }

  @override
  String get holdAmount => 'Hold Amount';

  @override
  String get holdAmountDesc =>
      'The total amount ordered to purchase stocks and bonds is called the hold amount. If the order is not executed, the hold amount can be canceled to increase cash balance.';

  @override
  String get cashDesc =>
      'It refers to the total available cash amount that can be used to purchase securities such as stocks and bonds.';

  @override
  String get totalReturnReceivedInfo =>
      'Bond interest income you have earned in the past.';

  @override
  String get futureReturnInfo =>
      'Bond interest income you will earn in the future.';

  @override
  String get noActiveOrders => 'No active orders';

  @override
  String get noActiveOrdersDesc =>
      'To see completed or canceled orders, tap “Order History”';

  @override
  String get noHistoryFound => 'No history found';

  @override
  String get done => 'Done';

  @override
  String get canceled => 'Canceled';

  @override
  String get cancelAllOrders => 'Cancel all orders';

  @override
  String get dailyStockRate => 'Daily change';

  @override
  String get last1Year => 'Last 1 year';

  @override
  String get orderedDate => 'Ordered date';

  @override
  String get account => 'Account';

  @override
  String get exchangeRateGain => 'Exchange rate gain';

  @override
  String get bondsPiece => 'bonds';

  @override
  String get lastInterestPaymentDate => 'Last interest payment date';

  @override
  String get nominal => 'Nominal';

  @override
  String get csd => 'CSD';

  @override
  String get buyStock => 'Buy stock';

  @override
  String get totalYield => 'Total yield:';

  @override
  String get totalYieldGot => 'Total yield (got):';

  @override
  String get daysLeft => 'DAYS LEFT';

  @override
  String get totalPriceBreakdown => 'Total price breakdown';

  @override
  String get unitPriceExplanation => 'Unit price explanation';

  @override
  String get unitPriceFormula => 'Piece price + Accrued price = Unit price';

  @override
  String get piecePrice => 'Piece price';

  @override
  String get accruedInterest => 'Accrued interest';

  @override
  String get returnBack => 'Return';

  @override
  String get accruedInterestDescP1 =>
      'Interest on bonds accrues daily, but the payout schedule varies—such as monthly, quarterly, or semi-annually.';

  @override
  String get accruedInterestDescP2 =>
      'For example, suppose the bond you are looking to buy pays interest quarterly. However, what if there is only one month remaining until the next coupon payment date?';

  @override
  String get accruedInterestDescP3 =>
      'You cannot receive a full three months\' worth of interest when you have only held the bond for one month. Therefore, you must pay the seller the accrued interest for the two months during which you did not own the bond. Then, on the next coupon payment date—one month later—you will be entitled to receive the full three-month interest payment.';

  @override
  String get prevInterestPaidDate => 'Previous interest\n payment date';

  @override
  String get nextInterestPayDueDate => 'Next interest\n payment date';

  @override
  String get todayBondBuyDate => 'Today\n(Bond buy date)';

  @override
  String get accruedInterestToSeller => 'Accrued interest\n paid to seller';

  @override
  String get yourInterestToReceive => 'YOUR INTEREST TO RECEIVE';

  @override
  String get stockTradingNoPowerTitle =>
      'Please make a deposit into your business account';

  @override
  String get stockTradingNoPowerDesc =>
      'To buy domestic and international stocks, you first need to deposit funds into your trading account.';

  @override
  String get marketClosedNotifTitle => 'The market is closed';

  @override
  String marketClosedNotifDesc(String startDate, String endDate) {
    return 'Mongolian Stock Exchange trading hours are from $startDate to $endDate. You can only trade at market price during this period.';
  }

  @override
  String get understood => 'Understood';

  @override
  String get stockTradingMarketPriceNotify =>
      'Please note that the total amount of market orders may vary depending on the market price at execution.';

  @override
  String cancelAllOrdersDesc(int Number) {
    return 'You are about to cancel $Number active order(s). \n Do you wish to continue?';
  }

  @override
  String get yesContinue => 'Yes, continue';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get details => 'Details';

  @override
  String get primaryAccount => 'Primary Account';

  @override
  String get stockMoney => 'Stock money';

  @override
  String get bondMoney => 'Bond money';
}
