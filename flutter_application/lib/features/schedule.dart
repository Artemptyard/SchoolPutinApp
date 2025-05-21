import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Assignment {
  final String title;
  final String description;
  final DateTime dueDate;

  Assignment({
    required this.title,
    required this.description,
    required this.dueDate,
  });
}

class SchedulePage extends StatefulWidget {
  final String userRole;

  const SchedulePage({super.key, required this.userRole});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final List<String> groups = ['10A', '10B', '11A'];
  String selectedGroup = '10A';
      final Map<String, List<Assignment>> groupAssignments = {
        '10A': [
          Assignment(
            title: 'Математика',
            description: 'Тема: Решение квадратных уравнений',
            dueDate: DateTime.now().add(Duration(days: 3)),
          ),
          Assignment(
            title: 'Английский язык',
            description: 'Тема: Present Perfect vs Past Simple',
            dueDate: DateTime.now().add(Duration(days: 5)),
          ),
          Assignment(
            title: 'Математика',
            description: 'Тема: Геометрия. Теорема Пифагора',
            dueDate: DateTime.now().add(Duration(days: 7)),
          ),
          Assignment(
            title: 'Английский язык',
            description: 'Тема: Модальные глаголы (can, must, should)',
            dueDate: DateTime.now().add(Duration(days: 9)),
          ),
          Assignment(
            title: 'Математика',
            description: 'Тема: Логарифмы и их свойства',
            dueDate: DateTime.now().add(Duration(days: 11)),
          ),
          Assignment(
            title: 'Английский язык',
            description: 'Тема: Условные предложения (Conditionals)',
            dueDate: DateTime.now().add(Duration(days: 13)),
          ),
          Assignment(
            title: 'Математика',
            description: 'Тема: Производные и дифференцирование',
            dueDate: DateTime.now().add(Duration(days: 15)),
          ),
          Assignment(
            title: 'Английский язык',
            description: 'Тема: Пассивный залог (Passive Voice)',
            dueDate: DateTime.now().add(Duration(days: 17)),
          ),
          Assignment(
            title: 'Математика',
            description: 'Тема: Тригонометрические уравнения',
            dueDate: DateTime.now().add(Duration(days: 19)),
          ),
          Assignment(
            title: 'Английский язык',
            description: 'Тема: Фразовые глаголы (Phrasal Verbs)',
            dueDate: DateTime.now().add(Duration(days: 21)),
          ),
        ]
  };

  @override
  Widget build(BuildContext context) {
    final assignments = [...(groupAssignments[selectedGroup] ?? [])];
    assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: assignments.isEmpty
                ? Center(child: Text('Нет заданий'))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GridView.count(
                      crossAxisCount: 5, 
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 3 / 2, // Соотношение сторон карточки
                      children: assignments.map((assignment) {
                        return Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  assignment.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Expanded(
                                  child: Text(
                                    assignment.description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Дата: ${DateFormat('dd.MM.yyyy').format(assignment.dueDate)}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
