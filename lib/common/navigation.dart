import 'package:flutter/widgets.dart';

/// Back / хаах товчинд зориулсан аюулгүй pop:
///   • тухайн route аль хэдийн хаагдаж байвал (хурдан олон дарсан) юу ч
///     хийхгүй — эс бөгөөс доод дэлгэцийг ч хааж, stack хоосорч хар
///     дэлгэц гарна
///   • maybePop — stack-ийн сүүлийн route-ыг хэзээ ч хаахгүй, PopScope-ийг
///     хүндэтгэнэ
void safePop<T extends Object?>(BuildContext context, [T? result]) {
  final route = ModalRoute.of(context);
  if (route != null && !route.isCurrent) return;
  Navigator.of(context).maybePop<T>(result);
}
