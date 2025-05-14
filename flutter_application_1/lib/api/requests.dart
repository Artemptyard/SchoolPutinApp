import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../features/dashboard.dart';
import '../features/materials.dart';
import 'dart:io'; 

class ApiClient{
  final Dio _dio;
  final String _username;
  final String _password;
  final String _userRole;

  ApiClient({
    required String baseUrl,
    required String username,
    required String password,
    required String userRole,
  })  : _username = username,
        _password = password,
        _userRole = userRole,
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': _basicAuthHeader(username, password),
          },
        )) {
    _dio.interceptors.add(LogInterceptor());
  }


  static String _basicAuthHeader(String username, String password) {
    final credentials = '$username:$password';
    final base64Credentials = base64Encode(utf8.encode(credentials));
    return 'Basic $base64Credentials';
  }

  Future<List<StudentGrade>> fetchGrades() async {
    final response = await _dio.get('/gradebook/teacher/');
    final rawList = List.from(response.data);
    
    final students = await getStudents();
    final courses = await fetchCourses();
    
    List<StudentGrade> gradeData = [];
    for (var raw in rawList) {
      final student = students.firstWhere((s) => s.id == raw['student']);
      final course = courses.firstWhere((c) => c.id == raw['subject']);
      gradeData.add(StudentGrade(
        id: raw['id'],
        name: student.fullName,
        grade: raw['grade'],
        date: DateTime.parse(raw['date']),
        course: course.name,
      ));
    }
    return gradeData;
  }

  Future<List<Course>> fetchCourses() async {
    final response = await _dio.get('/schedule/subject/');
    final rawList = List.from(response.data);
    List<Course> courseData = [];
    for (var raw in rawList){
      courseData.add(Course(id: raw['id'], name: raw['name'], description: raw['description']));
    }
    return courseData;
  }

  // ignore: non_constant_identifier_names
  Future<List<Group>> get_groups() async {
    final response = await _dio.get('/schedule/group/');
    final rawList = List.from(response.data);
    List<Group> groupData = [];
    for (final raw in rawList){
      var students = await getStudentsByGroup(raw['id']);
      if (_userRole == 'student') {
        final student = await getStudentByName(_userRole);
        final isStudentInGroup = students.any((s) => s.id == student?.id);
        students = [student!];
        if (!isStudentInGroup) {
          continue;
      }
    }
      groupData.add(Group(id: raw['id'],name: raw['name'], subject: raw['subject'], students:  students));
    }
    return groupData;
  }

  Future<List<Student>> getStudents() async{
    final students = await _dio.get('/users/get_students/');

    final allStudents = (students.data as List)
          .map((json) => Student(id: json['id'],
      firstName: json['user']['first_name'],
      lastName: json['user']['last_name'],
      middleName: json['user']['middle_name'],
      username: json['user']['username']))
          .toList();

    return allStudents;
  }

  Future<void> sendAddGradeRequest(StudentGrade grade, Course course) async {
    try {
    final student = await getStudentByFullName(grade.name);
    if (student == null) {
      throw Exception('Студент с именем ${grade.name} не найден');
    }

    await _dio.post('/gradebook/create/', data: {
      "date":  DateFormat('yyyy-MM-dd').format(grade.date),
      "grade": grade.grade,
      "comment": "",
      "student": student.id,
      "subject": course.id,
    });
  } catch (e) {
    print('Ошибка при добавлении оценки: $e');
  }
  }

  Future<Student?> getStudentByName(String studentName) async{
    final students = await _dio.get('/users/get_students/');

    final allStudents = (students.data)
          .map((json) => Student(id: json['id'],
      firstName: json['user']['first_name'],
      lastName: json['user']['last_name'],
      middleName: json['user']['middle_name'],
      username: json['user']['username']))
          .toList();


    Student? foundStudent;
    for (Student student in allStudents){
      if (studentName == student.username){
        foundStudent = student;
      }
    }

    return foundStudent;
  }

  Future<Student?> getStudentByFullName(String studentName) async{
    final students = await _dio.get('/users/get_students/');

    final allStudents = (students.data)
          .map((json) => Student(id: json['id'],
      firstName: json['user']['first_name'],
      lastName: json['user']['last_name'],
      middleName: json['user']['middle_name'],
      username: json['user']['username']))
          .toList();


    Student? foundStudent;
    for (Student student in allStudents){
      if (studentName == student.fullName){
        foundStudent = student;
      }
    }

    return foundStudent;
  }

  Future<List<StudyMaterial>> fetchMaterials() async {
    final response = await _dio.get('/materials/materials/');

    final data = response.data as List;
    print('---------------------------------------------------------------------');
    print(data);
    return data.map((json) => StudyMaterial.fromJson(json)).toList();
  }

  Future<File> downloadMaterialFile(StudyMaterial material) async {
  try {
    final filename = material.fileUrl!.split('/').last;
    final savePath = await _getLocalPath(filename);
    
    await _dio.download(
      material.fileUrl!,
      savePath,
      options: Options(
        headers: {'Authorization': 'Bearer YOUR_TOKEN'}, // Если нужно
      ),
      onReceiveProgress: (received, total) {
        if (total != -1) {
          print('${(received / total * 100).toStringAsFixed(0)}%');
        }
      },
    );
    
    return File(savePath);
  } on DioException catch (e) {
    throw Exception('Failed to download file: ${e.message}');
  }
}

