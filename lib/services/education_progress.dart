import 'package:shared_preferences/shared_preferences.dart';

import '../models/education_guide.dart';

/// Боловсролын хичээлийн үр дүнг төхөөрөмж дээр хадгална.
///
/// Дуусгасан сэдвүүд `courseId/lessonId` хэлбэрээр
/// shared_preferences-д хадгалагдана.
class EducationProgress {
  static const _key = 'edu_completed_lessons';

  static String _entry(String courseId, String lessonId) =>
      '$courseId/$lessonId';

  /// Дуусгасан бүх сэдвийн олонлог
  static Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? const []).toSet();
  }

  /// Сэдвийг дуусгасанд тооцож хадгална
  static Future<void> markCompleted(String courseId, String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    final set = (prefs.getStringList(_key) ?? const []).toSet();
    set.add(_entry(courseId, lessonId));
    await prefs.setStringList(_key, set.toList());
  }

  static bool isCompleted(
    Set<String> completed,
    String courseId,
    String lessonId,
  ) =>
      completed.contains(_entry(courseId, lessonId));

  /// Тухайн хичээлээс хэдэн сэдэв дуусгасныг тоолно
  static int completedCount(Set<String> completed, EducationCourse course) =>
      course.lessons
          .where((l) => completed.contains(_entry(course.id, l.id)))
          .length;
}
