// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Mongolian (`mn`).
class AppLocalizationsMn extends AppLocalizations {
  AppLocalizationsMn([String locale = 'mn']) : super(locale);

  @override
  String get appTitle => 'Антигравити';

  @override
  String get login => 'Нэвтрэх';

  @override
  String get useAnotherAccount => 'Өөр хаяг ашиглах';

  @override
  String get loginErrorPhone => 'Утасны дугаар эсвэл нууц үг буруу байна.';

  @override
  String get loginErrorEmail => 'И-мэйл эсвэл нууц үг буруу байна.';

  @override
  String get connectionError => 'Алдаа гарлаа. Дахин оролдоно уу.';

  @override
  String get tryAgain => 'Дахин оролдох';

  @override
  String attemptsRemaining(Object count) {
    return 'Утасны дугаар эсвэл нууц үг буруу байна. \n$count удаагийн эрх үлдлээ.';
  }

  @override
  String attemptsRemainingEmail(Object count) {
    return 'И-мэйл эсвэл нууц үг буруу байна. \n$count удаагийн эрх үлдлээ.';
  }

  @override
  String get validationEmailRequired => 'И-мэйл оруулна уу';

  @override
  String get validationInvalidFormat => 'Бичиглэл буруу эсвэл дутуу байна';

  @override
  String get validationThisField => 'Энэ талбар';

  @override
  String validationRequired(Object field) {
    return '$field хоосон байна';
  }

  @override
  String get validationRegisterRequired => 'Регистрийн дугаар оруулна уу';

  @override
  String get validationRegisterInvalid => 'Регистрийн дугаар буруу байна';

  @override
  String get validationPhoneRequired => 'Утасны дугаар оруулна уу';

  @override
  String validationEnterField(Object field) {
    return '$field оруулна уу';
  }

  @override
  String validationLettersOnly(Object field) {
    return '$field зөвхөн үсэг байна';
  }

  @override
  String get phoneNumber => 'Утасны дугаар';

  @override
  String get email => 'И-мэйл';

  @override
  String get password => 'Нууц үг';

  @override
  String get forgotPassword => 'Нууц үг сэргээх?';

  @override
  String get register => 'Бүртгүүлэх';

  @override
  String get portfolio => 'Портфолио';

  @override
  String get bonds => 'Бонд';

  @override
  String get stocks => 'Хувьцаа';

  @override
  String get orders => 'Захиалга';

  @override
  String get totalBalance => 'Нийт үлдэгдэл';

  @override
  String get income => 'Орлого';

  @override
  String get expense => 'Зарлага';

  @override
  String get myAssets => 'Миний хөрөнгө';

  @override
  String get viewAll => 'Бүгдийг харах';

  @override
  String get mandalSavings => 'МАНДАЛ ХАДГАЛАМЖ';

  @override
  String get mySavings => 'Миний хадгаламж';

  @override
  String get finished => 'Дууссан';

  @override
  String get add => 'Нэмэх';

  @override
  String get searchByName => 'Нэрээр хайх';

  @override
  String get dividendPortfolio => 'Ногдол ашгийн багц';

  @override
  String get recommendedStocks => 'Санал болгох хувьцаанууд';

  @override
  String get viewPortfolio => 'Багц харах';

  @override
  String get all => 'Бүгд';

  @override
  String get ipo => 'IPO';

  @override
  String get gainers => 'Өсөлттэй';

  @override
  String get losers => 'Уналттай';

  @override
  String get market => 'Зах зээл үнэлгээ';

  @override
  String get orderActive => 'Арилжааны идэвхи';

  @override
  String get stock => 'Хувьцаа';

  @override
  String get saved => 'Хадгалсан';

  @override
  String get pieceOfStock => 'ширхэг хувьцаа';

  @override
  String get lastPrice24h => 'Сүүлийн ханш (24 цаг)';

  @override
  String get settings => 'Тохиргоо';

  @override
  String get theme => 'Загвар';

  @override
  String get language => 'Хэл';

  @override
  String get darkTheme => 'Харанхуй';

  @override
  String get lightTheme => 'Гэрэлтэй';

  @override
  String get activeOrders => 'Идэвхтэй захиалга';

  @override
  String get orderHistory => 'Захиалгын түүх';

  @override
  String get executionQuantity => 'Биелэлт/Ширхэг';

  @override
  String get unitPrice => 'Нэгж үнэ';

  @override
  String get sellingPrice => 'Зарах ханш';

  @override
  String get open => 'НЭЭЛТТЭЙ';

  @override
  String get closed => 'ХААЛТТАЙ';

  @override
  String get foreign => 'ГАДААД';

  @override
  String get buy => 'Авах';

  @override
  String get sell => 'Зарах';

  @override
  String get bond => 'Бонд';

  @override
  String get term => 'Хугацаа';

  @override
  String get yield => 'Өгөөж';

  @override
  String get balance => 'Дүн';

  @override
  String get orderUpdated => 'Захиалга шинэчлэгдлээ';

  @override
  String get totalAssets => 'Нийт хөрөнгө';

  @override
  String get last1Month => 'Сүүлийн 1 сар';

  @override
  String get history => 'Хуулга';

  @override
  String get assetBreakdown => 'Хөрөнгийн задаргаа';

  @override
  String get tugrik => 'Төгрөг';

  @override
  String get dollar => 'Доллар';

  @override
  String orderCount(String count) {
    return '$count Захиалга';
  }

