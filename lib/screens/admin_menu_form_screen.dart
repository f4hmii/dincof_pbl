import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/colors.dart';
import '../models/coffee.dart';
import '../providers/app_provider.dart';
import '../widgets/coffee_image_widget.dart';

class AdminMenuFormScreen extends StatefulWidget {
  final Coffee? coffee;

  const AdminMenuFormScreen({super.key, this.coffee});

  @override
  State<AdminMenuFormScreen> createState() => _AdminMenuFormScreenState();
}

class _AdminMenuFormScreenState extends State<AdminMenuFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.coffee?.name ?? '');
    _typeController = TextEditingController(text: widget.coffee?.type ?? '');
    _descriptionController = TextEditingController(text: widget.coffee?.description ?? '');
    _priceController = TextEditingController(text: widget.coffee?.price.toString() ?? '');
    _imageController = TextEditingController(text: widget.coffee?.imagePath ?? '');
    
    // Listener untuk memperbarui preview gambar secara langsung saat URL/path berubah
    _imageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final coffee = Coffee(
        id: widget.coffee?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        type: _typeController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        imagePath: _imageController.text,
        rating: widget.coffee?.rating ?? 4.7,
      );

      if (widget.coffee == null) {
        context.read<AppProvider>().addCoffee(coffee);
      } else {
        context.read<AppProvider>().updateCoffee(coffee);
      }

      Navigator.pop(context);
    }
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        final path = result.files.single.path;
        if (path != null) {
          setState(() {
            _imageController.text = path;
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.coffee == null ? 'Add Menu' : 'Edit Menu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField('Name', _nameController),
              const SizedBox(height: 16),
              _buildTextField('Type (e.g. with Oat Milk)', _typeController),
              const SizedBox(height: 16),
              _buildTextField('Description', _descriptionController, maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField('Price', _priceController, isNumber: true),
              const SizedBox(height: 16),
              // Image Preview
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.lightGray),
                    color: AppColors.lightGray.withOpacity(0.2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _imageController.text.trim().isNotEmpty
                        ? CoffeeImageWidget(
                            imagePath: _imageController.text,
                            fit: BoxFit.cover,
                            fallbackWidget: const Icon(
                              Icons.image_not_supported,
                              color: AppColors.textSecondary,
                              size: 40,
                            ),
                          )
                        : const Icon(
                            Icons.add_a_photo,
                            color: AppColors.textSecondary,
                            size: 40,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextField('Image URL / Path', _imageController),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 56, // Menyesuaikan tinggi dengan TextFormField default
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.folder_open, size: 20),
                      label: const Text('Pilih Berkas'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        filled: true,
        fillColor: AppColors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (isNumber && double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }
}
