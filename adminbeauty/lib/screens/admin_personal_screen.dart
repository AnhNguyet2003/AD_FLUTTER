// import 'package:flutter/material.dart';
// import 'base_screen.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:another_flushbar/flushbar.dart';
// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'login_screen.dart'; // Import màn hình đăng nhập

// class AdminPersonalScreen extends StatefulWidget {
//   @override
//   _AdminPersonalScreenState createState() => _AdminPersonalScreenState();
// }

// class _AdminPersonalScreenState extends State<AdminPersonalScreen> {
//   final nameController = TextEditingController();
//   final addressController = TextEditingController();
//   final phoneController = TextEditingController();
//   final birthdayController = TextEditingController();
//   File? avatar;
//   bool isLoading = false; // Biến trạng thái cho loading
//   String password = '';
//   String newPassword = '';
//   String? passwordError;
//   String? newPasswordError;
//   Map<String, dynamic>? userData; // Biến để lưu dữ liệu người dùng
//   bool isPickingImage = false;

//   // Biến để kiểm soát việc hiển thị mật khẩu
//   bool _isPasswordVisible = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchUserData();
//   }

//   // Hàm lấy thông tin người dùng từ API
//   Future<void> fetchUserData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String? accessToken = prefs.getString('accessToken');

//       final response = await http.get(
//         Uri.parse('http://192.168.81.30:5000/api/user/current'),
//         headers: {'Authorization': 'Bearer $accessToken'},
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success']) {
//           setState(() {
//             userData = data['rs']; // Lưu dữ liệu người dùng vào biến
//             nameController.text = userData!['name'];
//             addressController.text = userData!['address'];
//             phoneController.text = userData!['phone'];
//             birthdayController.text = DateFormat(
//               'yyyy-MM-dd',
//             ).format(DateTime.parse(userData!['birthday']));
//             avatar = null; // Reset avatar nếu cần
//           });
//         } else {
//           showFlushbar('Lỗi: ${data['rs']}', Colors.red);
//         }
//       } else {
//         showFlushbar(
//           'Lỗi khi lấy thông tin người dùng: ${response.reasonPhrase}',
//           Colors.red,
//         );
//       }
//     } catch (e) {
//       print("Lỗi khi lấy thông tin người dùng: $e");
//       showFlushbar('Có lỗi xảy ra, vui lòng thử lại', Colors.red);
//     }
//   }

//   // Hàm hiển thị Flushbar
//   void showFlushbar(String message, Color color) {
//     Flushbar(
//       message: message,
//       duration: Duration(seconds: 3),
//       flushbarStyle: FlushbarStyle.GROUNDED,
//       backgroundColor: color,
//     )..show(context);
//   }

//   // Hàm cập nhật thông tin người dùng
//   Future<void> handleUpdateInfo() async {
//     final prefs = await SharedPreferences.getInstance();
//     String? accessToken = prefs.getString('accessToken');

//     final formData = {
//       'name': nameController.text,
//       'address': addressController.text,
//       'phone': phoneController.text,
//       'birthday': birthdayController.text,
//       'avatar': avatar != null ? avatar!.path : null,
//     };

//     final cleanedFormData = formData.map((key, value) {
//       return MapEntry(key, value ?? '');
//     });

//     final request = http.MultipartRequest(
//       'PUT',
//       Uri.parse('http://192.168.81.30:5000/api/user/customer'),
//     );
//     request.headers['Authorization'] =
//         'Bearer $accessToken'; // Thêm token vào tiêu đề
//     request.fields.addAll(cleanedFormData);
//     if (avatar != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('avatar', avatar!.path),
//       );
//     }

//     setState(() {
//       isLoading = true; // Bắt đầu hiển thị loading
//     });

//     final response = await request.send();
//     final responseBody = await http.Response.fromStream(response);
//     print("CN " + responseBody.body);

//     setState(() {
//       isLoading = false; // Kết thúc hiển thị loading
//     });

//     if (response.statusCode == 200) {
//       showFlushbar('Cập nhật thông tin thành công', Colors.green);
//     } else {
//       showFlushbar('Cập nhật thất bại: ${responseBody.body}', Colors.red);
//     }
//   }

//   // Hàm xử lý đổi mật khẩu
//   Future<void> handleResetPassword() async {
//     final prefs = await SharedPreferences.getInstance();
//     String? accessToken = prefs.getString('accessToken');

//     if (password.isNotEmpty && newPassword.isNotEmpty) {
//       setState(() {
//         isLoading = true; // Bắt đầu hiển thị loading
//       });