  @override
  String get emailHint => 'И-мэйл хаягаа оруулна уу';

  @override
  String get phonePlaceholder => 'Утасны дугаар оруулах хэсэг';

  @override
  String get forgotPasswordBtn => 'Нууц үг мартсан?';

  @override
  String get noCompletedSavings => 'Дууссан хадгаламж байхгүй байна.';

  @override
  String get tenureLabel => 'Хугацаа';

  @override
  String get interestRate => 'Хүү';

  @override
  String get endDateLabel => 'Дуусах';

  @override
  String get uiComponentsShowcase => 'UI бүрэлдэхүүн хэсгүүд';

  @override
  String get uiComponentsSubtitle => 'Бүх боломжтой загваруудыг харах';

  @override
  String get themeColorsSubtitle => 'Дизайн системийн өнгөний палитр';

  @override
  String get personalInfo => 'Хувийн мэдээлэл';

  @override
  String get darkMode => 'Darkmode асаах';

  @override
  String get lightMode => 'Lightmode асаах';

  @override
  String get myInfo => 'Миний мэдээлэл';

  @override
  String get myInfoSubtitle => 'И-мэйл, Утасны дугаар, Хаяг';

  @override
  String get incomeAccount => 'Орлого авах данс';

  @override
  String get incomeAccountSubtitle => 'Голомт банк - MN650039008000110...';

  @override
  String get summaryReport => 'Хураангуй тайлан';

  @override
  String get summaryReportSubtitle => 'Сарын болон жилийн тайлан';

  @override
  String get childAccount => 'Хүүхдийн данс';

  @override
  String get createNewAccount => 'Шинэ данс үүсгэх';

  @override
  String get createNewAccountSubtitle => 'Ирээдүйдээ хөрөнгө оруулаарай';

  @override
  String get security => 'Аюулгүй байдал';

  @override
  String get biometric => 'Биометрик';

  @override
  String get inactive => 'Идэвхгүй';

  @override
  String get changePassword => 'Нууц үг солих';

  @override
  String get lastChanged => '2025.10.20-нд сольсон';

  @override
  String passwordChangedOn(Object date) {
    return '$date-нд сольсон';
  }

  @override
  String get connectedDevices => 'Холбогдсон төхөөрөмж';

  @override
  String get noConnectedDevices => 'Холбоотой төхөөрөмж байхгүй';

  @override
  String get devicesCount => '2 төхөөрөмж';

  @override
  String deviceCountLabel(Object count) {
    return '$count төхөөрөмж';
  }

  @override
  String get biometricFaceTitle => 'Царай таниулах уу';

  @override
  String get biometricFingerprintTitle => 'Хурууны хээ таниулах уу';

  @override
  String get biometricEnrollDesc =>
      'Ингэснээр та цаашид биометрик ашиглан хялбар нэвтрэх боломжтой болно.';

  @override
  String get biometricEnrollConfirm => 'Тэгье';

  @override
  String get skip => 'Алгасах';

  @override
  String get logout => 'Апп-с гарах';

  @override
  String get notifications => 'Мэдэгдэл';

  @override
  String get markAllAsRead => 'Бүгдийг уншсан';

  @override
  String get allNotifications => 'Бүгд';

  @override
  String get trading => 'Арилжаа';

  @override
  String get news => 'Мэдээ';

  @override
  String get others => 'Бусад';

  @override
  String get markAllReadTitle => 'Бүгдийг уншсан болгох';

  @override
  String get markAllReadDesc =>
      'Та бүх мэдэгдлийг уншсан төлөвт оруулж, улаан дугуй тэмдэгийг арилгах гэж байна уу?';

  @override
  String get confirm => 'Тийм, уншсан болгох';

  @override
  String get back => 'Буцах';

  @override
  String get notificationRelatedInfo => 'Холбогдох мэдээлэл';

  @override
  String get surname => 'Овог';

  @override
  String get firstName => 'Нэр';

  @override
  String get regNo => 'Регистрийн дугаар';

  @override
  String get address => 'Оршин суугаа хаяг';

  @override
  String get otherAccounts => 'Бусад данс';

  @override
  String get incomeAccBenefitPrompt =>
      'Таны арилжаанаас олсон ашгийг энэ данс руу шилжүүлэх юм шүү';

  @override
  String get addIncomeAccPrompt => 'Орлого авах данс оруулна уу';

  @override
  String get iban => 'IBAN дугаар';

  @override
  String get bank => 'Банк';

  @override
  String get receiver => 'Хүлээн авагч';

  @override
  String get receiverHint => 'Овог нэр гэсэн дарааллаар бичнэ';

  @override
  String get save => 'Хадгалах';

  @override
  String get saving => 'Хадгалж байна...';

  @override
  String get growth => 'Өсөлт';

  @override
  String get lastMonth => 'Сүүлийн 1 сар';

  @override
  String get cash => 'Бэлэн мөнгө';

  @override
  String get type => 'Төрөл';

  @override
  String get incomeExpense => 'Орлого/Зардал';

  @override
  String get incomeSalary => 'Орлого/Зарлага';

  @override
  String get stockProfit => 'Хувьцааны ашиг';

  @override
  String get interestIncome => 'Хүүгийн орлого';

  @override
  String get bondPrincipal => 'Бондын үндсэн төлбөр';

  @override
  String get dividendProfit => 'Ногдол ашиг';

  @override
  String get downloadReport => 'Тайлан татах';

  @override
  String get oneDay => '1С';

