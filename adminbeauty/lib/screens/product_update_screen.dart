import 'package:adminbeauty/screens/product_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Product {
  final String id;
  final String productName;
  final double price;
  final int stockQuantity;
  final String description;
  final Brand brand;
  final Category category;

  Product({
    required this.id,
    required this.productName,
    required this.price,
    required this.stockQuantity,
    required this.description,
    required this.brand,
    required this.category,
  });
}

class Brand {
  final String id;
  final String name;

  Brand({required this.id, required this.name});
}

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});
}

class ProductUpdateScreen extends StatefulWidget {
  final Product editProduct;

  ProductUpdateScreen({Key? key, required this.editProduct}) : super(key: key);

  @override
  _ProductUpdateScreenState createState() => _ProductUpdateScreenState();
}

class _ProductUpdateScreenState extends State<ProductUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  late String productName;
  late double price;
  late int stockQuantity;
  late String description;
  String? selectedCategory;
  String? selectedBrand;

  List<Map<String, String>> categories = [];
  List<Map<String, String>> brands = [];

  @override
  void initState() {
    super.initState();
    productName = widget.editProduct.productName;
    price = widget.editProduct.price;
    stockQuantity = widget.editProduct.stockQuantity;
    description = widget.editProduct.description;
    selectedBrand = widget.editProduct.brand.id;
    selectedCategory = widget.editProduct.category.id;

    _fetchCategories();
    _fetchBrands();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.81.30:5000/api/productCategory'),
      );
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        setState(() {
          categories =
              (jsonResponse['productCategory'] as List)
                  .map<Map<String, String>>(
                    (category) => {
                      'id': category['_id'].toString(),
                      'name': category['categoryName'].toString(),
                    },
                  )
                  .toList();
        });
      } else {
        _showFlushbar(
          'Lỗi khi tải danh mục: ${jsonResponse['message']}',
          false,
        );
      }
    } catch (e) {
      _showFlushbar('Lỗi: $e', false);
    }
  }

  Future<void> _fetchBrands() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.81.30:5000/api/brand'),
      );
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        setState(() {
          brands =
              (jsonResponse['brandList'] as List)
                  .map<Map<String, String>>(
                    (brand) => {
                      'id': brand['_id'].toString(),
                      'name': brand['brandName'].toString(),
                    },
                  )
                  .toList();
        });
      } else {
        _showFlushbar(
          'Lỗi khi tải thương hiệu: ${jsonResponse['message']}',
          false,
        );
      }
    } catch (e) {
      _showFlushbar('Lỗi: $e', false);
    }
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });

      // Log các giá trị trước khi gửi yêu cầu
      print("Tên sản phẩm: $productName");
      print("Giá: $price");
      print("Số lượng: $stockQuantity");
      print("Mô tả: $description");
      print("Thương hiệu: $selectedBrand");
      print("Danh mục: $selectedCategory");

      try {
        final prefs = await SharedPreferences.getInstance();
        final accessToken = prefs.getString('accessToken');
        final response = await http.put(
          Uri.parse(
            'http://192.168.81.30:5000/api/product/${widget.editProduct.id}',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: json.encode({
            'productName': productName,
            'price': price,
            'stockQuantity': stockQuantity,
            'description': description,
            'brand': selectedBrand,
            'category': selectedCategory,
          }),
        );

        final responseData = json.decode(response.body);
        print("Phản hồi từ server: $responseData"); // Log phản hồi từ server

        if (response.statusCode == 200 && responseData['success']) {
          _showFlushbar('Cập nhật sản phẩm thành công', true);
          // Chuyển tới trang ProductManagement
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => ProductManagementScreen()),
            (Route<dynamic> route) => false, // Xóa tất cả các route trước đó
          );
        } else {
          _showFlushbar(responseData['message'], false);
        }
      } catch (e) {
        _showFlushbar('Lỗi: $e', false);
        print("Lỗi: $e"); // Log lỗi
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showFlushbar(String message, bool success) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Flushbar(
        message: message,
        duration: Duration(seconds: 3),
        backgroundColor: success ? Colors.green : Colors.red,
      ).show(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cập nhật sản phẩm')),
      body:
          _loading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: productName,
                        decoration: InputDecoration(labelText: 'Tên sản phẩm'),
                        onChanged: (value) => productName = value,
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? 'Vui lòng nhập tên sản phẩm'
                                    : null,
                      ),
                      TextFormField(
                        initialValue: price.toString(),
                        decoration: InputDecoration(labelText: 'Giá'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if (value.isEmpty) {
                            price = 0; // Hoặc giá mặc định nào đó nếu cần
                          } else {
                            try {
                              price = double.parse(value);
                            } catch (e) {
                              // Nếu không thể chuyển đổi, có thể log lỗi hoặc hiển thị thông báo
                              print("Lỗi chuyển đổi giá: $e");
                              // Bạn có thể thêm logic để xử lý lỗi ở đây
                            }
                          }
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Vui lòng nhập giá';
                          } else {
                            // Kiểm tra xem giá có phải là số hợp lệ không
                            final parsedValue = double.tryParse(value);
                            if (parsedValue == null) {
                              return 'Giá không hợp lệ';
                            }
                          }
                          return null; // Không có lỗi
                        },
                      ),
                      TextFormField(
                        initialValue: stockQuantity.toString(),
                        decoration: InputDecoration(labelText: 'Số lượng'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if (value.isEmpty) {
                            stockQuantity =
                                0; // Hoặc giá mặc định nào đó nếu cần
                          } else {
                            try {
                              stockQuantity = int.parse(value);
                            } catch (e) {
                              // Nếu không thể chuyển đổi, có thể log lỗi hoặc hiển thị thông báo
                              print("Lỗi chuyển đổi số lượng: $e");
                              // Bạn có thể thêm logic để xử lý lỗi ở đây
                            }
                          }
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Vui lòng nhập số lượng';
                          } else {
                            // Kiểm tra xem số lượng có phải là số hợp lệ không
                            final parsedValue = int.tryParse(value);
                            if (parsedValue == null) {
                              return 'Số lượng không hợp lệ';
                            }
                          }
                          return null; // Không có lỗi
                        },
                      ),
                      DropdownButtonFormField(
                        value: selectedCategory,
                        decoration: InputDecoration(labelText: 'Danh mục'),
                        items:
                            categories.map((category) {
                              return DropdownMenuItem(
                                value: category['id'],
                                child: Text(category['name']!),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value as String?;
                          });
                        },
                        validator:
                            (value) =>
                                value == null ? 'Vui lòng chọn danh mục' : null,
                      ),
                      DropdownButtonFormField(
                        value: selectedBrand,
                        decoration: InputDecoration(labelText: 'Thương hiệu'),
                        items:
                            brands.map((brand) {
                              return DropdownMenuItem(
                                value: brand['id'],
                                child: Text(brand['name']!),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedBrand = value as String?;
                          });
                        },
                        validator:
                            (value) =>
                                value == null
                                    ? 'Vui lòng chọn thương hiệu'
                                    : null,
                      ),
                      TextFormField(
                        initialValue: description,
                        decoration: InputDecoration(labelText: 'Mô tả'),
                        maxLines: 3,
                        onChanged: (value) => description = value,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Vui lòng nhập mô tả' : null,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _updateProduct,
                        child: Text('Cập nhật sản phẩm'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Trở về'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
