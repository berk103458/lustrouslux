import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../injection_container.dart' as di;
import '../../../../core/services/backblaze_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';

class UploadFeedItemForm extends StatefulWidget {
  const UploadFeedItemForm({super.key});

  @override
  State<UploadFeedItemForm> createState() => _UploadFeedItemFormState();
}

class _UploadFeedItemFormState extends State<UploadFeedItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() => _isUploading = true);
      try {
        final service = di.sl<BackblazeService>();
        final url = await service.uploadFile(File(image.path), 'feed_images/${image.name}');
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AdminBloc>().add(
            UploadFeedItemEvent(
              title: _titleController.text,
              content: _contentController.text,
              imageUrl: _imageUrlController.text,
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
          Text('Akışa Yükle', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Başlık'),
            validator: (value) => value!.isEmpty ? 'Zorunlu Alan' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _contentController,
            decoration: const InputDecoration(labelText: 'İçerik'),
            maxLines: 5,
            validator: (value) => value!.isEmpty ? 'Zorunlu Alan' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _imageUrlController,
            decoration: InputDecoration(
              labelText: 'Resim URL',
              hintText: 'Link yapıştır veya butona bas',
              suffixIcon: IconButton(
                icon: const Icon(Icons.upload_file, color: LustrousTheme.lustrousGold),
                onPressed: _isUploading ? null : _pickAndUploadImage,
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
              child: const Text('AKIŞA YÜKLE'),
            ),
          ),
        ],
      ),
    );
  }
}