  @override
  String get threeDays => '3С';

  @override
  String get sixDays => '6С';

  @override
  String get oneYear => '1Ж';

  @override
  String get selectedPeriod => 'Сонгосон хугацаанд';

  @override
  String get connectedDevicesDesc =>
      'Таны Мандал Капитал апп-д холбогдсон төхөөрөмжийн жагсаалт. Танихгүй төхөөрөмж байвал устгана уу.';

  @override
  String get active => 'Идэвхтэй';

  @override
  String get date => 'Огноо';

  @override
  String get d1 => '1Х';

  @override
  String get d7 => '7Х';

  @override
  String get m1 => '1С';

  @override
  String get m3 => '3С';

  @override
  String get y1 => '1Ж';

  @override
  String get ipAddress => 'IP хаяг';

  @override
  String get remove => 'Устгах';

  @override
  String get logoutConfirmTitle => 'Апп-с гарах';

  @override
  String get logoutConfirmDesc => 'Та Мандал Капитал апп-с гарах гэж байна уу?';

  @override
  String get yesLogout => 'Тийм, гарах';

  @override
  String get selectVerifyChannel => 'Баталгаажуулах суваг сонгоно уу';

  @override
  String get verifyChannelPrompt =>
      '4 оронтой кодыг таны сонгосон утасны дугаар эсвэл и-мэйл рүү илгээх болно.';

  @override
  String get sms => 'SMS';

  @override
  String get emailLabel => 'И-мэйл';

  @override
  String get enterCodeTitle => '4 оронтой код оруулна уу';

  @override
  String codeSentTo(Object value) {
    return 'Таны $value дугаарт код илгээлээ.';
  }

  @override
  String get resendCode => 'Шинэ код авах';

  @override
  String get noCodeReceived => 'Код ирээгүй?';

  @override
  String get createNewPassword => 'Нууц үгээ зохионо уу';

  @override
  String get passwordHint => 'Нууц үг';

  @override
  String get repeatPasswordHint => 'Нууц үг давтах';

  @override
  String get atLeast8Chars => 'Багадаа 8 тэмдэгттэй байх';

  @override
  String get uppercaseLetter => 'Том үсэг (A-Z)';

  @override
  String get lowercaseLetter => 'Жижиг үсэг (a-z)';

  @override
  String get numberDigit => 'Тоон утга (0-9)';

  @override
  String get continueLabel => 'Үргэлжлүүлэх';

  @override
  String get incomeAccountDetail => 'Орлого авах данс';

  @override
  String get incomeAccountDetailDesc =>
      'Таны арижаанаас олсон ашигийг энэ данс руу шилжүүлэх юм шүү';

  @override
  String get ibanNumber => 'IBAN дугаар';

  @override
  String get accountChangedSuccess => 'Орлого авах данс өөрчлөгдлөө.';

  @override
  String get changeAccount => 'Данс өөрчлөх';

  @override
  String get setAsDefaultAccount => 'Орлого авдаг данс болгох';

  @override
  String get loginSubtitle => 'Өнөөдрийн шийдвэр, маргаашийн өгөөж';

  @override
  String get newToApp => 'Шинэ хэрэглэгч?';

  @override
  String get forgotPasswordTitle => 'Нууц үг сэргээх';

  @override
  String get forgotPasswordSubtitle => 'Бүртгэлтэй мэдээллээ оруулна уу';

  @override
  String get registrationNumber => 'Регистрийн дугаар';

  @override
  String get continueBtn => 'Үргэлжлүүлэх';

  @override
  String get registerTitle => 'Бүртгүүлэх';

  @override
  String get registerSubtitle => 'Та хувийн мэдээллээ оруулна уу';

  @override
  String get lastName => 'Овог';

  @override
  String get enterIncomeAccount => 'Орлого авах данс оруулна уу';

  @override
  String get enterIncomeAccountSubtitle =>
      'Таны арилжаанаас олсон ашигийг энэ данс руу шилжүүлэх юм шүү';

  @override
  String get bankName => 'Банк';

  @override
  String get recipientName => 'Хүлээн авагч';

  @override
  String get lastNameOrFirstNameNote => 'Овог нэр гэсэн дараалалаар бичнэ';

  @override
  String get registrationSuccess => 'Бүртгэл амжилттай';

  @override
  String get registrationSuccessMessage =>
      'Таны зорилго, бидний туршлага - итгэл, өгөөж, боломжоор дүүрэн байна гэдэгт итгэлтэй байна.';

  @override
  String get finish => 'Дуусгах';

  @override
  String get selectYourBank => 'Үнэт цаасны данс нээх хүрээмж';

  @override
  String get selectBankToContinue => 'Төлбөр шалгах';

  @override
  String get amountLabel => 'Дүн';

  @override
  String get lockedAmountLabel => 'Түгжигдсэн дүн';

  @override
  String get placeOrder => 'Захиалга өгөх';

  @override
  String get receivableAmountLabel => 'Хүлээн авах дүн';

  @override
  String get sellPriceDesc =>
      'Зарах ханш бага байх тусам таны захиалга хурдан биелэх магадлалтай.';

  @override
  String get swipeUpToConfirm => 'Дээш сөхөж баталгаажуулна уу';

  @override
  String get orderPlacedSuccess => 'ЗАХИАЛГА\nБҮРТГЭГДЛЭЭ';

  @override
  String get orderPlacedDesc =>
      'Захиалга биелж, хүү тооцогдож эхлэхэд бид танд мэдэгдэх болно.';

