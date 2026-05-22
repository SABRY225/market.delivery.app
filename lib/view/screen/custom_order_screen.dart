import '../../../data/datasource/remote/custom_order.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:get/get.dart';

class CustomOrderScreen extends StatefulWidget {
  const CustomOrderScreen({super.key});

  @override
  State<CustomOrderScreen> createState() => _CustomOrderScreenState();
}

class _CustomOrderScreenState extends State<CustomOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  bool _isLoading = false;
  final _picker = ImagePicker();

  final Color silverColor = const Color(0xFFBDC3C7);   
  final Color darkBlack = const Color(0xFF1A1A1B);    
  final Color charcoal = const Color(0xFF2C3E50);     
  final Color lightSilver = const Color(0xFFE5E8E8);  

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  void _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please attach a picture of the piece design.'.tr)),
      );
      return;
    }

    setState(() => _isLoading = true);
    bool success = await CustomOrder.submitOrder(
      name: _nameController.text,
      phone: '+962${_phoneController.text}',
      address: _addressController.text,
      desc: _descController.text,
      imageFile: _image!,
    );
    setState(() => _isLoading = false);

    if (success) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sorry, transmission failed. Please try again.'.tr)),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: darkBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: silverColor)),
        title: Icon(Icons.verified, color: silverColor, size: 50),
        content: Text(
          'Your request has been successfully submitted. We will contact you regarding pricing soon.'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              child: Text('Good'.tr, style: TextStyle(color: silverColor, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: Text('Designing a special piece'.tr, style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        centerTitle: true,
        backgroundColor: darkBlack,
        foregroundColor: silverColor,
        elevation: 10,
        shadowColor: Colors.black45,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _isLoading 
          ? Center(child: CircularProgressIndicator(color: darkBlack)) 
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle('Customer data'.tr),
                    _buildField('Full name'.tr, _nameController, Icons.person_outlined),
                    _buildField('Contact number'.tr, _phoneController, Icons.phone_outlined, isPhone: true),
                    _buildField('address'.tr, _addressController, Icons.map_outlined),
                    
                    const SizedBox(height: 30),
                    _buildTitle('Details of the silver piece'.tr),
                    _buildField('Design Description'.tr, _descController, Icons.edit_note_outlined, maxLines: 4),
                    
                    const SizedBox(height: 15),
                    Text('Illustrative image'.tr, style: TextStyle(color: darkBlack, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildImageArea(),

                    const SizedBox(height: 40),
                    _buildButton(),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: darkBlack, fontSize: 18, fontWeight: FontWeight.w900)),
        Container(margin: const EdgeInsets.only(top: 4, bottom: 20), height: 3, width: 40, color: silverColor),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {int maxLines = 1, bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        maxLength: isPhone ? 9 : 150,
        style: const TextStyle(color: Color.fromARGB(255, 7, 7, 7)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: charcoal),
          prefixIcon: Icon(icon, color: darkBlack),
          filled: true,
          fillColor: Color.from(alpha: 0, red: 0, green: 0, blue: 0),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: darkBlack, width: 1.5)),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: lightSilver, width: 1.5)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (v) => v!.isEmpty ? 'Required'.tr : null,
      ),
    );
  }

  Widget _buildImageArea() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: lightSilver.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: silverColor, width: 1, style: BorderStyle.solid),
        ),
        child: _image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_file, size: 40, color: charcoal),
                  Text('Attach a photo of the model.'.tr, style: TextStyle(color: Colors.grey)),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.file(_image!, fit: BoxFit.cover),
              ),
      ),
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _submitOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: darkBlack,
          foregroundColor: silverColor,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: silverColor, width: 0.5),
          ),
        ),
        child:  Text('Submit'.tr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}