//       try {
//         final response = await http.put(
//           Uri.parse(
//             'http://192.168.81.30:5000/api/user/customer/resetpassword',
//           ),
//           headers: {
//             'Authorization': 'Bearer $accessToken',
//             'Content-Type': 'application/json',
//           },
//           body: jsonEncode({
//             'currentPassword': password,
//             'newPassword': newPassword,
//           }),
//         );

//         setState(() {
//           isLoading = false; // Kết thúc hiển thị loading
//         });

//         if (response.statusCode == 200) {
//           Navigator.of(context).pop(); // Đóng dialog
//           final data = jsonDecode(response.body);
//           showFlushbar(
//             data['mess'],
//             Colors.green,
//           ); // Hiển thị thông báo thành công
//         } else {
//           final data = jsonDecode(response.body);
//           showFlushbar(data['mess'], Colors.red); // Hiển thị thông báo lỗi
//         }
//       } catch (e) {
//         setState(() {
//           isLoading = false; // Kết thúc hiển thị loading nếu có lỗi
//         });
//         showFlushbar(
//           'Đã xảy ra lỗi, vui lòng thử lại.',
//           Colors.red,
//         ); // Thông báo lỗi chung
//       }
//     } else {
//       setState(() {
//         passwordError =
//             password.isEmpty ? 'Vui lòng nhập mật khẩu hiện tại' : null;
//         newPasswordError =
//             newPassword.isEmpty ? 'Vui lòng nhập mật khẩu mới' : null;
//       });
//     }
//   }

//   // Hàm chọn ảnh
//   Future<void> handleChooseImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.getImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         avatar = File(pickedFile.path);
//       });
//     }
//   }