  @override
  String get viewOrders => 'Захиалга харах';

  @override
  String get sellOrderSuccessDesc =>
      'Зөвхөн хамгийн сайн зарах ханш бусад хөрөнгө оруулагч нарт харагдахыг анхаарна уу.';

  @override
  String get commissionLabel => 'Шимтгэл';

  @override
  String get ownedAmountLabel => 'Эзэмшиж буй дүн';

  @override
  String get pledgeBondDesc =>
      'Бондоо зарахгүйгээр санхүүгийн хэрэгцээгээ шийдээрэй.';

  @override
  String get pledge => 'Барьцаалах';

  @override
  String get newBond => 'Шинэ бонд';

  @override
  String get newBondDesc =>
      'Earn steady returns with our premium bond offerings. Start investing today.';

  @override
  String get watchlist => 'Хадгалсан';

  @override
  String get askingWatchlist => 'Watchlist үүсгэх үү?';

  @override
  String get watchlistDescription =>
      'Өөрийн сонирхсон хувьцааг хадгалж, ханшийг мэдээллийг цаг алдалгүй хурдан аваарай.';

  @override
  String get recommendationTitle => 'Та ямар бонд авахаа мэдэхгүй байна уу?';

  @override
  String get recommendationDesc =>
      'Тийм бол - Эрсдэл бага, өгөөж өндөр дараах бондуудыг танд санал болгож байна.';

  @override
  String get uploading => 'Илгээж байна';

  @override
  String get noData => 'Мэдээлэл байхгүй';

  @override
  String get addEmail => 'И-мэйл нэмэх';

  @override
  String get annualYield => 'Жилийн өгөөж';

  @override
  String get nextInterestPayDate => 'Дараагийн хүү төлөгдөх өдөр';

  @override
  String get bondMaturityDate => 'Бонд дуусах өдөр';

  @override
  String daysCount(Object days) {
    return '$days хоног';
  }

  @override
  String get tradePlannedDate => 'Арилжаа биелэх төлөвлөгөөт огноо';

  @override
  String get buyRate => 'Авах ханш';

  @override
  String get selectPledgeBond => 'Барьцаалах бонд сонгох';

  @override
  String get pledgeBondSelectDesc =>
      'Бондоо барьцаалаад, суллахдаа +6.0% хүү төлнө. Яг л банкны хадгаламж барьцаалсан зээл шиг.';

  @override
  String get pledgeQuantityLabel => 'Барьцаалах ширхэг';

  @override
  String availablePieces(Object count) {
    return 'Боломжит: $count ш';
  }

  @override
  String get receiveAmountLabel => 'Хүлээн авах дүн';

  @override
  String get noReportYet => 'Одоогоор тайлан үүсээгүй';

  @override
  String get reportPeriodTitle => 'Тайлан хураангуй татах хугацаа сонгоно уу';

  @override
  String get periodOneMonth => '1 сар';

  @override
  String get periodThreeMonths => '3 сар';

  @override
  String get periodSixMonths => '6 сар';

  @override
  String get periodTwelveMonths => '12 сар';

  @override
  String get allTimeReport => 'Бүх цаг үеийн тайлан';

  @override
  String get emptyWatchlist => 'Хадгалсан хувьцаа байхгүй';

  @override
  String get emptyWatchlistHint => 'Та + товчоор хувьцаа нэмээрэй';

  @override
  String resultsCount(Object count) {
    return '$count илэрц';
  }

  @override
  String get noResults => 'Илэрц байхгүй';

  @override
  String get noResultsHint => 'Та түлхүүр үгээ өөрчлөөд үзээрэй';

  @override
  String get sorryTitle => 'Уучлаарай';

  @override
  String get noPledgeBondDesc =>
      'Танд одоогоор барьцаалах боломжит бонд байхгүй байна.';

  @override
  String get requestSent => 'ХҮСЭЛТ ИЛГЭЭЛЭЭ';

  @override
  String requestSentDesc(Object phone) {
    return 'Манай брокер тун удахгүй таны $phone дугаарт холбогдох болно.';
  }

  @override
  String get closedBondInfoTitle => 'Хаалттай бонд';

  @override
  String get closedBondInfoDesc =>
      'Хадгаламжтай адил буюу 10%-ийн хүүгийн орлогын татвартай, биржийн бус захд арилжаалагддаг бонд.';

  @override
  String get openBondInfoTitle => 'Нээлттэй бонд';

  @override
  String get openBondInfoDesc =>
      'Биржээр нээлттэй арилжаалагддаг, хүссэн үедээ худалдах, худалдан авах боломжтой бонд.';

  @override
  String get foreignBondInfoTitle => 'Гадаад бонд';

  @override
  String get foreignBondInfoDesc =>
      'Гадаад валютаар, олон улсын зах зээл дээр арилжаалагддаг бонд.';

  @override
  String get close => 'Хаах';

  @override
  String get stockRecommendationTitle => 'Санал болгох хувьцаа';

  @override
  String get stockRecommendationDesc =>
      'Хамгийн их арилжааны дүнтэй хувьцаануудыг санал болгож байна.';

  @override
  String get sellBond => 'Бонд зарах';

  @override
  String get mandalBond => 'МАНДАЛ БОНД';

  @override
  String get primaryMarket => 'Анхдагч арилжаа';

  @override
  String get secondaryMarket => 'Хоёрдогч арилжаа';

