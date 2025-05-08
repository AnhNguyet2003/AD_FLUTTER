// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dashboard_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();
//   bool _showPassword = false;
//   bool _showForgotPassword = false;
//   bool _showResetPassword = false;
//   String _otp = '';

//   Future<void> _login(BuildContext context) async {
//     final String email = _emailController.text;
//     final String password = _passwordController.text;

//     // Kiểm tra xem email và mật khẩu có được nhập đầy đủ không
//     if (email.isEmpty || password.isEmpty) {
//       _showAlert(context, 'Lỗi', 'Thiếu dữ liệu yêu cầu');
//       return;
//     }

//     // Kiểm tra email
//     if (email != "21110264@student.hcmute.edu.vn") {
//       _showAlert(context, 'Lỗi', 'Email hoặc mật khẩu sai');
//       return;
//     }

//     // Gọi API đăng nhập
//     final response = await http.post(
//       Uri.parse('http://192.168.81.30:5000/api/user/login'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({'email': email, 'password': password}),
//     );

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> responseData = json.decode(response.body);
//       final String accessToken = responseData['accessToken'];

//       // Lưu access token vào SharedPreferences
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('accessToken', accessToken);

//       // Navigate to DashboardScreen
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => DashboardScreen()),
//       );
//     } else {
//       final Map<String, dynamic> responseData = json.decode(response.body);
//       String errorMessage = responseData['mess'] ?? 'Đăng nhập thất bại';
//       _showAlert(context, 'Lỗi', errorMessage);
//     }
//   }

//   void _showAlert(BuildContext context, String title, String message) {
//     showDialog(
//       context: context,
//       builder:
//           (ctx) => AlertDialog(
//             title: Text(title),
//             content: Text(message),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(ctx).pop();
//                 },
//                 child: Text('Đóng'),
//               ),
//             ],
//           ),
//     );
//   }

//   Future<void> _handleForgotPassword() async {
//     final String email = _emailController.text;

//     // Kiểm tra xem email có được nhập không
//     if (email.isEmpty) {
//       _showAlert(context, 'Lỗi', 'Vui lòng nhập email');
//       return;
//     }

//     try {
//       final response = await http.post(
//         Uri.parse('http://192.168.81.30:5000/api/user/forgetpassword'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'email': email}),
//       );

//       final Map<String, dynamic> responseData = json.decode(response.body);
//       String message = responseData['mess'] ?? 'Thao tác không thành công';
//       _showAlert(context, 'Thông báo', message);
//       setState(() {
//         _showForgotPassword = false;
//         _showResetPassword = true; // Hiển thị form thay đổi mật khẩu
//       });
//     } catch (e) {
//       _showAlert(context, 'Lỗi', 'Có lỗi xảy ra, vui lòng thử lại.');
//     }
//   }

//   Future<void> _handleResetPassword() async {
//     final String email = _emailController.text;
//     final String password = _passwordController.text;
//     final String confirmPassword = _confirmPasswordController.text;

//     if (password != confirmPassword) {
//       _showAlert(
//         context,
//         'Lỗi',
//         'Mật khẩu mới và xác nhận mật khẩu không khớp.',
//       );
//       return;
//     }

//     try {
//       final response = await http.put(
//         Uri.parse('http://192.168.81.30:5000/api/user/resetpassword'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'email': email, 'otp': _otp, 'password': password}),
//       );

//       final Map<String, dynamic> responseData = json.decode(response.body);
//       String message = responseData['mess'] ?? 'Thao tác không thành công';

//       if (responseData['success']) {
//         // Nếu cập nhật thành công, chuyển về màn hình đăng nhập
//         _showAlert(context, 'Thông báo', message);
//         setState(() {
//           _showResetPassword = false;
//           _emailController.clear();
//           _passwordController.clear();
//           _confirmPasswordController.clear();
//         });
//       } else {
//         _showAlert(context, 'Lỗi', message);
//       }
//     } catch (e) {
//       _showAlert(context, 'Lỗi', 'Có lỗi xảy ra, vui lòng thử lại.');
//     }
//   }

