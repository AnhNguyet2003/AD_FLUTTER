import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:another_flushbar/flushbar.dart';
import 'base_screen.dart'; // Import BaseScreen

class Category {
  String id;
  String categoryName;

  Category({required this.id, required this.categoryName});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'].toString(),
      categoryName: json['categoryName'],
    );
  }
}

class CategoryManagementScreen extends StatefulWidget {
  @override
  _CategoryManagementScreenState createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryNameController = TextEditingController();
  List<Category> _categories = [];
  bool _isEditing = false;
  String? _editId;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.81.30:5000/api/productCategory'),
      );
      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData['success'] == true) {
        setState(() {
          final List<dynamic> categoriesData = jsonData['productCategory'];
          _categories =
              categoriesData.map((json) => Category.fromJson(json)).toList();
        });
      } else {
        _showFlushbar('Lỗi khi lấy danh mục');
      }
    } catch (e) {
      _showFlushbar('Lỗi mạng: $e');
    }
  }

  void _showFlushbar(String message) {
    Flushbar(message: message, duration: Duration(seconds: 3))..show(context);
  }

  Future<void> _createCategory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      final response = await http.post(
        Uri.parse('http://192.168.81.30:5000/api/productCategory'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({'categoryName': _categoryNameController.text}),
      );

      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData['success'] == true) {
        setState(() {
          _categories.add(
            Category(
              id: jsonData['createdCategory']['_id'].toString(),
              categoryName: jsonData['createdCategory']['categoryName'],
            ),
          );
        });
        _categoryNameController.clear();
        Navigator.of(context).pop();
      } else {
        _showFlushbar('Lỗi khi thêm danh mục');
      }
    } catch (e) {
      _showFlushbar('Lỗi mạng: $e');
    }
  }

  Future<void> _updateCategory(String id) async {
    print("=====ID NE ======= " + id);
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      final response = await http.put(
        Uri.parse('http://192.168.81.30:5000/api/productCategory/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({'categoryName': _categoryNameController.text}),
      );

      print("============ " + response.body);

      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData['success'] == true) {
        setState(() {
          int index = _categories.indexWhere((category) => category.id == id);
          if (index != -1) {
            _categories[index].categoryName = _categoryNameController.text;
          }
        });
        _categoryNameController.clear();
        Navigator.of(context).pop();
      } else {
        _showFlushbar(
          'Lỗi khi cập nhật danh mục: ${jsonData['updatedCategory']}',
        );
      }
    } catch (e) {
      _showFlushbar('Lỗi mạng: $e');
    }
  }

  Future<void> _deleteCategory(String id) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Bạn có chắc chắn muốn xóa?"),
          content: Text("Hành động này không thể hoàn tác."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: Text("Hủy"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final prefs = await SharedPreferences.getInstance();
                  String? accessToken = prefs.getString('accessToken');

                  final response = await http.delete(
                    Uri.parse(
                      'http://192.168.81.30:5000/api/productCategory/$id',
                    ),
                    headers: {'Authorization': 'Bearer $accessToken'},
                  );

                  final Map<String, dynamic> jsonData = json.decode(
                    response.body,
                  );

                  if (jsonData['success'] == true) {
                    setState(() {
                      _categories.removeWhere((category) => category.id == id);
                    });
                    Navigator.of(context).pop();
                  } else {
                    _showFlushbar('Lỗi khi xóa danh mục');
                  }
                } catch (e) {
                  _showFlushbar('Lỗi mạng: $e');
                }
              },
              child: Text("Xóa"),
            ),
          ],
        );
      },
    );
  }

  void _showDialog() {
    if (!_isEditing) {
      _categoryNameController.clear(); // Làm trống ô nhập liệu khi thêm mới
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_isEditing ? 'Cập nhật danh mục' : 'Thêm danh mục'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _categoryNameController,
              decoration: InputDecoration(labelText: 'Tên danh mục sản phẩm'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Yêu cầu nhập';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (_isEditing) {
                    _updateCategory(_editId!);
                  } else {
                    _createCategory();
                  }
                }
              },
              child: Text(_isEditing ? 'Cập nhật' : 'Thêm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  void _editCategory(Category category) {
    print("CATE " + category.id + " ==== " + category.categoryName);
    _categoryNameController.text = category.categoryName;
    setState(() {
      _isEditing = true;
      _editId = category.id;
    });
    _showDialog();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      // Sử dụng BaseScreen
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Căn trái
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Quản lý danh mục',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerRight, // Căn phải
              child: ElevatedButton(
                onPressed: () {
                  _isEditing = false;
                  _showDialog();
                },
                child: Text('Thêm mới'),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return ListTile(
                  title: Text(category.categoryName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editCategory(category),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteCategory(category.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