  @override
  String get myBond => 'Миний бонд';

  @override
  String get pledgeBond => 'Бонд барьцаалах';

  @override
  String get bondCollectionTarget => 'Цуглуулах дүн';

  @override
  String get annualInterest => 'Жилийн хүү';

  @override
  String get paymentFrequency => 'Хүү төлөх давтамж';

  @override
  String get availableCash => 'Бэлэн мөнгө';

  @override
  String get buyQuantity => 'Авах ширхэг';

  @override
  String get availableQuantity => 'Боломжит';

  @override
  String get totalPayment => 'Нийт төлөх дүн';

  @override
  String get totalReturn => 'Нийт өгөөж';

  @override
  String get lockedAmount => 'Түгжигдсэн дүн';

  @override
  String get release => 'Суллах';

  @override
  String get orderRegistered => 'ЗАХИАЛГА БҮРТГЭГДЛЭЭ';

  @override
  String get sellPrice => 'Зарах ханш';

  @override
  String get executionProbability => 'Биелэх магадлал';

  @override
  String get orderBoard => 'Захиалгийн самбар';

  @override
  String get high => 'Өндөр';

  @override
  String get medium => 'Дунд';

  @override
  String get low => 'Бага';

  @override
  String get bondClosingDateLabel => 'Хаалтын огноо';

  @override
  String get viewBondPresentation => 'Бондын танилцуулга үзэх';

  @override
  String get buyBond => 'Бонд авах';

  @override
  String get availableAmountLabel => 'Боломжит дүн';

  @override
  String get costLabel => 'Зээлийн хүү';

  @override
  String get quantityLabel => 'Ширхэг';

  @override
  String get tradeAmount => 'Арилжааны дүн';

  @override
  String get orderTypeLabel => 'Төрөл';

  @override
  String get orderStatusLabel => 'Төлөв';

  @override
  String get yieldLabel => 'Өгөөж';

  @override
  String get settlementDate => 'Төлбөр тооцоо хийгдэх';

  @override
  String get orderDate => 'Захиалга оруулсан';

  @override
  String get executionHistory => 'Биелэлтийн түүх';

  @override
  String get executedQuantity => 'Биелсэн ширхэг';

  @override
  String get partiallyFilled => 'Хэсэгчлэн биелсэн';

  @override
  String get limitPrice => 'Нөхцөлт үнэ';

  @override
  String get generalInfo => 'Ерөнхий мэдээлэл';

  @override
  String get marketCap => 'Нийт зах зээлийн үнэлгээ';

  @override
  String get avgVolume => 'Дундаж арилжааны хэмжээ';

  @override
  String get dividendYield => 'Ногдол ашгийн хувь';

  @override
  String get dailyVolume => 'Өдрийн арилжааны хэмжээ';

  @override
  String get pastDividends => 'Өнгөрсөн хугацаанд олгосон ногдол ашиг';

  @override
  String get trade => 'Арилжаа хийх';

  @override
  String get billion => 'тэрбум';

  @override
  String get today => 'Өнөөдөр';

  @override
  String get stockTrading => 'Хувьцаа арилжих';

  @override
  String get paste => 'Paste';

  @override
  String get buyTab => 'Авах';

  @override
  String get sellTab => 'Зарах';

  @override
  String get totalPaymentLabel => 'Нийт төлөх дүн';

  @override
  String get totalReceivableLabel => 'Нийт хүлээн авах дүн';

  @override
  String get orderBoardTitle => 'Захиалгийн самбар';

  @override
  String get buyAmount => 'Авах';

  @override
  String get sellAmount => 'Зарах';

  @override
  String get releaseLockedTitle => 'Түгжигдсэн дүн суллах';

  @override
  String get releaseLockedSubtitle =>
      'Та идэвхтэй захиалгаа цуцлаж (түгжигдсэн дүнг) бэлэн мөнгөө ихэсгэх боломжтой.';

  @override
  String get cancelOrder => 'Захиалга цуцлах';

  @override
  String get acceptTerms => 'Гэрээний нөхцөлийг хүлээн зөвшөөрч байна';

  @override
  String get agree => 'Зөвшөөрөх';

  @override
  String get agreed => 'Зөвшөөрсөн';

  @override
  String get securitiesAgreementContent =>
      'Энэхүү гэрээг нэг талаас \"Монголын Хөрөнгийн Бирж\" ТӨХК /цаашид Бирж гэх/, түүнийг төлөөлж................................................, нөгөө талаас “................................................” ХК /цаашид Үнэт цаас гаргагч, хамтад нь Талууд гэх/-ийг төлөөлж ............................................ нар дараах нөхцөлийг харилцан тохиролцож байгуулав.\n\n1.1 Энэхүү гэрээгээр Бирж нь Үнэт цаас гаргагч, түүний гаргасан үнэт цаасыг бүртгэх, үнэт цаасны арилжааг зохион байгуулах ажиллагааг зохих дүрэм, журмын дагуу хийж гүйцэтгэх, Үнэт цаас гаргагч нь холбогдох журмын дагуу Биржид бүртгэлтэй байх хугацаандаа зохих үүргийг хүлээх, үйлчилгээний төлбөр төлөхтэй холбогдон үүсэх харилцаанд талуудын эдлэх эрх, хүлээх үүрэг, хариуцлагыг тодорхойлно.';

  @override
  String get khurSystem => 'ХУР систем';

  @override
  String registrationStepLabel(int num, String title) {
    return 'Алхам $num: $title';
  }

