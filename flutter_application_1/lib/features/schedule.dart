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
        title: 'История',
        description: 'Тема: Великая Отечественная война (1941–1945)',
        dueDate: DateTime.now().add(Duration(days: 3)),
      ),
      Assignment(
        title: 'Химия',
        description: 'Тема: Валентность и химические связи',
        dueDate: DateTime.now().add(Duration(days: 4)),
      ),
      Assignment(
        title: 'Литература',
        description: 'Тема: Анализ поэмы "Мёртвые души"',
        dueDate: DateTime.now().add(Duration(days: 2)),
      ),
      Assignment(
        title: 'Биология',
        description: 'Тема: Генетика. Законы Менделя',
        dueDate: DateTime.now().add(Duration(days: 5)),
      ),
      Assignment(
        title: 'Информатика',
        description: 'Тема: Основы алгоритмизации и блок-схемы',
        dueDate: DateTime.now().add(Duration(days: 1)),
      ),
      Assignment(
        title: 'Русский язык',
        description: 'Тема: Сложноподчинённые предложения с придаточными определительными',
        dueDate: DateTime.now().add(Duration(days: 2)),
      ),
      Assignment(
        title: 'Обществознание',
        description: 'Тема: Политическая система и её элементы',
        dueDate: DateTime.now().add(Duration(days: 3)),
      ),

    ],
    '10B': [],
    '11A': [],
  };

  @override
  Widget build(BuildContext context) {
    final assignments = [...(groupAssignments[selectedGroup] ?? [])];
    assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedGroup,
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedGroup = value);
                }
              },
              items: groups
                  .map((group) => DropdownMenuItem(
                        value: group,
                        child: Text('Группа $group'),
                      ))
                  .toList(),
            ),
          ),
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
