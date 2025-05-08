import 'oder_management_screen.dart';
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'product_management_screen.dart';
import 'user_management_screen.dart';
import 'category_management__screen.dart'; // Sửa lỗi chính tả
import 'admin_personal_screen.dart';

class BaseScreen extends StatelessWidget {
  final Widget child;

  const BaseScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý hệ thống'),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Center(
                child: Image.asset(
                  'lib/assets/logo.png', // Đường dẫn đến logo
                  fit: BoxFit.cover, // Điều chỉnh cách hiển thị
                ),
              ),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              title: Text('Dashboard'),
              leading: Icon(Icons.dashboard),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Quản lý Người dùng'),
              leading: Icon(Icons.group),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Quản lý Danh mục'),
              leading: Icon(Icons.category),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Quản lý Sản phẩm'),
              leading: Icon(Icons.shopping_cart),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Quản lý Đơn hàng'),
              leading: Icon(Icons.list_alt),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Thông tin Quản lý'),
              leading: Icon(Icons.person),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminPersonalScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}