  @override
  String registrationProgress(String percent) {
    return 'Бүртгэлийн явц: ';
  }

  @override
  String get registrationProgressText => 'Бүртгэлийн явц: ';

  @override
  String get start => 'Эхлэх';

  @override
  String get preparationWork => 'Бэлтгэл ажил';

  @override
  String get preparationDesc =>
      'Та доорх алхмуудыг гүйцэтгэсний дараа арилжаа хийхэд бэлэн болно.';

  @override
  String get danSystem => 'ДАН танилт систем';

  @override
  String get danSystemDesc => 'Мэдээлэл баталгаажуулах';

  @override
  String get addressInfo => 'Хаягийн мэдээлэл';

  @override
  String get addressInfoDesc => 'Таны оршин суугаа хаяг';

  @override
  String get securitiesAgreement => 'Үнэт цаасны гэрээ';

  @override
  String get securitiesAgreementDesc => 'Гэрээтэй уншиж танилцах';

  @override
  String get document => 'Бичиг баримт';

  @override
  String get currencyLabel => 'Валют';

  @override
  String get termsOfService => 'Үйлчилгээний нөхцөл';

  @override
  String get securitiesStatement => 'Үнэт цаасны тодорхойлолт';

  @override
  String get securitiesStatementSubtitle => 'Эзэмшиж буй үнэт цаас';

  @override
  String get agreementLabel => 'Гэрээ';

  @override
  String get documentDesc => 'Иргэний үнэмлэх, селфи зураг';

  @override
  String get idFront => 'Иргэний үнэмлэх - Урд тал';

  @override
  String get idBack => 'Иргэний үнэмлэх - Ард тал';

  @override
  String get selfiePhoto => 'Селфье зураг';

  @override
  String get addPhoto => 'Зураг оруулах';

  @override
  String get editPhoto => 'Зураг засах';

  @override
  String get photoRequirements => 'Зургийн шаардлага';

  @override
  String get reqCorner => 'Үнэмлэхийн 4 булан бүтэн орсон байх';

  @override
  String get reqValid => 'Хүчин төгөлдөр бичиг баримт ашиглах';

  @override
  String get reqClear => 'Бүрсгэр эсвэл гялбаагүй байх';

  @override
  String get reqReadable => 'Мэдээлэл тод уншигдахуйц байх';

  @override
  String get sendPhoto => 'Зураг илгээх';

  @override
  String get cameraInstructionId => 'Доорх хэлбэрт зургийг багтаана уу';

  @override
  String get cameraInstructionSelfie => 'Нүүрээ доорх хэлбэрт багтаана уу';

  @override
  String get readyToTrade => 'Арилжаа хийхэд бэлэн боллоо';

  @override
  String get readyToTradeDesc =>
      'Хөрөнгө оруулалтын урт аялалаа хамдаа эхлүүлцгээе!';

  @override
  String get pepQuestion =>
      'Та, таны гэр бүлийн гишүүн эсвэл ойрын хүрээний хүн улс төрд нөлөө бүхий этгээд үү?';

  @override
  String get pepDefinition => 'УТНБЭ гэж хэн бэ?';

  @override
  String get pepDefinitionFull =>
      'Улс төрд нөлөө бүхий этгээд гэж дараах ажил албан тушаалыг хашиж байсан хүнийг ойлгоно. Үүнд:\n\nМонгол Улсын Ерөнхийлөгч, Улсын Их Хурлын гишүүн, Монгол Улсын Ерөнхий сайд, Засгийн газрын гишүүн, Үндсэн Хуулийн цэцийн гишүүн, Улсын дээд шүүхийн Ерөнхий шүүгч, Улсын дээд шүүхийн шүүгч, Улсын ерөнхий прокурор, Улсын Их Хуралд ажлаа шууд хариуцан тайлагнадаг байгууллагын дарга, Аймаг, нийслэлийн Засаг дарга, Аймаг, нийслэлийн иргэдийн Төлөөлөгчдийн Хурлын Тэргүүлэгчдийн дарга, Яамны Төрийн нарийн бичгийн дарга, Засгийн газрын агентлагийн дарга, Төрийн өмчит компани, олон улсын байгууллагын дарга, захирлын албан тушаал эрхэлж байсан болон эрхэлж байгаа хүн.';

  @override
  String get no => 'Үгүй';

  @override
  String get yes => 'Тийм';

  @override
  String get verify => 'Баталгаажуулах';

  @override
  String get newDeviceTitle => 'Шинэ төхөөрөмж';

  @override
  String get newDeviceDesc =>
      'Та энэ төхөөрөмжөөс анх удаа нэвтэрч байна. Мэдээллийн аюулгүй байдлыг хангаж баталгаажуулалт хийж үргэлжлүүлээрэй.';

  @override
  String get danVerificationDesc =>
      'Систем ашиглан өөрийн хувийн мэдээллээ баталгаажуулаарай.';

  @override
  String get success => 'Амжилттай';

  @override
  String get myStocks => 'Миний хувьцаа';

  @override
  String get statistics => 'Статистик';

  @override
  String get totalProfit => 'Нийт ашиг';

  @override
  String get realizedProfit => 'Хэрэгжсэн ашиг';

  @override
  String get unrealizedProfit => 'Хэрэгжээгүй ашиг';

  @override
  String get futureReturn => 'Ирээдүйд авах өгөөж';

  @override
  String get totalReturnReceived => 'Нийт авсан өгөөж';

