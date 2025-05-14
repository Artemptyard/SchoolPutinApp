import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/requests.dart';

class StudentGrade {
  final int? id;
  final String name;
  final int grade;
  final DateTime date;
  final String course;

  StudentGrade({
    this.id,
    required this.name,
    required this.grade,
    required this.date,
    required this.course,
  });
}

class MultiGradeBookPage extends StatefulWidget {
  final String userRole;

  const MultiGradeBookPage({super.key, required this.userRole});

  @override
  State<MultiGradeBookPage> createState() => _MultiGradeBookPageState();
}

class _MultiGradeBookPageState extends State<MultiGradeBookPage> {
  late List<Student> _students = [];
  late List<Group> _groups = [];
  late List<StudentGrade> _grades = [];
  final DateTime now = DateTime.now();
  late List<DateTime> _dates;
  late List<Course> _courses = [];
  
  ApiClient get apiClient => ApiClient(
    baseUrl: 'http://localhost:8000/api',
    username: 'teacher',
    password: 'teacherteacher',
    userRole: widget.userRole
  );

  Course? _selectedCourse;
  Group? _selectedGroup;
  late Map<String, Map<String, List<int>>> _gradesMap = {};
  bool _isLoading = true;
  String? _errorMessage;
  List<Group> _allGroups = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    _dates = List.generate(
      daysInMonth,
      (i) => DateTime(now.year, now.month, i + 1),
    );
    loadCourses();
    _initData();
  }

  Future<void> _initData() async {
    try {
      await _loadInitialData();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки данных: $e';
        _isLoading = false;
      });
    }
  }


  // 1. Обновляем метод загрузки курсов
  Future<void> loadCourses() async {
    try {
      final courses = await apiClient.fetchCourses();
      setState(() {
        _courses = courses;
        if (_courses.isNotEmpty) {
          _selectedCourse = _courses.first;
          _filterGroupsByCourse();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки курсов: $e')),
      );
    }
  }

  void _filterGroupsByCourse() {
    if (_selectedCourse == null) {
      return;
    }
    setState(() {
      _groups = _allGroups.where((group) => group.subject == _selectedCourse!.id).toList();
      if (_groups.isNotEmpty) {
        _selectedGroup = _groups.first;
        _loadStudentsForGroup(_selectedGroup!);
      } else {
        _selectedGroup = null;
      }
    });
  }

  // 3. Обновляем метод изменения курса
  void _changeCourse(Course? course) {
    if (course != null) {
      setState(() {
        _selectedCourse = course;
        _filterGroupsByCourse();
        _processGradesData();
      });
    }
  }

  Future<void> _loadInitialData() async {
    try {
      final allGroups = await apiClient.get_groups();
      final students = await apiClient.getStudents();
      
      setState(() {
        _allGroups = allGroups;
        _students = students;
        _filterGroupsByCourse();
      });

      _loadGrades();
      _processGradesData();
    } catch (e) {
      throw Exception('Ошибка загрузки данных: $e');
    }
  }


  Future<void> _loadStudentsForGroup(Group group) async {
    try {
      final students = await apiClient.getStudentsByGroup(group.id);
      setState(() {
        _selectedGroup = Group(
          id: group.id,
          name: group.name,
          subject: group.subject,
          students: students,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки студентов: $e')),
      );
    }
  }

  void _loadGrades() async {
    setState(() => _isLoading = true);
    
    try {
      final grades = await apiClient.fetchGrades();
      setState(() {
        _grades = grades;
        _processGradesData();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки оценок: $e';
        _grades = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки оценок: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _processGradesData() {
    _gradesMap = {};
    
    for (var student in _students) {
      _gradesMap[student.fullName] = {};
      
      for (var date in _dates) {
        final dateKey = _dateKey(date);
        _gradesMap[student.fullName]![dateKey] = [];
      }
    }

    for (var grade in _grades) {
      if (grade.course == _selectedCourse!.name) {
        final dateKey = _dateKey(grade.date);
        _gradesMap[grade.name]![dateKey]?.add(grade.grade);
      }
    }
  }

  String _dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  List<Student> _getCurrentGroupStudents() {
    if (_selectedGroup == null || _selectedGroup!.students.isEmpty) return [];
    return _selectedGroup!.students;
  }

  void _addGrade(String studentName, String dateKey, int grade) {
    setState(() {
      _gradesMap[studentName]![dateKey]?.add(grade);
      _grades.add(StudentGrade(
        name: studentName,
        grade: grade,
        date: DateFormat('yyyy-MM-dd').parse(dateKey),
        course: _selectedCourse!.name,
      ));
    });

    apiClient.sendAddGradeRequest(StudentGrade(
        name: studentName,
        grade: grade,
        date: DateFormat('yyyy-MM-dd').parse(dateKey),
        course: _selectedCourse!.name,
      ), _selectedCourse!);
  }

  void _changeGroup(Group? group) async {
  if (group != null) {
    setState(() => _isLoading = true);
    
    try {
      await _loadStudentsForGroup(group);
      setState(() {
        _processGradesData();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки студентов: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            ElevatedButton(
              onPressed: _initData,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (_groups.isEmpty) {
      return const Center(child: Text('Нет доступных групп'));
    }

    final isEditable = widget.userRole == 'teacher';

    return Scaffold(
      body: Column(
        children: [
          _buildControls(),
          Expanded(child: _buildGradeTable(isEditable)),
        ],
      ),
    );
  }

  Widget _buildControls() {
    
    final isEditable = widget.userRole == 'teacher';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const Text('Предмет: ', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<Course>(
            value: _selectedCourse,
            items: _courses.map((course) => DropdownMenuItem(
              value: course,
              child: Text(course.name),
            )).toList(),
            onChanged: _changeCourse,
          ),
          const SizedBox(width: 20),
          if (isEditable) ...[
          const Text('Группа: ', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<Group>(
            value: _selectedGroup,
            items: _groups.map((group) => DropdownMenuItem(
              value: group,
              child: Text(group.name),
            )).toList(),
            onChanged: _changeGroup,
          ),
          ],
        ],
      ),
    );
  }

  Widget _buildGradeTable(bool isEditable) {
    final students = _getCurrentGroupStudents();
    
    if (students.isEmpty) {
      return const Center(child: Text('В группе нет студентов'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(),
          ...students.map((student) => _buildStudentRow(student, isEditable)),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        Container(
          width: 120,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: const Text('ФИО', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ..._dates.map((date) => Container(
          width: 100,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Text(
            DateFormat('dd.MM').format(date),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        )),
      ],
    );
  }

  Widget _buildStudentRow(Student student, bool isEditable) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 120,
          height: 80,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Text(student.fullName),
        ),
        ..._dates.map((date) => _buildGradeCell(student.fullName, date, isEditable)),
      ],
    );
  }

  Widget _buildGradeCell(String studentName, DateTime date, bool isEditable) {
    final dateKey = _dateKey(date);
    final grades = _gradesMap[studentName]?[dateKey] ?? [];

    return Container(
      width: 100,
      height: 80,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: isEditable ? _buildEditableCell(studentName, dateKey, grades) 
                        : _buildReadOnlyCell(grades),
    );
  }

  Widget _buildEditableCell(String studentName, String dateKey, List<int> grades) {
    return Column(
      children: [
        Expanded(
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: grades.map((grade) => Chip(
              label: Text('$grade'),
              labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
              backgroundColor: _getColorForGrade(grade),
              visualDensity: VisualDensity.compact,
            )).toList(),
          ),
        ),
        if (grades.length < 3)
          IconButton(
            icon: const Icon(Icons.add, size: 16),
            onPressed: () => _showAddGradeDialog(studentName, dateKey),
          ),
      ],
    );
  }

  Widget _buildReadOnlyCell(List<int> grades) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: grades.map((grade) => CircleAvatar(
        radius: 12,
        backgroundColor: _getColorForGrade(grade),
        child: Text('$grade', style: const TextStyle(fontSize: 12, color: Colors.white)),
      )).toList(),
    );
  }

  Color _getColorForGrade(int grade) {
    switch (grade) {
      case 5: return Colors.green;
      case 4: return Colors.blue;
      case 3: return Colors.orange;
      default: return Colors.red;
    }
  }

  void _showAddGradeDialog(String studentName, String dateKey) {
    int selectedGrade = 4;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Добавить оценку'),
        content: DropdownButton<int>(
          value: selectedGrade,
          items: [2, 3, 4, 5].map((e) => DropdownMenuItem(
            value: e,
            child: Text('$e'),
          )).toList(),
          onChanged: (value) => selectedGrade = value ?? 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              _addGrade(studentName, dateKey, selectedGrade);
              Navigator.pop(ctx);
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }
}

class Student {
  final int id;
  final String username;
  final String firstName;
  final String? lastName;
  final String? middleName;

  Student({
    required this.username,
    required this.id,
    required this.firstName,
    this.lastName,
    this.middleName,
  });

  String get fullName => [lastName, firstName, middleName]
      .where((part) => part != null && part.isNotEmpty)
      .join(' ');
}

class Group {
  final int id;
  final String name;
  final int subject;
  final List<Student> students;

  Group({
    required this.id,
    required this.name,
    required this.subject,
    required this.students,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Group &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  Group copyWith({List<Student>? students}) {
    return Group(
      id: id,
      name: name,
      subject: subject,
      students: students ?? this.students,
    );
  }
}


class Course {
  final int id;
  final String name;
  final String description;

  Course({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}
