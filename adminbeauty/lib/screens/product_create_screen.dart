import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductCreateScreen extends StatefulWidget {
  const ProductCreateScreen({super.key});

  @override
  _ProductCreateScreenState createState() => _ProductCreateScreenState();
}

class _ProductCreateScreenState extends State<ProductCreateScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockQuantityController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  XFile? _imageFile; // Chỉ lưu trữ một hình ảnh
  final ImagePicker _picker = ImagePicker();

  List<Map<String, String>> categories = []; // Lưu danh mục dưới dạng map
  List<Map<String, String>> brands = []; // Lưu thương hiệu dưới dạng map
  String? selectedCategory;
  String? selectedBrand;
  bool _isLoading = false; // Biến trạng thái loading

  @override
  void initState() {
    super.initState();
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
        _showFlushbar('Lỗi khi tải danh mục: ${jsonResponse['message']}');
      }
    } catch (e) {
      _showFlushbar('Lỗi: $e');
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
        _showFlushbar('Lỗi khi tải thương hiệu: ${jsonResponse['message']}');
      }
    } catch (e) {
      _showFlushbar('Lỗi: $e');
    }
  }

  Future<void> _pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      _imageFile = selectedImage; // Lưu trữ một hình ảnh duy nhất
    });
  }

  Future<void> _createProduct() async {
    // Kiểm tra các trường thông tin
    if (_productNameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _stockQuantityController.text.isEmpty ||
        selectedCategory == null ||
        selectedBrand == null ||
        _imageFile == null) {
      _showFlushbar(
        'Vui lòng điền đầy đủ thông tin sản phẩm và chọn hình ảnh.',
      );
      return;
    }

    // Kiểm tra kiểu dữ liệu trước khi gửi
    print(
      'Product Name: ${_productNameController.text} (Type: ${_productNameController.text.runtimeType})',
    );
    print(
      'Price: ${_priceController.text} (Type: ${_priceController.text.runtimeType})',
    );
    print(
      'Stock Quantity: ${_stockQuantityController.text} (Type: ${_stockQuantityController.text.runtimeType})',
    );
    print(
      'Description: ${_descriptionController.text} (Type: ${_descriptionController.text.runtimeType})',
    );
    print(
      'Category: $selectedCategory (Type: ${selectedCategory.runtimeType})',
    );
    print('Brand: $selectedBrand (Type: ${selectedBrand.runtimeType})');
    print(
      'Image Path: ${_imageFile?.path} (Type: ${_imageFile?.path.runtimeType})',
    );

    setState(() {
      _isLoading = true; // Bắt đầu loading
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.81.30:5000/api/product'),
      );

      // Gán các trường thông tin vào request
      request.fields['productName'] = _productNameController.text;
      request.fields['price'] = double.parse(_priceController.text).toString();
      request.fields['stockQuantity'] =
          int.parse(_stockQuantityController.text).toString();
      request.fields['description'] = _descriptionController.text;
      request.fields['category'] = selectedCategory!; // Đảm bảo không phải null
      request.fields['brand'] = selectedBrand!; // Đảm bảo không phải null

      // Thêm hình ảnh
      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('images', _imageFile!.path),
        );
      } else {
        _showFlushbar('No image file selected');
        return;
      }

      // Thêm header Authorization nếu có accessToken
      if (accessToken != null) {
        request.headers['Authorization'] = 'Bearer $accessToken';
      }

      // Gửi request và nhận phản hồi
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      setState(() {
        _isLoading = false; // Kết thúc loading
      });

      print("Response Status Code: ${response.statusCode}");
      print("Response Data: $responseData");

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseData);
        if (jsonResponse['success']) {
          Navigator.pop(context);
          _showFlushbar('Tạo sản phẩm thành công');
        } else {
          _showFlushbar('Lỗi: ${jsonResponse['mess']}');
        }
      } else {
        _showFlushbar('Vui lòng nhập đầy đủ các trường');
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Kết thúc loading
      });
      _showFlushbar('Lỗi: $e');
    }
  }

  void _showFlushbar(String message) {
    Flushbar(message: message, duration: Duration(seconds: 3))..show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thêm sản phẩm')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _productNameController,
              decoration: InputDecoration(labelText: 'Tên sản phẩm'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Giá'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _stockQuantityController,
              decoration: InputDecoration(labelText: 'Số lượng'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Danh mục'),
              value: selectedCategory,
              items:
                  categories.map((category) {
                    return DropdownMenuItem(
                      value: category['id'],
                      child: Text(category['name'] ?? ''),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
              validator:
                  (value) => value == null ? 'Vui lòng chọn danh mục' : null,
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Thương hiệu'),
              value: selectedBrand,
              items:
                  brands.map((brand) {
                    return DropdownMenuItem(
                      value: brand['id'],
                      child: Text(brand['name'] ?? ''),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedBrand = value;
                });
              },
              validator:
                  (value) => value == null ? 'Vui lòng chọn thương hiệu' : null,
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Mô tả'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _pickImage,
              child: Text('Chọn hình ảnh'),
            ),
            SizedBox(height: 10),
            _imageFile != null
                ? Image.file(File(_imageFile!.path), width: 100, height: 100)
                : Text('Chưa chọn hình ảnh'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _createProduct,
              child:
                  _isLoading
                      ? CircularProgressIndicator()
                      : Text('Lưu sản phẩm'),
            ),
            if (_isLoading) SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
