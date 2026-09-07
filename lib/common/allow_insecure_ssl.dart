// SSL сертификатын шалгалтыг унтраах (зөвхөн dev/debug зориулалт).
// Web дээр dart:io байхгүй тул stub хувилбар ашиглагдана.
export 'allow_insecure_ssl_stub.dart'
    if (dart.library.io) 'allow_insecure_ssl_io.dart';
