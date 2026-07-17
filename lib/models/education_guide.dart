import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Боловсролын дэлгэцийн бүх дата — `assets/data/education_guide.json`.
///
/// Текстүүд монгол/англи хоёр хэл дээр хадгалагдах бөгөөд
/// `*Of(lang)` getter-үүдээр тухайн хэлний утгыг авна.
class EducationGuideData {
  final List<EducationCourse> courses;
  final List<GuideSection> sections;

  const EducationGuideData({required this.courses, required this.sections});

  factory EducationGuideData.fromJson(Map<String, dynamic> json) {
    return EducationGuideData(
      courses: (json['courses'] as List? ?? [])
          .map((e) => EducationCourse.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      sections: (json['sections'] as List? ?? [])
          .map((e) => GuideSection.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  /// Asset-аас уншиж задлана
  static Future<EducationGuideData> load() async {
    final raw = await rootBundle.loadString(
      'assets/data/education_guide.json',
    );
    return EducationGuideData.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw)),
    );
  }
}

/// mn бол монгол, бусад хэлэнд англи текстийг буцаана
String _pick(String mn, String en, String lang) =>
    lang == 'mn' || en.isEmpty ? mn : en;

/// Санхүүгийн хичээл — дотроо хэд хэдэн сэдэвтэй (lesson)
class EducationCourse {
  final String id;
  final String title;
  final String titleEn;
  final String image;
  final List<EducationLesson> lessons;

  const EducationCourse({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.image,
    required this.lessons,
  });

  factory EducationCourse.fromJson(Map<String, dynamic> json) {
    return EducationCourse(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      titleEn: json['titleEn']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      lessons: (json['lessons'] as List? ?? [])
          .map((e) => EducationLesson.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  int get total => lessons.length;

  String titleOf(String lang) => _pick(title, titleEn, lang);
}

/// Хичээлийн нэг сэдэв — слайдууд + мэдлэг шалгах тест
class EducationLesson {
  final String id;
  final String title;
  final String titleEn;
  final List<LessonSlide> slides;
  final LessonQuiz? quiz;

  const EducationLesson({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.slides,
    required this.quiz,
  });

  factory EducationLesson.fromJson(Map<String, dynamic> json) {
    final quizJson = json['quiz'];
    return EducationLesson(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      titleEn: json['titleEn']?.toString() ?? '',
      slides: (json['slides'] as List? ?? [])
          .map((e) => LessonSlide.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      quiz: quizJson is Map
          ? LessonQuiz.fromJson(Map<String, dynamic>.from(quizJson))
          : null,
    );
  }

  String titleOf(String lang) => _pick(title, titleEn, lang);
}

/// Сэдвийн нэг слайд — гарчиг, агуулга, заавал биш зураг/бичлэг + тайлбар.
/// `image` нь asset зам эсвэл http(s) URL, `video` нь http(s) URL байж болно.
/// Бичлэг байвал зургийн оронд тоглуулагч харагдана.
class LessonSlide {
  final String title;
  final String titleEn;
  final String body;
  final String bodyEn;
  final String image; // хоосон бол зураггүй (asset зам эсвэл URL)
  final String video; // хоосон бол бичлэггүй (URL)
  final String caption;
  final String captionEn;

  const LessonSlide({
    required this.title,
    required this.titleEn,
    required this.body,
    required this.bodyEn,
    required this.image,
    required this.video,
    required this.caption,
    required this.captionEn,
  });

  factory LessonSlide.fromJson(Map<String, dynamic> json) {
    return LessonSlide(
      title: json['title']?.toString() ?? '',
      titleEn: json['titleEn']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      bodyEn: json['bodyEn']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      video: json['video']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
      captionEn: json['captionEn']?.toString() ?? '',
    );
  }

  String titleOf(String lang) => _pick(title, titleEn, lang);
  String bodyOf(String lang) => _pick(body, bodyEn, lang);
  String captionOf(String lang) => _pick(caption, captionEn, lang);
}

/// Мэдлэг шалгах тест — нэг асуулт, сонголтууд, зөв хариултын индекс
class LessonQuiz {
  final String question;
  final String questionEn;
  final List<String> options;
  final List<String> optionsEn;
  final int correctIndex;

  const LessonQuiz({
    required this.question,
    required this.questionEn,
    required this.options,
    required this.optionsEn,
    required this.correctIndex,
  });

  factory LessonQuiz.fromJson(Map<String, dynamic> json) {
    return LessonQuiz(
      question: json['question']?.toString() ?? '',
      questionEn: json['questionEn']?.toString() ?? '',
      options:
          (json['options'] as List? ?? []).map((e) => e.toString()).toList(),
      optionsEn:
          (json['optionsEn'] as List? ?? []).map((e) => e.toString()).toList(),
      correctIndex: int.tryParse(json['correctIndex']?.toString() ?? '') ?? 0,
    );
  }

  String questionOf(String lang) => _pick(question, questionEn, lang);

  List<String> optionsOf(String lang) =>
      lang == 'mn' || optionsEn.isEmpty ? options : optionsEn;
}

/// "Апп ашиглах заавар"-ын бүлэг
class GuideSection {
  final String id;
  final String icon; // CustomSvgIcon нэр
  final String title;
  final String titleEn;
  final String description;
  final String descriptionEn;
  final List<GuideItem> items;

  const GuideSection({
    required this.id,
    required this.icon,
    required this.title,
    required this.titleEn,
    required this.description,
    required this.descriptionEn,
    required this.items,
  });

  factory GuideSection.fromJson(Map<String, dynamic> json) {
    return GuideSection(
      id: json['id']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      titleEn: json['titleEn']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      descriptionEn: json['descriptionEn']?.toString() ?? '',
      items: (json['items'] as List? ?? [])
          .map((e) => GuideItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  String titleOf(String lang) => _pick(title, titleEn, lang);
  String descriptionOf(String lang) => _pick(description, descriptionEn, lang);
}

/// Зааврын нэг сэдэв — гарчиг + дэлгэрэнгүй агуулга
class GuideItem {
  final String title;
  final String titleEn;
  final String body;
  final String bodyEn;

  const GuideItem({
    required this.title,
    required this.titleEn,
    required this.body,
    required this.bodyEn,
  });

  factory GuideItem.fromJson(Map<String, dynamic> json) {
    return GuideItem(
      title: json['title']?.toString() ?? '',
      titleEn: json['titleEn']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      bodyEn: json['bodyEn']?.toString() ?? '',
    );
  }

  String titleOf(String lang) => _pick(title, titleEn, lang);
  String bodyOf(String lang) => _pick(body, bodyEn, lang);
}
