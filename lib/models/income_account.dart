/// /user/acnts-ийн нэг данс
class IncomeAccount {
  final String accountNumber; // TXNACNTNO (IBAN)
  final String accountName; // TXNACNTNAME (эзэмшигч)
  final String bankCode; // TXNBANKNO ("04")
  final String bankName; // BANKNAME (монгол)
  final String bankName2; // BANKNAME2 (англи)
  final bool isPrimary; // ISPRIMARY == "1"
  final String curCode; // CURCODE ("MNT" | "USD")

  const IncomeAccount({
    required this.accountNumber,
    required this.accountName,
    required this.bankCode,
    required this.bankName,
    required this.bankName2,
    required this.isPrimary,
    this.curCode = '',
  });

  factory IncomeAccount.fromJson(Map<String, dynamic> json) => IncomeAccount(
        accountNumber: json['TXNACNTNO']?.toString() ?? '',
        accountName: json['TXNACNTNAME']?.toString() ?? '',
        bankCode: json['TXNBANKNO']?.toString() ?? '',
        bankName: json['BANKNAME']?.toString() ?? '',
        bankName2: json['BANKNAME2']?.toString() ?? '',
        isPrimary: json['ISPRIMARY']?.toString() == '1',
        curCode: json['CURCODE']?.toString() ?? '',
      );

  /// Locale-ийн дагуу банкны нэр (аль нь хоосон бол нөгөөгөөр нөхнө)
  String localizedBankName(String languageCode) {
    final preferred = languageCode == 'en' ? bankName2 : bankName;
    return preferred.isNotEmpty ? preferred : bankName;
  }
}
