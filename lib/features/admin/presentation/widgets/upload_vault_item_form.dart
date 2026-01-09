import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../injection_container.dart' as di;
import '../../../../core/services/backblaze_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';

class UploadVaultItemForm extends StatefulWidget {
  const UploadVaultItemForm({super.key});

  @override
  State<UploadVaultItemForm> createState() => _UploadVaultItemFormState();
}

class _UploadVaultItemFormState extends State<UploadVaultItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  // Price removed
  final _imageUrlController = TextEditingController();
  final _pdfUrlController = TextEditingController();
  bool _isPremium = true; // Default to true as per user request (VIP only)
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() => _isUploading = true);
      try {
        final service = di.sl<BackblazeService>();
        final url = await service.uploadFile(File(image.path), 'vault_covers/${image.name}');
        setState(() {
          _imageUrlController.text = url;
          _isUploading = false;
        });
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Resim yüklendi!")));
      } catch (e) {
        setState(() => _isUploading = false);
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
      }
    }
  }

  Future<void> _pickAndUploadPdf() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    
    if (result != null && result.files.single.path != null) {
      setState(() => _isUploading = true);
      try {
        final file = File(result.files.single.path!);
        final service = di.sl<BackblazeService>();
        final url = await service.uploadFile(file, 'vault_pdfs/${result.files.single.name}');
        setState(() {
          _pdfUrlController.text = url;
          _isUploading = false;
        });
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PDF yüklendi!")));
      } catch (e) {
        setState(() => _isUploading = false);
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
      }
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AdminBloc>().add(
            UploadVaultItemEvent(
              title: _titleController.text,
              author: _authorController.text,
              description: _descriptionController.text,
              price: 0.0, // Free/Included in VIP
              isPremium: _isPremium,
              imageUrl: _imageUrlController.text,
              pdfUrl: _pdfUrlController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kasaya Yükle', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Başlık'),
            validator: (value) => value!.isEmpty ? 'Zorunlu Alan' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _authorController,
            decoration: const InputDecoration(labelText: 'Yazar'),
            validator: (value) => value!.isEmpty ? 'Zorunlu Alan' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Açıklama'),
            maxLines: 3,
            validator: (value) => value!.isEmpty ? 'Zorunlu Alan' : null,
          ),
          const SizedBox(height: 10),
          // Price Field Removed
          SwitchListTile(
            title: const Text('VIP Özel İçerik'),
            value: _isPremium,
            onChanged: (val) => setState(() => _isPremium = val),
            activeColor: LustrousTheme.lustrousGold,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _imageUrlController,
            decoration: InputDecoration(
              labelText: 'Kapak Resmi URL',
              hintText: 'Link yapıştır veya butona bas',
              suffixIcon: IconButton(
                icon: const Icon(Icons.upload_file, color: LustrousTheme.lustrousGold),
                onPressed: _isUploading ? null : _pickAndUploadImage,
                tooltip: 'Cihazdan Yükle',
              ),
            ),
            validator: (value) => value!.isEmpty ? 'Zorunlu Alan' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _pdfUrlController,
            decoration: InputDecoration(
              labelText: 'PDF Doküman URL',
              hintText: 'Link yapıştır veya butona bas',
              suffixIcon: IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: LustrousTheme.lustrousGold),
                onPressed: _isUploading ? null : _pickAndUploadPdf,
                tooltip: 'Cihazdan Yükle',
              ),
            ),
            validator: (value) => value!.isEmpty ? 'Zorunlu Alan' : null,
          ),
          if (_isUploading)
             const Padding(
               padding: EdgeInsets.symmetric(vertical: 8.0),
               child: LinearProgressIndicator(color: LustrousTheme.lustrousGold),
             ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: LustrousTheme.lustrousGold,
                foregroundColor: Colors.black,
              ),
              child: const Text('KASAYA YÜKLE'),
            ),
          ),
        ],
      ),
    );
  }
}
