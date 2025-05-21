import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'schedule.dart';
import 'materials.dart';

class MainLayout extends StatefulWidget {
  final String userRole;

  const MainLayout({super.key, required this.userRole});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      MultiGradeBookPage(userRole: widget.userRole),
      MaterialsPage(userRole: widget.userRole,),
      SchedulePage(userRole: widget.userRole,),
    ];
  }

  final List<String> _titles = [
    'Оценки',
    'Материалы',
    'Расписание',
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grade), label: 'Успеваемость'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Материалы'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Расписание'),
        ],
      ),
    );
  }
}
