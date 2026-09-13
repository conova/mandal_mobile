/// E-Mongolia-аас татагдаж сервер дээр хадгалагдсан хүүхдийн мэдээлэл
/// (`/user/childs`-ийн нэг мөр).
class ChildInfo {
  final int id;
  final String firstName;
  final String lastName;
  final String registerNumber;

  const ChildInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.registerNumber,
  });

  factory ChildInfo.fromJson(Map<String, dynamic> json) => ChildInfo(
        id: (json['id'] as num?)?.toInt() ?? 0,
        firstName: json['firstName']?.toString() ?? '',
        lastName: json['lastName']?.toString() ?? '',
        registerNumber: json['registerNumber']?.toString() ?? '',
      );

  /// Жагсаалтад харуулах бүтэн нэр (овог + нэр)
  String get fullName => '$lastName $firstName'.trim();

  /// Avatar-т харуулах эхний үсэг
  String get initial =>
      firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';
}