Future<String> _getLocalPath(String filename) async {
  return 'http://localhost:8000/media/materials/$filename';
}

Future<void> deleteMaterial(int id) async {
  final response = await _dio.delete('/materials/delete-materials/$id/');
  if (response.statusCode != 204) {
    throw Exception('Не удалось удалить материал');
  }
}

Future<void> updateMaterial(material_id, title, description, fileBytes, fileName, subjectId) async {
  try{
  
  final formData = FormData.fromMap({
    'title': title,
    'description': description,
    if (fileBytes != null)
      'file': MultipartFile.fromBytes(
        fileBytes!,
        filename: fileName,
      ),
    'subject': subjectId,
    'teacher': 7
  });

  var res = await _dio.put(
    '/materials/update-materials/${material_id}/',
    data: formData,
    options: Options(contentType: 'multipart/form-data'),
  );
  } on DioException catch(e){
    print('Ошибка с ответом от сервера: ${e.response?.data}');
    print('Код статуса: ${e.response?.statusCode}');
  }
}


  Future<void> addMaterial(title, description, fileBytes, fileName, subjectId,) async {
  try {
    print('----------------------------------------------------------------');
    print([title, description, fileBytes, fileName, subjectId]);
    if (fileBytes != null) {
      final formData = FormData.fromMap({
        'title': title,
        'description': description,
        'subject': subjectId,
        'teacher':7,
        'file': MultipartFile.fromBytes(
          fileBytes!,
          filename: fileName,
        ),
      });
      
      await _dio.post(
        '/materials/create-materials/',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } else {
      await _dio.post(
        '/materials/create-materials/',
        data: {
          'title': title,
          'description': description,
          'subject': subjectId,
          'teacher':7
        },
      );
    }
  } on DioException catch (e) {
    throw Exception('Failed to add material: ${e.response?.data ?? e.message}');
  }
}

  Future<List<Student>> getStudentsByGroup(int groupId) async {
    try {
      final groupResponse = await _dio.get('/schedule/group/$groupId/');
      final groupData = groupResponse.data as Map<String, dynamic>;
      final studentIds = List<int>.from(groupData['students']);

      final students = await getStudents();
      List<Student> allStudents = students.where((s) => studentIds.contains(s.id)).toList();

      if (_userRole == 'student') {
        final student = await getStudentByName(_userRole);
        final isStudentInGroup = allStudents.any((s) => s.id == student?.id);
        if (isStudentInGroup) {
          allStudents = [student!];
      }
      }
      return allStudents;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createGrade({
    required int studentId,
    required int subjectId,
    required int gradeValue,
    required String date,
    String? comment,
  }) async {
    try {
      final response = await _dio.post('/gradebook/create', data: {
        'date': date,
        'grade': gradeValue,
        'comment': comment,
        'student': studentId,
        'subject': subjectId,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      return Exception(
        'Ошибка ${e.response!.statusCode}: ${e.response!.data['message'] ?? e.response!.data}',
      );
    } else {
      return Exception('Сетевая ошибка: ${e.message}');
    }
  }
}
