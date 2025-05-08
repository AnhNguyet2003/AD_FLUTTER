import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'base_screen.dart'; // Import BaseScreen

class Order {
  String id;
  String recipient;
  String address;
  String phone;
  String status;
  double total;
  DateTime createdAt;

  Order({
    required this.id,
    required this.recipient,
    required this.address,
    required this.phone,
    required this.status,
    required this.total,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] is String ? json['_id'] : json['_id'].toString(),
      recipient:
          json['recipient'] is String
              ? json['recipient']
              : json['recipient'].toString(),
      address:
          json['address'] is String
              ? json['address']
              : json['address'].toString(),
      phone: json['phone'] is String ? json['phone'] : json['phone'].toString(),
      status:
          json['status'] is String ? json['status'] : json['status'].toString(),
      total:
          (json['total'] is double
              ? json['total']
              : (json['total'] as int).toDouble()),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class OrderManagementScreen extends StatefulWidget {
  @override
  _OrderManagementScreenState createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  List<Order> _orders = [];
  String _currentStatus = "All"; // Giá trị mặc định là tiếng Anh
  bool _isLoading = true;

  final Map<String, String> _statusMap = {
    'All': 'Tất cả',
    'Pending': 'Chờ xác nhận',
    'Shipped': 'Hoàn thành',
    'Confirmed': 'Đang giao',
    'Cancelled': 'Đã hủy',
  };

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      final response = await http.get(
        Uri.parse('http://192.168.81.30:5000/api/bill/admin'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      final Map<String, dynamic> jsonData = json.decode(response.body);
      print("RS " + jsonData.toString());
      if (jsonData['success']) {
        setState(() {
          _orders =
              (jsonData['result'] as List)
                  .map((order) => Order.fromJson(order))
                  .toList();
        });
      } else {
        _showFlushbar('Lỗi khi lấy đơn hàng');
      }
    } catch (e) {
      print("LỖI " + e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showFlushbar(String message) {
    Flushbar(message: message, duration: Duration(seconds: 3))..show(context);
  }

  Future<void> _updateOrder(String id, String currentStatus) async {
    String newStatus;

    // Xác định trạng thái mới dựa trên trạng thái hiện tại
    if (currentStatus == "Pending") {
      newStatus = "Confirmed";
    } else if (currentStatus == "Confirmed") {
      newStatus = "Shipped";
    } else {
      // Nếu không phải là trạng thái hợp lệ để cập nhật, kết thúc hàm
      _showFlushbar('Trạng thái không thể cập nhật');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      final response = await http.put(
        Uri.parse('http://192.168.81.30:5000/api/bill/status/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({'status': newStatus}),
      );

      final Map<String, dynamic> jsonData = json.decode(response.body);
      if (jsonData['success']) {
        setState(() {
          final order = _orders.firstWhere((order) => order.id == id);
          order.status = newStatus;
        });
        _showFlushbar('Cập nhật đơn hàng thành công');
      } else {
        _showFlushbar('Lỗi khi cập nhật đơn hàng');
      }
    } catch (e) {
      print("LỖI " + e.toString());
      _showFlushbar('Có lỗi xảy ra, vui lòng thử lại');
    }
  }

  Future<void> _cancelOrder(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      final response = await http.put(
        Uri.parse('http://192.168.81.30:5000/api/bill/status/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({'status': 'Cancelled'}),
      );

      final Map<String, dynamic> jsonData = json.decode(response.body);
      if (jsonData['success']) {
        setState(() {
          final order = _orders.firstWhere((order) => order.id == id);
          order.status = 'Cancelled';
        });
        _showFlushbar('Hủy đơn hàng thành công');
      } else {
        _showFlushbar(
          jsonData['mess'] ?? 'Lỗi khi hủy đơn hàng',
        ); // Sử dụng thông báo từ phản hồi nếu có
      }
    } catch (e) {
      print("LỖI " + e.toString());
      _showFlushbar('Có lỗi xảy ra, vui lòng thử lại');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders =
        _currentStatus == "All"
            ? _orders
            : _orders.where((order) => order.status == _currentStatus).toList();

    return BaseScreen(
      child: Scaffold(
        appBar: AppBar(title: Text('Quản lý đơn hàng'), centerTitle: true),
        body:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: DropdownButton<String>(
                        value: _currentStatus,
                        icon: Icon(Icons.arrow_drop_down),
                        onChanged: (String? newValue) {
                          setState(() {
                            _currentStatus = newValue!;
                          });
                        },
                        items:
                            _statusMap.keys.map<DropdownMenuItem<String>>((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(_statusMap[value]!),
                              );
                            }).toList(),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(
                                order.recipient,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Địa chỉ: ${order.address}\n'
                                'Số điện thoại: ${order.phone}\n'
                                'Tổng tiền: ${order.total} VND\n',
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed:
                                        order.status == "Shipped" ||
                                                order.status == "Cancelled" ||
                                                order.status == "Confirmed"
                                            ? null
                                            : () => _updateOrder(
                                              order.id,
                                              order.status,
                                            ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue, // Màu nền
                                      foregroundColor: Colors.white, // Màu chữ
                                    ),
                                    child: Row(
                                      children: [
                                        if (order.status == "Shipped")
                                          Icon(
                                            Icons.check_circle,
                                            color: const Color.fromARGB(
                                              255,
                                              33,
                                              143,
                                              34,
                                            ),
                                            size: 20,
                                          ) // Biểu tượng cho "Hoàn thành"
                                        else if (order.status == "Cancelled")
                                          Icon(
                                            Icons.cancel,
                                            color: const Color.fromARGB(
                                              255,
                                              238,
                                              58,
                                              58,
                                            ),
                                            size: 20,
                                          ) // Biểu tượng cho "Đã hủy"
                                        else
                                          SizedBox.shrink(), // Nếu không có biểu tượng, không hiển thị gì
                                        SizedBox(
                                          width: 4,
                                        ), // Khoảng cách giữa biểu tượng và văn bản
                                        Text(
                                          order.status == "Pending"
                                              ? "Chờ xác nhận"
                                              : order.status == "Confirmed"
                                              ? "Đang giao"
                                              : order.status == "Shipped"
                                              ? "Hoàn thành"
                                              : order.status == "Cancelled"
                                              ? "Đã hủy"
                                              : "",
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ), // Khoảng cách giữa các nút
                                  if (order.status == "Pending")
                                    ElevatedButton(
                                      onPressed: () => _cancelOrder(order.id),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.red, // Màu nền cho nút hủy
                                        foregroundColor:
                                            Colors.white, // Màu chữ
                                      ),
                                      child: Text("Hủy"),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