  @override
  String get bondName => 'Бонд нэр';

  @override
  String get amountPieces => 'Дүн | ширхэг';

  @override
  String get profitPlusMinus => 'Ашиг (+ -)';

  @override
  String get historyAll => 'Нийлбэр өгөөж';

  @override
  String get view => 'Харах';

  @override
  String get pieces => 'ш';

  @override
  String get interestRateShort => 'Хүү';

  @override
  String get incomeMethod => 'Орлогын хэлбэр';

  @override
  String get incomeMethodDesc =>
      'Та орлого хийсэн мөнгөөрөө бонд эсвэл хувьцаа худалдан авах боломжтой.';

  @override
  String get qpay => 'Qpay';

  @override
  String get qpayAndCard => 'Qpay болон картаар';

  @override
  String get recommend => 'Санал болгох';

  @override
  String get enterAmount => 'Дүн оруулна уу';

  @override
  String get makeIncome => 'Орлого хийх';

  @override
  String get million => 'сая';

  @override
  String get incomeSuccess => 'Орлого хийгдлээ';

  @override
  String get incomeSuccessDesc => 'Та хөрөнгө оруулахад бэлэн боллоо!';

  @override
  String get withdrawMethod => 'Зарлагын хэлбэр';

  @override
  String get withdrawMethodDesc => 'Татан авалт хийх данс сонгоно уу';

  @override
  String get makeWithdraw => 'Зарлага гаргах';

  @override
  String get addAccountLabel => 'Данс нэмэх';

  @override
  String get receiveAccount => 'Хүлээн авах данс';

  @override
  String get withdrawAmountTitle => 'Зарлага гаргах дүн';

  @override
  String get withdrawSuccess => 'Зарлага хийгдлээ';

  @override
  String get withdrawSuccessDesc =>
      'Олон өөр данснаас нэгтгэж гүйлгээ хийгддэг учраас та түр хүлээж байгаарай.';

  @override
  String get bankTransfer => 'Банкны шилжүүлэг';

  @override
  String get bankTransferDesc => 'Банкны данс руу шилжүүлэх';

  @override
  String get filter => 'Шүүлтүүр';

  @override
  String get filterAction => 'Шүүх';

  @override
  String get clearFilter => 'Цэвэрлэх';

  @override
  String get selectPeriod => 'Хугацаа сонгоно уу';

  @override
  String get last7Days => 'Сүүлийн 7 хоног';

  @override
  String get last1MonthFilter => 'Сүүлийн 1 сар';

  @override
  String get last3Months => 'Сүүлийн 3 сар';

  @override
  String get last6Months => 'Сүүлийн 6 сар';

  @override
  String get selectDateRange => 'Эхлэх дуусах огноо сонгох';

  @override
  String get startDate => 'Эхлэх огноо';

  @override
  String get endDate => 'Дуусах огноо';

  @override
  String get cashSection => 'Бэлэн мөнгө';

  @override
  String get boughtType => 'Авсан';

  @override
  String get soldType => 'Зарсан';

  @override
  String get bondReturnType => 'Бондын өгөөж';

  @override
  String get stockTransferType => 'Хувьцаа шилжүүлэн авсан';

  @override
  String get monthLabel => 'сар';

  @override
  String get mandalCapital => 'Мандал Капитал';

  @override
  String get signUp => 'Бүртгүүлэх';

  @override
  String get signIn => 'Нэвтрэх';

  @override
  String get alreadyHaveAccount => 'Надад хаяг байгаа?';

  @override
  String get registerContactPrefix => 'Та байгууллагаар бүртгүүлэх бол ';

  @override
  String get registerContactPostfix => ' хаягт хүсэлтээ илгээнэ үү.';

  @override
  String approxUsd(String amount) {
    return '≈$amount\$';
  }

  @override
  String get educationTitle => 'Боловсрол';

  @override
  String get educationSubtitle =>
      'Санхүүгийн мэдлэгээ нэмэх нь таны амьдралд илүү эрх чөлөө авчирна.';

  @override
  String get eduCourseIntro => 'Хөрөнгө оруулалтын ухаанд нэвтрэхүй';

  @override
  String get eduCourseBond => 'Бондын хичээл';

  @override
  String get eduCourseStock => 'Хувьцааны хичээл';

  @override
  String get eduCourseFund => 'Хөрөнгийн оруулалтын сангийн тухай хичээл';

  @override
  String eduLessonProgress(int done, int total) {
    return '$done/$total';
  }

  @override
  String get appGuideTitle => 'Апп ашиглах заавар';

  @override
  String get eduGeneralInfo => 'Ерөнхий мэдээлэл';

  @override
  String get eduGeneralInfoDesc => 'Харилцагч мэдэх ёстой зүйлс';

  @override
  String get eduGeneral1 => 'Бүртгэл үүсгэх, хувийн мэдээлэл баталгаажуулах';

  @override
  String get eduGeneral2 => 'Нүүр хуудасны хяналтын самбар';

  @override
  String get eduGeneral3 => 'Портфолио: эзэмшиж буй хөрөнгө, гүйцэтгэл';

  @override
  String get eduTradingTitle => 'Арилжаа хэрхэн хийх вэ?';

  @override
  String get eduTradingDesc => 'Бонд болон хувьцааны арилжаа';

  @override
  String get eduTrading1 => 'Бонд худалдан авах';

  @override
  String get eduTrading2 => 'Хувьцаа худалдан авах';

