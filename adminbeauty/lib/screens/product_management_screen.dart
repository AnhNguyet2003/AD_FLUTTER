import 'package:flutter/material.dart';
import 'base_screen.dart';
import 'package:http/http.dart' as http;
import 'package:another_flushbar/flushbar.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'product_create_screen.dart'; // Import màn hình tạo sản phẩm
import 'product_update_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductManagementScreen extends StatefulWidget {
  @override
  _ProductManagementScreenState createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final ScrollController _scrollController = ScrollController();
  List<dynamic> products = [];
  bool isLoading = false;
  bool hasMore = true;
  int page = 1;
  String? searchQuery;
  TextEditingController _searchController =
      TextEditingController(); // Thêm controller cho ô tìm kiếm

  @override
  void initState() {
    super.initState();
    _fetchProducts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isLoading &&
          hasMore) {
        _fetchProducts();
      }
    });
  }

  Future<void> _fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final String url =
          'http://192.168.81.30:5000/api/product?limit=12&page=$page' +
          (searchQuery != null && searchQuery!.isNotEmpty
              ? '&productName=$searchQuery'
              : '');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      final data = json.decode(response.body);

      if (data['success']) {
        setState(() {
          products.addAll(data['productData']);
          hasMore = data['productData'].length == 12;
          page++;
        });
      } else {
        setState(() {
          products.clear(); // Xóa danh sách sản phẩm nếu không thành công
        });
        // _showFlushbar('Lỗi khi lấy sản phẩm');
      }
    } catch (e) {
      _showFlushbar('Lỗi mạng: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteProduct(String pid) async {
    // Hiển thị hộp thoại xác nhận
    bool confirm = await _showDeleteConfirmationDialog();
    if (!confirm) return; // Nếu không xác nhận, thoát hàm
    print("PID: " + pid);

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      final response = await http.delete(
        Uri.parse('http://192.168.81.30:5000/api/product/$pid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken', // Thêm token vào tiêu đề
        },
      );

      // Giải mã phản hồi
      final data = json.decode(response.body);
      print("Response: " + jsonEncode(data)); // Sử dụng jsonEncode để in ra

      if (data['success']) {
        _showFlushbar('Xóa sản phẩm thành công');
        setState(() {
          products.removeWhere((product) => product['_id'] == pid);
        });
      } else {
        _showFlushbar('Đã có lỗi xảy ra khi xóa sản phẩm');
      }
    } catch (e) {
      print("====" + e.toString());
      _showFlushbar('Lỗi mạng: $e');
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible:
          false, // Người dùng không thể đóng hộp thoại bằng cách chạm ra ngoài
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa sản phẩm này không?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(false); // Trả về false nếu nhấn "Không"
              },
              child: Text('Không'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Trả về true nếu nhấn "Có"
              },
              child: Text('Có'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false); // Đảm bảo trả về false nếu giá trị null
  }

  void _searchProducts() {
    page = 1; // Reset trang khi tìm kiếm
    products.clear(); // Xóa danh sách sản phẩm hiện tại
    _fetchProducts(); // Gọi lại hàm để tìm kiếm
  }

  void _clearSearch() {
    setState(() {
      searchQuery = null; // Đặt lại giá trị tìm kiếm
      _searchController.clear(); // Xóa nội dung ô tìm kiếm
      products.clear(); // Xóa danh sách sản phẩm hiện tại
      page = 1; // Reset trang
    });
    _fetchProducts();
  }

  void _showFlushbar(String message) {
    Flushbar(message: message, duration: Duration(seconds: 3))..show(context);
  }

  // void _navigateToUpdateProduct(String productId) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder:
  //           (context) => ProductUpdateScreen(
  //             productData: products.firstWhere(
  //               (product) => product['_id'] == productId,
  //             ),
  //           ), // Chuyển đến màn hình cập nhật sản phẩm
  //     ),
  //   );
  //}

  void _navigateToUpdateProduct(String productId) {
    // Tìm sản phẩm theo ID
    final product = products.firstWhere(
      (product) => product['_id'] == productId,
    );

    // Chuyển đổi từ điển sang đối tượng Product
    final productData = Product(
      id: product['_id'] as String, // Đảm bảo là String
      productName: product['productName'] as String, // Đảm bảo là String
      price: (product['price'] as num).toDouble(), // Chuyển đổi sang double
      stockQuantity: product['stockQuantity'] as int, // Đảm bảo là int
      description: product['description'] as String, // Đảm bảo là String
      brand: Brand(
        id: product['brand']['_id'] as String, // Đảm bảo là String
        name: product['brand']['brandName'] as String, // Đảm bảo là String
      ),
      category: Category(
        id: product['category']['_id'] as String, // Đảm bảo là String
        name:
            product['category']['categoryName'] as String, // Đảm bảo là String
      ),
    );

    // Chuyển đến màn hình cập nhật sản phẩm
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ProductUpdateScreen(
              editProduct: productData, // Truyền đối tượng Product
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BaseScreen(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Quản lý sản phẩm',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      left: 10,
                    ), // Thêm margin bên trái cho thanh tìm kiếm
                    child: TextField(
                      controller:
                          _searchController, // Gán controller cho ô tìm kiếm
                      decoration: InputDecoration(
                        labelText: 'Tìm kiếm sản phẩm',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        searchQuery = value;
                      },
                      onSubmitted: (value) => _searchProducts(),
                    ),
                  ),
                ),
                // Hiện nút "x" chỉ khi có giá trị tìm kiếm
                if (searchQuery != null && searchQuery!.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _clearSearch(); // Xóa giá trị tìm kiếm và nội dung ô
                    },
                  ),
                ElevatedButton(
                  onPressed: _searchProducts, // Nút Tìm
                  child: Text('Tìm'),
                ),
              ],
            ),
            SizedBox(height: 10),
            Align(
              alignment:
                  Alignment.centerRight, // Đẩy nút thêm sản phẩm về bên phải
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductCreateScreen(),
                    ), // Chuyển đến màn hình tạo sản phẩm
                  );
                },
                child: Text('Thêm sản phẩm'),
              ),
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!isLoading &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent &&
                      hasMore) {
                    _fetchProducts();
                  }
                  return true;
                },
                child:
                    products.isEmpty && !isLoading
                        ? Center(
                          child: Text(
                            'Không có sản phẩm',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        : ListView.builder(
                          controller: _scrollController,
                          itemCount: products.length + (isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == products.length) {
                              return Center(child: CircularProgressIndicator());
                            }
                            final product = products[index];
                            return Card(
                              child: ListTile(
                                leading: Image.network(
                                  product['imageUrl'][0],
                                  width: 80,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(product['productName']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Brand: ${product['brand']['brandName']}',
                                    ),
                                    Text(
                                      'Category: ${product['category']['categoryName']}',
                                    ),
                                    Text('Price: ${product['price']}'),
                                    Text(
                                      'Quantity: ${product['stockQuantity']}',
                                    ),
                                    Text(
                                      'Updated: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(product['updatedAt']))}',
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed:
                                          () => _navigateToUpdateProduct(
                                            product['_id'],
                                          ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed:
                                          () => _deleteProduct(product['_id']),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