//   // Hàm xử lý đăng xuất
//   Future<void> handleLogout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('accessToken'); // Xóa token
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => LoginScreen(),
//       ), // Chuyển đến màn hình đăng nhập
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BaseScreen(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Khung tròn hiển thị ảnh người dùng
//             Stack(
//               alignment: Alignment.bottomLeft,
//               children: [
//                 CircleAvatar(
//                   radius: 60,
//                   backgroundImage:
//                       avatar != null
//                           ? FileImage(avatar!)
//                           : (userData?['avatar'] != null &&
//                               userData!['avatar'].isNotEmpty)
//                           ? NetworkImage(userData!['avatar'])
//                           : null,
//                   child:
//                       avatar == null &&
//                               (userData?['avatar'] == null ||
//                                   userData!['avatar'].isEmpty)
//                           ? Icon(Icons.person, size: 60)
//                           : null,
//                 ),
//                 Positioned(
//                   bottom: 0,
//                   left: 0,
//                   child: GestureDetector(
//                     onTap: handleChooseImage,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.blue,
//                       ),
//                       child: Icon(Icons.camera_alt, color: Colors.white),
//                       padding: EdgeInsets.all(8),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Thông tin cá nhân',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             TextField(
//               controller: nameController,
//               decoration: InputDecoration(labelText: 'Tên của bạn'),
//             ),
//             TextField(
//               controller: addressController,
//               decoration: InputDecoration(labelText: 'Địa chỉ của bạn'),
//             ),
//             TextField(
//               controller: phoneController,
//               decoration: InputDecoration(labelText: 'Số điện thoại'),
//             ),
//             TextField(
//               controller: birthdayController,
//               decoration: InputDecoration(labelText: 'Ngày sinh'),
//               readOnly: true,
//               onTap: () async {
//                 DateTime? pickedDate = await showDatePicker(
//                   context: context,
//                   initialDate: DateTime.now(),
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime(2100),
//                 );
//                 if (pickedDate != null) {
//                   birthdayController.text = DateFormat(
//                     'yyyy-MM-dd',
//                   ).format(pickedDate);
//                 }
//               },
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: isLoading ? null : handleUpdateInfo,
//               child:
//                   isLoading
//                       ? CircularProgressIndicator()
//                       : Text('Cập nhật thông tin'),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 showDialog(
//                   context: context,
//                   builder: (BuildContext context) {
//                     return AlertDialog(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                       content: StatefulBuilder(
//                         builder: (context, setState) {
//                           return Container(
//                             width: double.maxFinite,
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   'Đổi mật khẩu',
//                                   style: TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 TextField(
//                                   decoration: InputDecoration(
//                                     labelText: 'Mật khẩu hiện tại',
//                                     errorText: passwordError,
//                                   ),
//                                   obscureText: !_isPasswordVisible,
//                                   onChanged:
//                                       (value) =>
//                                           setState(() => password = value),
//                                 ),
//                                 TextField(
//                                   decoration: InputDecoration(
//                                     labelText: 'Mật khẩu mới',
//                                     errorText: newPasswordError,
//                                   ),
//                                   obscureText: !_isPasswordVisible,
//                                   onChanged:
//                                       (value) =>
//                                           setState(() => newPassword = value),
//                                 ),
//                                 TextButton(
//                                   onPressed: () {
//                                     setState(() {
//                                       _isPasswordVisible = !_isPasswordVisible;
//                                     });
//                                   },
//                                   child: Text(
//                                     _isPasswordVisible
//                                         ? 'Ẩn mật khẩu'
//                                         : 'Hiện mật khẩu',
//                                   ),
//                                 ),
//                                 SizedBox(height: 16),
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     ElevatedButton(
//                                       onPressed: handleResetPassword,
//                                       child:
//                                           isLoading
//                                               ? CircularProgressIndicator()
//                                               : Text('Xác nhận'),
//                                     ),
//                                     TextButton(
//                                       onPressed: () {
//                                         Navigator.of(
//                                           context,
//                                         ).pop(); // Đóng dialog
//                                       },
//                                       child: Text('Hủy'),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 );
//               },
//               child: Text('Đổi mật khẩu'),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: handleLogout, // Gọi hàm đăng xuất
//               child: Text('Đăng xuất'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'base_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:another_flushbar/flushbar.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart'; // Import màn hình đăng nhập

class AdminPersonalScreen extends StatefulWidget {
  @override
  _AdminPersonalScreenState createState() => _AdminPersonalScreenState();
}

class _AdminPersonalScreenState extends State<AdminPersonalScreen> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final birthdayController = TextEditingController();
  File? avatar;
  bool isLoading = false; // Biến trạng thái cho loading
  String password = '';
  String newPassword = '';
  String? passwordError;
  String? newPasswordError;
  Map<String, dynamic>? userData; // Biến để lưu dữ liệu người dùng
  bool isPickingImage =
      false; // Biến trạng thái để kiểm soát việc chọn hình ảnh
  bool _isPasswordVisible = false; // Biến để kiểm soát việc hiển thị mật khẩu

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // Hàm lấy thông tin người dùng từ API
  Future<void> fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      final response = await http.get(
        Uri.parse('http://192.168.81.30:5000/api/user/current'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            userData = data['rs']; // Lưu dữ liệu người dùng vào biến
            nameController.text = userData!['name'];
            addressController.text = userData!['address'];
            phoneController.text = userData!['phone'];
            birthdayController.text = DateFormat(
              'yyyy-MM-dd',
            ).format(DateTime.parse(userData!['birthday']));
            avatar = null; // Reset avatar nếu cần
          });
        } else {
          showFlushbar('Lỗi: ${data['rs']}', Colors.red);
        }
      } else {
        showFlushbar(
          'Lỗi khi lấy thông tin người dùng: ${response.reasonPhrase}',
          Colors.red,
        );
      }
    } catch (e) {
      print("Lỗi khi lấy thông tin người dùng: $e");
      showFlushbar('Có lỗi xảy ra, vui lòng thử lại', Colors.red);
    }
  }

  // Hàm hiển thị Flushbar
  void showFlushbar(String message, Color color) {
    Flushbar(
      message: message,
      duration: Duration(seconds: 3),
      flushbarStyle: FlushbarStyle.GROUNDED,
      backgroundColor: color,
    )..show(context);
  }

  // Hàm cập nhật thông tin người dùng
  Future<void> handleUpdateInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    final formData = {
      'name': nameController.text,
      'address': addressController.text,
      'phone': phoneController.text,
      'birthday': birthdayController.text,
      'avatar': avatar != null ? avatar!.path : null,
    };

    final cleanedFormData = formData.map((key, value) {
      return MapEntry(key, value ?? '');
    });

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('http://192.168.81.30:5000/api/user/customer'),
    );
    request.headers['Authorization'] =
        'Bearer $accessToken'; // Thêm token vào tiêu đề
    request.fields.addAll(cleanedFormData);
    if (avatar != null) {
      request.files.add(
        await http.MultipartFile.fromPath('avatar', avatar!.path),
      );
    }

    setState(() {
      isLoading = true; // Bắt đầu hiển thị loading
    });

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);
    print("CN " + responseBody.body);

    setState(() {
      isLoading = false; // Kết thúc hiển thị loading
    });

    if (response.statusCode == 200) {
      showFlushbar('Cập nhật thông tin thành công', Colors.green);
    } else {
      showFlushbar('Cập nhật thất bại: ${responseBody.body}', Colors.red);
    }
  }

  // Hàm xử lý đổi mật khẩu
  Future<void> handleResetPassword() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    if (password.isNotEmpty && newPassword.isNotEmpty) {
      setState(() {
        isLoading = true; // Bắt đầu hiển thị loading
      });

      try {
        final response = await http.put(
          Uri.parse(
            'http://192.168.81.30:5000/api/user/customer/resetpassword',
          ),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'currentPassword': password,
            'newPassword': newPassword,
          }),
        );

        setState(() {
          isLoading = false; // Kết thúc hiển thị loading
        });

        if (response.statusCode == 200) {
          Navigator.of(context).pop(); // Đóng dialog
          final data = jsonDecode(response.body);
          showFlushbar(
            data['mess'],
            Colors.green,
          ); // Hiển thị thông báo thành công
        } else {
          final data = jsonDecode(response.body);
          showFlushbar(data['mess'], Colors.red); // Hiển thị thông báo lỗi
        }
      } catch (e) {
        setState(() {
          isLoading = false; // Kết thúc hiển thị loading nếu có lỗi
        });
        showFlushbar(
          'Đã xảy ra lỗi, vui lòng thử lại.',
          Colors.red,
        ); // Thông báo lỗi chung
      }
    } else {
      setState(() {
        passwordError =
            password.isEmpty ? 'Vui lòng nhập mật khẩu hiện tại' : null;
        newPasswordError =
            newPassword.isEmpty ? 'Vui lòng nhập mật khẩu mới' : null;
      });
    }
  }

  // Hàm chọn ảnh
  Future<void> handleChooseImage() async {
    if (isPickingImage) return; // Nếu đã đang mở, không thực hiện thêm

    setState(() {
      isPickingImage = true; // Đánh dấu đang mở trình chọn hình ảnh
    });

    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      isPickingImage = false; // Đánh dấu đã hoàn tất
    });

    if (pickedFile != null) {
      setState(() {
        avatar = File(pickedFile.path);
      });
    }
  }

  // Hàm xử lý đăng xuất
  Future<void> handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken'); // Xóa token
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ), // Chuyển đến màn hình đăng nhập
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Khung tròn hiển thị ảnh người dùng
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      avatar != null
                          ? FileImage(avatar!)
                          : (userData?['avatar'] != null &&
                              userData!['avatar'].isNotEmpty)
                          ? NetworkImage(userData!['avatar'])
                          : null,
                  child:
                      avatar == null &&
                              (userData?['avatar'] == null ||
                                  userData!['avatar'].isEmpty)
                          ? Icon(Icons.person, size: 60)
                          : null,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: GestureDetector(
                    onTap: handleChooseImage,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: Icon(Icons.camera_alt, color: Colors.white),
                      padding: EdgeInsets.all(8),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Thông tin cá nhân',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Tên của bạn'),
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Địa chỉ của bạn'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Số điện thoại'),
            ),
            TextField(
              controller: birthdayController,
              decoration: InputDecoration(labelText: 'Ngày sinh'),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  birthdayController.text = DateFormat(
                    'yyyy-MM-dd',
                  ).format(pickedDate);
                }
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : handleUpdateInfo,
              child:
                  isLoading
                      ? CircularProgressIndicator()
                      : Text('Cập nhật thông tin'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      content: StatefulBuilder(
                        builder: (context, setState) {
                          return Container(
                            width: double.maxFinite,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Đổi mật khẩu',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Mật khẩu hiện tại',
                                    errorText: passwordError,
                                  ),
                                  obscureText: !_isPasswordVisible,
                                  onChanged:
                                      (value) =>
                                          setState(() => password = value),
                                ),
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Mật khẩu mới',
                                    errorText: newPasswordError,
                                  ),
                                  obscureText: !_isPasswordVisible,
                                  onChanged:
                                      (value) =>
                                          setState(() => newPassword = value),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                  child: Text(
                                    _isPasswordVisible
                                        ? 'Ẩn mật khẩu'
                                        : 'Hiện mật khẩu',
                                  ),
                                ),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: handleResetPassword,
                                      child:
                                          isLoading
                                              ? CircularProgressIndicator()
                                              : Text('Xác nhận'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(
                                          context,
                                        ).pop(); // Đóng dialog
                                      },
                                      child: Text('Hủy'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              child: Text('Đổi mật khẩu'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: handleLogout, // Gọi hàm đăng xuất
              child: Text('Đăng xuất'),
            ),
          ],
        ),
      ),
    );
  }
}
