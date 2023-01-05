import 'dart:convert';

import 'package:gakujo_task/api/parse.dart';
import 'package:html/dom.dart';

class Quiz implements Comparable<Quiz> {
  String subject;
  String title;
  String id;
  String schoolYear;
  String subjectCode;
  String classCode;
  String status;
  DateTime startDateTime = DateTime.fromMicrosecondsSinceEpoch(0);
  DateTime endDateTime = DateTime.fromMicrosecondsSinceEpoch(0);
  String submissionStatus;
  String implementationFormat;
  String operation;
  int questionsCount;
  String evaluationMethod;
  String description;
  List<String>? fileNames;
  String message;
  bool isAcquired = false;
  bool isArchived = false;

  Quiz(
    this.subject,
    this.title,
    this.id,
    this.schoolYear,
    this.subjectCode,
    this.classCode,
    this.status,
    this.startDateTime,
    this.endDateTime,
    this.submissionStatus,
    this.implementationFormat,
    this.operation,
    this.questionsCount,
    this.evaluationMethod,
    this.description,
    this.fileNames,
    this.message, {
    required this.isAcquired,
    required this.isArchived,
  });

  factory Quiz.fromDocument(String subject, Document document) {
    final title =
        document.querySelector('#area > table > tbody > tr > td')?.text ?? '';
    final id = document
            .querySelector(
              '#right-box > form > input[type=hidden]:nth-child(3)',
            )
            ?.attributes['value'] ??
        '';
    final startDateTime = document
        .querySelector('#area > table > tbody > tr:nth-child(1) > td')!
        .text
        .trimSpanDateTime(0);
    final endDateTime = document
        .querySelector('#area > table > tbody > tr:nth-child(1) > td')!
        .text
        .trimSpanDateTime(1);
    final quiz = Quiz(
      subject.trimSubject(),
      title,
      id,
      '',
      '',
      '',
      '',
      startDateTime,
      endDateTime,
      '',
      '',
      '',
      -1,
      '',
      '',
      null,
      '',
      isAcquired: false,
      isArchived: false,
    )..toDetail(document);
    return quiz;
  }

  factory Quiz.fromElement(Element element) {
    final subject =
        element.querySelectorAll('td')[0].text.trimWhiteSpace().trimSubject();
    final title =
        element.querySelectorAll('td')[1].querySelector('a')!.text.trim();
    final id = element
        .querySelectorAll('td')[1]
        .querySelector('a')!
        .attributes['onclick']!
        .trimJsArgs(1);
    final schoolYear = element
        .querySelectorAll('td')[1]
        .querySelector('a')!
        .attributes['onclick']!
        .trimJsArgs(3);
    final subjectCode = element
        .querySelectorAll('td')[1]
        .querySelector('a')!
        .attributes['onclick']!
        .trimJsArgs(4);
    final classCode = element
        .querySelectorAll('td')[1]
        .querySelector('a')!
        .attributes['onclick']!
        .trimJsArgs(5);
    final status = element.querySelectorAll('td')[2].text.trim();
    final startDateTime =
        element.querySelectorAll('td')[3].text.trimSpanDateTime(0);
    final endDateTime =
        element.querySelectorAll('td')[3].text.trimSpanDateTime(1);
    final submissionStatus = element.querySelectorAll('td')[4].text.trim();
    final implementationFormat = element.querySelectorAll('td')[5].text.trim();
    final operation = element.querySelectorAll('td')[6].text.trim();
    return Quiz(
      subject,
      title,
      id,
      schoolYear,
      subjectCode,
      classCode,
      status,
      startDateTime,
      endDateTime,
      submissionStatus,
      implementationFormat,
      operation,
      -1,
      '',
      '',
      null,
      '',
      isAcquired: false,
      isArchived: false,
    );
  }