//   void _togglePasswordVisibility() {
//     setState(() {
//       _showPassword = !_showPassword;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Đăng Nhập')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             if (!_showForgotPassword && !_showResetPassword) ...[
//               TextField(
//                 controller: _emailController,
//                 decoration: InputDecoration(labelText: 'Email'),
//               ),
//               TextField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Mật khẩu',
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _showPassword ? Icons.visibility : Icons.visibility_off,
//                     ),
//                     onPressed: _togglePasswordVisibility,
//                   ),
//                 ),
//                 obscureText: !_showPassword,
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () => _login(context),
//                 child: Text('Đăng Nhập'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     _showForgotPassword = true;
//                   });
//                 },
//                 child: Text('Quên mật khẩu?'),
//               ),
//             ] else if (_showForgotPassword) ...[
//               TextField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Nhập email để lấy lại mật khẩu',
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: _handleForgotPassword,
//                 child: Text('Gửi Email'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     _showForgotPassword = false;
//                   });
//                 },
//                 child: Text('Quay lại đăng nhập'),
//               ),
//             ] else if (_showResetPassword) ...[
//               TextField(
//                 controller: _emailController,
//                 decoration: InputDecoration(labelText: 'Email'),
//               ),
//               TextField(
//                 controller: TextEditingController(text: _otp),
//                 decoration: InputDecoration(labelText: 'Nhập OTP'),
//                 onChanged: (value) {
//                   _otp = value;
//                 },
//               ),
//               TextField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Mật khẩu mới',
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _showPassword ? Icons.visibility : Icons.visibility_off,
//                     ),
//                     onPressed: _togglePasswordVisibility,
//                   ),
//                 ),
//                 obscureText: !_showPassword,
//               ),
//               TextField(
//                 controller: _confirmPasswordController,
//                 decoration: InputDecoration(labelText: 'Xác nhận mật khẩu mới'),
//                 obscureText: !_showPassword,
//               ),
//               ElevatedButton(
//                 onPressed: _handleResetPassword,
//                 child: Text('Cập nhật mật khẩu'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     _showResetPassword = false;
//                   });
//                 },
//                 child: Text('Quay lại'),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _showPassword = false;
  bool _showForgotPassword = false;
  bool _showResetPassword = false;
  String _otp = '';

  Future<void> _login(BuildContext context) async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    // Kiểm tra xem email và mật khẩu có được nhập đầy đủ không
    if (email.isEmpty || password.isEmpty) {
      _showAlert(context, 'Lỗi', 'Thiếu dữ liệu yêu cầu');
      return;
    }

    // Kiểm tra email
    if (email != "21110264@student.hcmute.edu.vn") {
      _showAlert(context, 'Lỗi', 'Email hoặc mật khẩu sai');
      return;
    }

    // Gọi API đăng nhập
    final response = await http.post(
      Uri.parse('http://192.168.81.30:5000/api/user/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String accessToken = responseData['accessToken'];

      // Lưu access token vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', accessToken);

      // Navigate to DashboardScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } else {
      final Map<String, dynamic> responseData = json.decode(response.body);
      String errorMessage = responseData['mess'] ?? 'Đăng nhập thất bại';
      _showAlert(context, 'Lỗi', errorMessage);
    }
  }

  void _showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text('Đóng'),
              ),
            ],
          ),
    );
  }

  Future<void> _handleForgotPassword() async {
    final String email = _emailController.text;

    // Kiểm tra xem email có được nhập không
    if (email.isEmpty) {
      _showAlert(context, 'Lỗi', 'Vui lòng nhập email');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.81.30:5000/api/user/forgetpassword'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        String message = responseData['mess'] ?? 'Vui lòng kiểm tra email';
        _showAlert(context, 'Thông báo', message);
        setState(() {
          _showForgotPassword = false;
          _showResetPassword = true; // Hiển thị form thay đổi mật khẩu
        });
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        String message = responseData['mess'] ?? 'Vui lòng kiểm tra email';
        _showAlert(context, 'Thông báo', message);
      }
    } catch (e) {
      _showAlert(context, 'Lỗi', 'Có lỗi xảy ra, vui lòng thử lại.');
    }
  }

  Future<void> _handleResetPassword() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      _showAlert(
        context,
        'Lỗi',
        'Mật khẩu mới và xác nhận mật khẩu không khớp.',
      );
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('http://192.168.81.30:5000/api/user/resetpassword'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'otp': _otp, 'password': password}),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);
      String message = responseData['mess'] ?? 'Thao tác không thành công';

      if (responseData['success']) {
        // Nếu cập nhật thành công, chuyển về màn hình đăng nhập
        _showAlert(context, 'Thông báo', message);
        setState(() {
          _showResetPassword = false;
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
        });
      } else {
        _showAlert(context, 'Lỗi', message);
      }
    } catch (e) {
      _showAlert(context, 'Lỗi', 'Có lỗi xảy ra, vui lòng thử lại.');
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng Nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!_showForgotPassword && !_showResetPassword) ...[
              Text(
                'ĐĂNG NHẬP',
                style: TextStyle(
                  fontSize: 24, // Kích thước chữ
                  fontWeight: FontWeight.bold, // Đậm
                  color: Colors.black, // Màu chữ
                ),
              ),
              SizedBox(height: 20),
              // Hình ảnh trên trường nhập email
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Image.asset('lib/assets/loginadmin.jpg', height: 200),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                obscureText: !_showPassword,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _login(context),
                child: Text('Đăng Nhập'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showForgotPassword = true;
                  });
                },
                child: Text('Quên mật khẩu?'),
              ),
            ] else if (_showForgotPassword) ...[
              Text(
                'QUÊN MẬT KHẨU',
                style: TextStyle(
                  fontSize: 24, // Kích thước chữ
                  fontWeight: FontWeight.bold, // Đậm
                  color: Colors.black, // Màu chữ
                ),
              ),
              SizedBox(height: 20),
              // Hình ảnh trong form quên mật khẩu
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Image.asset('lib/assets/fogot-icon.png', height: 200),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Nhập email để lấy lại mật khẩu',
                ),
              ),
              ElevatedButton(
                onPressed: _handleForgotPassword,
                child: Text('Gửi Email'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showForgotPassword = false;
                  });
                },
                child: Text('Quay lại đăng nhập'),
              ),
            ] else if (_showResetPassword) ...[
              Text(
                'QUÊN MẬT KHẨU',
                style: TextStyle(
                  fontSize: 24, // Kích thước chữ
                  fontWeight: FontWeight.bold, // Đậm
                  color: Colors.black, // Màu chữ
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Image.asset('lib/assets/fogot-icon.png', height: 200),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: TextEditingController(text: _otp),
                decoration: InputDecoration(labelText: 'Nhập OTP'),
                onChanged: (value) {
                  _otp = value;
                },
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu mới',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                obscureText: !_showPassword,
              ),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'Xác nhận mật khẩu mới'),
                obscureText: !_showPassword,
              ),
              ElevatedButton(
                onPressed: _handleResetPassword,
                child: Text('Cập nhật mật khẩu'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showResetPassword = false;
                  });
                },
                child: Text('Quay lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
