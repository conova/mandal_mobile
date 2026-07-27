/// /user/info-ийн `subAcnts` мөр — бүртгэлтэй хүүхдийн (дэд) данс.
class SubAccount {
  final String custId;
  final String relTypeName; // ХҮҮ / ОХИН
  final String relTypeName2; // SON / DAUGHTER
  final String firstName;
  final String lastName;
  final String firstName2;
  final String lastName2;

  /// Регистрийн дугаар (ID1)
  final String register;

  final String phone;
  final String email;
  final String address;
  final double amount;

  const SubAccount({
    required this.custId,
    required this.relTypeName,
    required this.relTypeName2,
    required this.firstName,
    required this.lastName,
    required this.firstName2,
    required this.lastName2,
    required this.register,
    required this.phone,
    required this.email,
    required this.address,
    required this.amount,
  });

  factory SubAccount.fromJson(Map<String, dynamic> json) {
    String str(String key) => json[key]?.toString() ?? '';
    return SubAccount(
      custId: str('CUSTID'),
      relTypeName: str('RELTYPENAME'),
      relTypeName2: str('RELTYPENAME2'),
      firstName: str('FIRSTNAME'),
      lastName: str('LASTNAME'),
      firstName2: str('FIRSTNAME2'),
      lastName2: str('LASTNAME2'),
      register: str('ID1'),
      phone: str('HANDPHONE'),
      email: str('EMAIL'),
      address: str('ADDRESS'),
      amount: double.tryParse(str('AMOUNT').replaceAll(',', '')) ?? 0,
    );
  }

  static List<SubAccount> listFromJson(List rows) => rows
      .whereType<Map>()
      .map((e) => SubAccount.fromJson(Map<String, dynamic>.from(e)))
      .toList();

  /// Хэлээс хамааран нэр (en үед латин нэр байвал түүнийг)
  String nameOf(String lang) =>
      lang != 'mn' && firstName2.isNotEmpty ? firstName2 : firstName;

  /// Аватар дээр харуулах эхний үсэг
  String get initial => firstName.isEmpty ? '?' : firstName[0].toUpperCase();
}
