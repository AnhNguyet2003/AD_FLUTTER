import 'package:flutter/material.dart';
import 'base_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<dynamic> users = [];
  String searchName = '';
  Map<String, dynamic> editUser = {};
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  String selectedStatus = 'Hoạt động'; // Trạng thái mặc định
  bool isEditing = false;

  Future<void> fetchUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse('http://192.168.81.30:5000/api/user'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = json.decode(response.body);
    if (data['success']) {
      setState(() {
        users = data['userData'];
      });
    }
  }

  Future<void> updateUser(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('accessToken');

    final response = await http.put(
      Uri.parse('http://192.168.81.30:5000/api/user/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': nameController.text,
        'phone': phoneController.text,
        'status': selectedStatus == 'Hoạt động',
      }),
    );

    final data = json.decode(response.body);
    if (data['success']) {
      fetchUsers();
      setState(() {
        isEditing = false;
        editUser = {};
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Container(
        // color: Colors.pink[100],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Quản Lý Thành Viên',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Tìm kiếm tên người dùng'),
              onChanged: (value) {
                setState(() {
                  searchName = value;
                });
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    if (searchName.isNotEmpty &&
                        !user['name'].toString().toLowerCase().contains(
                          searchName.toLowerCase(),
                        )) {
                      return Container();
                    }
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user['email'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    user['name'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    user['phone'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          user['role'] == 'Admin'
                                              ? Colors.blue
                                              : const Color.fromARGB(
                                                255,
                                                249,
                                                124,
                                                207,
                                              ),
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          user['status']
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Hiển thị biểu tượng chỉnh sửa cho không phải Admin
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color:
                                    user['role'] == 'Admin'
                                        ? Colors
                                            .grey // Màu nhạt cho Admin
                                        : Colors.black,
                              ),
                              onPressed:
                                  user['role'] == 'Admin'
                                      ? null
                                      : () {
                                        setState(() {
                                          isEditing = true;
                                          editUser = user;
                                          nameController.text = user['name'];
                                          emailController.text = user['email'];
                                          phoneController.text = user['phone'];
                                          roleController.text = user['role'];
                                          selectedStatus =
                                              user['status']
                                                  ? 'Hoạt động'
                                                  : 'Đã khóa';
                                        });
                                      },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (isEditing) ...[
              // Thay đổi màu nền bên ngoài form chỉnh sửa
              Container(
                color: Colors.white.withOpacity(0.5), // Màu nền trong suốt
                child: Center(
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        33,
                        142,
                        243,
                      ), // Màu nền xanh dương cho form
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Tên người dùng',
                            enabled: false, // Chỉ để xem
                            fillColor: const Color.fromARGB(255, 242, 239, 239),
                            filled: true,
                          ),
                        ),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            enabled: false, // Chỉ để xem
                            fillColor: const Color.fromARGB(255, 242, 239, 239),
                            filled: true,
                          ),
                        ),
                        TextField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            labelText: 'Số điện thoại',
                            enabled: false, // Chỉ để xem
                            fillColor: const Color.fromARGB(255, 242, 239, 239),
                            filled: true,
                          ),
                        ),
                        TextField(
                          controller: roleController,
                          decoration: InputDecoration(
                            labelText: 'Vai trò',
                            enabled: false, // Chỉ để xem
                            fillColor: const Color.fromARGB(255, 242, 239, 239),
                            filled: true,
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: InputDecoration(labelText: 'Trạng thái'),
                          items: [
                            DropdownMenuItem(
                              child: Text('Hoạt động'),
                              value: 'Hoạt động',
                            ),
                            DropdownMenuItem(
                              child: Text('Đã khóa'),
                              value: 'Đã khóa',
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value!;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () => updateUser(editUser['_id']),
                              child: Text('Cập nhật'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isEditing = false;
                                  editUser = {};
                                  nameController.clear();
                                  emailController.clear();
                                  phoneController.clear();
                                  roleController.clear();
                                });
                              },
                              child: Text('Hủy'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
