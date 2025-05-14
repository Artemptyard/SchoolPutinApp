import 'package:flutter/material.dart';
import 'package:flutter_application_2/api/requests.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'dart:html' as html; // Только для веба
import 'package:flutter/foundation.dart'; // Для kIsWeb
import 'package:dio/dio.dart';
import 'dart:io'; 


class MaterialsPage extends StatefulWidget {
  final String userRole;

  const MaterialsPage({super.key, required this.userRole});

  @override
  State<MaterialsPage> createState() => _MaterialsPageState();
}

class _MaterialsPageState extends State<MaterialsPage> {
  final List<StudyMaterial> _materials = [];
  bool _isLoading = false;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  PlatformFile? _selectedFile;

  ApiClient get apiClient => ApiClient(
    baseUrl: 'http://localhost:8000/api',
    username: 'teacher',
    password: 'teacherteacher',
    userRole: widget.userRole,
  );

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadMaterials() async {
    try {
      final materials = await apiClient.fetchMaterials();
      setState(() {
        _materials.clear();
        _materials.addAll(materials);
      });
    } catch (e) {
      print('Ошибка загрузки: $e');
    }
  }

  void _showMaterial(StudyMaterial material, {bool isEditMode = false}) {
    final titleController = TextEditingController(text: material.title);
    final descController = TextEditingController(text: material.description);
    PlatformFile? selectedFile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return PopScope(
            child: AlertDialog(
              title: Text(isEditMode ? 'Редактировать материал' : material.title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isEditMode) Text(material.description),
                    
                    if (isEditMode) ...[
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Название',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Описание',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              final file = await _pickFile();
                              if (file != null) {
                                setState(() => selectedFile = file);
                              }
                            },
                            icon: const Icon(Icons.attach_file),
                            label: const Text('Заменить файл'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedFile?.name ?? 'Файл не выбран',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                if (isEditMode) ...[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await apiClient.updateMaterial(material.id,
                        titleController.text,
                        descController.text,
                        selectedFile?.bytes,
                        selectedFile?.name,
                        3);
                        Navigator.pop(context);
                        _loadMaterials(); // Обновляем список
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ошибка обновления: $e')),
                        );
                      }
                    },
                    child: const Text('Сохранить'),
                  ),
                ],
                if (!isEditMode) ...[
                  if (widget.userRole == 'teacher')
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showMaterial(material, isEditMode: true);
                      },
                      child: const Text('Редактировать'),
                    ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Закрыть'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteMaterial(int materialId) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Удалить материал?'),
      content: const Text('Вы уверены, что хотите удалить этот материал?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Удалить'),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  try {
    setState(() => _isLoading = true);
    await apiClient.deleteMaterial(materialId);
    await _loadMaterials();
  } catch (e) {
    _showErrorSnackbar('Ошибка удаления: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}


  Future<void> downloadAndOpenFile(String fileUrl) async {
  try {
    if (kIsWeb) {
      // Для веб-версии
      html.AnchorElement(href: fileUrl)
        ..setAttribute('download', '')
        ..click();
    } else {
      final response = await Dio().get(
        fileUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      
      final bytes = response.data as List<int>;
      final file = File('${fileUrl.split('/').last}');
      await file.writeAsBytes(bytes);
      await OpenFile.open(file.path);
    }
  } catch (e) {
    throw Exception('Ошибка загрузки файла: $e');
  }
}

  Future<PlatformFile?> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(withData: true);
      return result?.files.first;
    } catch (e) {
      _showErrorSnackbar('Ошибка выбора файла: $e');
      return null;
    }
  }

  Future<void> _addMaterial() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      _showErrorSnackbar('Заполните все поля');
      return;
    }

    try {
      setState(() => _isLoading = true);
      await apiClient.addMaterial(
        _titleController.text,
        _descController.text,
        _selectedFile?.bytes,
        _selectedFile?.name,
        3,
      );
      Navigator.of(context).pop();
      await _loadMaterials();
    } catch (e) {
      _showErrorSnackbar('Ошибка добавления: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showAddMaterialDialog() {
  PlatformFile? selectedFile;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Добавить материал'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Заголовок',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final file = await _pickFile();
                        if (file != null) {
                          setState(() {
                            selectedFile = file;
                            _selectedFile = file;
                          });
                        }
                      },
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Выбрать файл'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedFile?.name ?? 'Файл не выбран',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _addMaterial,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Добавить'),
              ),
            ],
          );
        },
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    final isTeacher = widget.userRole == 'teacher';

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (isTeacher)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddMaterialDialog,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _materials.isEmpty
              ? const Center(child: Text('Нет доступных материалов'))
              : ListView.builder(
                  itemCount: _materials.length,
                  itemBuilder: (context, index) {
                    final material = _materials[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(material.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(material.description),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd.MM.yyyy').format(material.uploadDate),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteMaterial(material.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () => downloadAndOpenFile(material.fileUrl!),
                            ),
                          ],
                        ),
                        onTap: () => _showMaterial(material),
                      ),
                    );
                  },
                ),
    );
  }
}

class StudyMaterial {
  final int id;
  final String title;
  final String description;
  final String? fileUrl;
  final DateTime uploadDate;
  final int subjectId;

  StudyMaterial({
    required this.id,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.uploadDate,
    required this.subjectId,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json) {
    return StudyMaterial(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      fileUrl: json['file'],
      uploadDate: DateTime.parse(json['upload_date']),
      subjectId: json['subject'],
    );
  }
}