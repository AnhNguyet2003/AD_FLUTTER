import 'oder_management_screen.dart';
import 'package:flutter/material.dart';
import 'product_management_screen.dart';
import 'user_management_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard Admin')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              title: Text('Quản lý Sản phẩm'),
              leading: Icon(Icons.shopping_cart),
              onTap: () {
                Navigator.push(
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Quản lý Người dùng'),
              leading: Icon(Icons.person),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserManagementScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(child: Text('Welcome to the Admin Dashboard')),
    );
  }
}
