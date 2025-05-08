import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'base_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime? startDate;
  DateTime? endDate;
  bool loading = false;
  int totalRevenue = 0; // Biến để lưu tổng doanh thu

  @override
  void initState() {
    super.initState();
    fetchOrders(); // Gọi API khi khởi tạo
  }

  Future<void> fetchOrders() async {
    setState(() {
      loading = true;
    });

    String start =
        startDate != null ? DateFormat('dd/MM/yyyy').format(startDate!) : '';
    String end =
        endDate != null ? DateFormat('dd/MM/yyyy').format(endDate!) : '';

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    String query = '';
    if (start.isNotEmpty && end.isNotEmpty) {
      query = '?startDate=$start&endDate=$end';
    } else if (start.isNotEmpty) {
      query = '?startDate=$start'; // Chỉ có ngày bắt đầu
    } else {
      query = '?toDay=true'; // Nếu không có ngày, lấy dữ liệu cho hôm nay
    }

    final apiUrl = 'http://192.168.81.30:5000/api/bill/list$query';
    print("API URL: $apiUrl");

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        totalRevenue =
            data['total'] != null ? data['total'] : 0; // Lưu tổng doanh thu
      });
    } else {
      print('Error fetching orders: ${response.body}');
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isStartDate
              ? (startDate ?? DateTime.now())
              : (endDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
      fetchOrders(); // Gọi lại API sau khi chọn ngày
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa cột
          children: [
            Text(
              'Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () => selectDate(context, true),
                  child: Text(
                    startDate == null
                        ? 'Chọn ngày bắt đầu'
                        : 'Ngày bắt đầu: ${DateFormat('dd/MM/yyyy').format(startDate!)}',
                  ),
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () => selectDate(context, false),
                  child: Text(
                    endDate == null
                        ? 'Chọn ngày kết thúc'
                        : 'Ngày kết thúc: ${DateFormat('dd/MM/yyyy').format(endDate!)}',
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            loading
                ? Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    Center(
                      // Căn giữa chữ "Tổng doanh thu"
                      child: Text(
                        'Tổng doanh thu:',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color:
                              Colors.black, // Màu đen cho chữ "Tổng doanh thu"
                        ),
                      ),
                    ),
                    SizedBox(height: 10), // Khoảng cách giữa hai dòng
                    Text(
                      '${NumberFormat.currency(locale: 'vi', symbol: 'VNĐ').format(totalRevenue)}',
                      style: TextStyle(
                        fontSize: 35, // Kích thước chữ lớn hơn
                        fontWeight: FontWeight.bold,
                        color: Colors.red, // Màu đỏ cho số tiền
                      ),
                    ),
                    SizedBox(height: 20), // Khoảng cách giữa số tiền và logo
                    Image.asset(
                      'lib/assets/logo.png', // Đường dẫn đến hình ảnh logo
                      width: 500, // Kích thước chiều rộng logo
                      height: 380, // Kích thước chiều cao logo
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