  @override
  String get eduTrading3 => 'Зах зээлийн захиалга vs Хязгаарласан захиалга';

  @override
  String get eduSecurityTitle => 'Аюулгүй байдал';

  @override
  String get eduSecurityDesc => 'Мэдээллээ хэрхэн хамгаалах вэ?';

  @override
  String get eduSecurity1 => 'Хөрөнгө оруулалтын эрсдэл';

  @override
  String get eduSecurity2 => 'Луйвраас сэргийлэх, данс хамгаалах';

  @override
  String get eduSecurity3 =>
      'Акаунтаа хамгаалах (PIN, биометрик, 2 шатлалтай баталгаажуулалт)';

  @override
  String get viewMore => 'Цааш үзэх';

  @override
  String get searchByKeyword => 'Түлхүүр үгээр хайх';

  @override
  String get eduQuizLabel => 'Мэдлэг шалгах тест';

  @override
  String eduNextCounter(int current, int total) {
    return 'Дараах $current/$total';
  }

  @override
  String get eduFinish => 'Дуусгах';

  @override
  String get eduCorrectAnswer => 'Зөв хариулт';

  @override
  String get eduCorrectDesc => 'Баяр хүргэе! Та энэ хичээлийг үзэж дууслаа.';

  @override
  String get eduWrongAnswer => 'Хариулт буруу';

  @override
  String get eduWrongDesc =>
      'Зөв хариулсан тохиолдолд хичээлийг үзсэнд тооцно. Энэ хичээлийг дахиад үзэх үү?';

  @override
  String get eduRetryLesson => 'Хичээл дахин үзэх';

  @override
  String get eduLater => 'Дараа болох';

  @override
  String eduCheckAnswer(int current, int total) {
    return 'Хариулт шалгах $current/$total';
  }

  @override
  String get noBondsYet => 'Танд бонд байхгүй байна';

  @override
  String get noStocksYet => 'Танд хувьцаа байхгүй байна';

  @override
  String get startInvestingPrompt => 'Хөрөнгө оруулалт хийж эхлэх үү?';

  @override
  String timesReceived(int cnt, int total) {
    return '$cnt/$total удаа авсан';
  }

  @override
  String timesRemaining(int cnt, int total) {
    return '$cnt/$total удаа үлдсэн';
  }

  @override
  String get error => 'Алдаа';

  @override
  String get listUpdated => 'Жагсаалт шинэчлэгдлээ';

  @override
  String get changed => 'Өөрчлөгдлөө';

  @override
  String get hasError => 'Алдаатай';

  @override
  String get childRegisterTitle => 'Хүүхдийнхээ регистрийн дугаарыг оруулна уу';

  @override
  String get childRegisterDesc =>
      'Хүүхдийн дансыг зөвхөн хууль ёсны асран хамгаалагч нь нээх боломжтой шүү.';

  @override
  String get childDocTitle => 'Төрсний гэрчилгээний зураг оруулна уу';

  @override
  String get birthCertificate => 'Төрсний гэрчилгээ';

  @override
  String get childSuccessDesc =>
      'Таны хүүхдийн мэдээллийг шалгаж байх ажлын 2 өдөр дотор арилжааны данс нээгдэх болно.';

  @override
  String get information => 'Мэдээлэл';

  @override
  String get noNotifications => 'Одоогоор мэдэгдэл байхгүй.';

  @override
  String removeFromList(String name) {
    return '$name хувьцааг хадгалсан жагсаалтаас хасах уу?';
  }

  @override
  String get holdAmount => 'Түгжигдсэн дүн';

  @override
  String get holdAmountDesc =>
      'Хувьцаа болон бонд худалдан авахаар захиалга өгсөн нийт дүнг түгжигдсэн дүн гэнэ. Захиалга биелээгүй үед түгжигдсэн дүнг цуцлаж бэлэн мөнгө ихэсгэх боломжтой.';

  @override
  String get cashDesc =>
      'Хувьцаа болон бонд зэрэг үнэт цаас худалдан авахад ашиглаж болох нийт боломжит мөнгөн дүнг хэлнэ.';

  @override
  String get totalReturnReceivedInfo =>
      'Таны өнгөрсөн хугацаанд олсон бондын хүүгийн орлого';

  @override
  String get futureReturnInfo => 'Таны ирээдүйд олох бондын хүүгийн орлого.';

  @override
  String get noActiveOrders => 'Идэвхтэй захиалга байхгүй';

  @override
  String get noActiveOrdersDesc =>
      'Биелсэн эсвэл цуцалсан захиалга харах бол “Захиалгийн түүх” дээр дарна уу';

  @override
  String get noHistoryFound => 'Түүх олдсонгүй';

  @override
  String get done => 'Биелсэн';

  @override
  String get canceled => 'Цуцалсан';

  @override
  String get cancelAllOrders => 'Бүх захиалгыг цуцлах';

  @override
  String get dailyStockRate => 'Өдрийн ханш';

  @override
  String get last1Year => 'Сүүлийн 1 жил';

  @override
  String get orderedDate => 'Захиалга өгсөн огноо';

  @override
  String get account => 'Данс';

  @override
  String get exchangeRateGain => 'Ханшийн ашиг';

  @override
  String get bondsPiece => 'ш';

  @override
  String get lastInterestPaymentDate => 'Сүүлд хүү төлөгдсөн өдөр';

  @override
  String get nominal => 'Номинал';

  @override
  String get csd => 'ҮЦТХТ';
}