  static Map<String, dynamic> toMap(Quiz quiz) => <String, dynamic>{
        'subject': quiz.subject,
        'title': quiz.title,
        'id': quiz.id,
        'schoolYear': quiz.schoolYear,
        'subjectCode': quiz.subjectCode,
        'classCode': quiz.classCode,
        'status': quiz.status,
        'startDateTime': quiz.startDateTime.toIso8601String(),
        'endDateTime': quiz.endDateTime.toIso8601String(),
        'submissionStatus': quiz.submissionStatus,
        'implementationFormat': quiz.implementationFormat,
        'operation': quiz.operation,
        'questionsCount': quiz.questionsCount,
        'evaluationMethod': quiz.evaluationMethod,
        'description': quiz.description,
        'fileNames': quiz.fileNames,
        'message': quiz.message,
        'isAcquired': quiz.isAcquired,
        'isArchived': quiz.isArchived
      };

  factory Quiz.fromJson(dynamic json) {
    json = json as Map<String, dynamic>;
    return Quiz(
      json['subject'] as String,
      json['title'] as String,
      json['id'] as String,
      json['schoolYear'] as String,
      json['subjectCode'] as String,
      json['classCode'] as String,
      json['status'] as String,
      (json['startDateTime'] as String).parseDateTime(),
      (json['endDateTime'] as String).parseDateTime(),
      json['submissionStatus'] as String,
      json['implementationFormat'] as String,
      json['operation'] as String,
      json['questionsCount'] as int,
      json['evaluationMethod'] as String,
      json['description'] as String,
      (json['fileNames'] as List<dynamic>?)?.map((e) => e as String).toList(),
      json['message'] as String,
      isAcquired: json['isAcquired'] as bool,
      isArchived: json['isArchived'] as bool,
    );
  }

  static String encode(List<Quiz> quizzes) => json.encode(
        quizzes.map<Map<String, dynamic>>(Quiz.toMap).toList(),
      );

  static List<Quiz> decode(String quizzes) => json.decode(quizzes) is List
      ? (json.decode(quizzes) as List).map<Quiz>(Quiz.fromJson).toList()
      : [];

  bool get isSubmitted => submissionStatus != '未提出';

  void toRefresh(Quiz quiz) {
    title = quiz.title;
    status = quiz.status;
    startDateTime = quiz.startDateTime;
    endDateTime = quiz.endDateTime;
    submissionStatus = quiz.submissionStatus;
    implementationFormat = quiz.implementationFormat;
    operation = quiz.operation;
  }

  void toDetail(Document document) {
    isAcquired = true;
    questionsCount = int.tryParse(
          document
                  .querySelector('#area > table > tbody > tr:nth-child(2) > td')
                  ?.text
                  .replaceFirst('問', '')
                  .trim() ??
              '',
        ) ??
        -1;
    evaluationMethod = document
            .querySelector('#area > table > tbody > tr:nth-child(3) > td')
            ?.text ??
        '';
    description = document
            .querySelector('#area > table > tbody > tr:nth-child(4) > td')
            ?.text ??
        '';
    message = document
            .querySelector('#area > table > tbody > tr:nth-child(6) > td')
            ?.text ??
        '';
  }

  bool contains(String value) =>
      subject.toLowerCase().contains(value.toLowerCase()) ||
      title.toLowerCase().contains(value.toLowerCase()) ||
      description.toLowerCase().contains(value.toLowerCase()) ||
      message.toLowerCase().contains(value.toLowerCase());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is Quiz) {
      return subjectCode == other.subjectCode &&
          classCode == other.classCode &&
          id == other.id;
    }
    return false;
  }

  @override
  int get hashCode => subjectCode.hashCode ^ classCode.hashCode ^ id.hashCode;

  @override
  int compareTo(Quiz other) {
    final compare1 = endDateTime.compareTo(other.endDateTime);
    if (compare1 != 0) {
      return compare1;
    }
    final compare2 = startDateTime.compareTo(other.startDateTime);
    if (compare2 != 0) {
      return compare2;
    }
    final compare3 = subjectCode.compareTo(other.subjectCode);
    if (compare3 != 0) {
      return compare3;
    }
    final compare4 = id.compareTo(other.id);
    return compare4;
  }
}
