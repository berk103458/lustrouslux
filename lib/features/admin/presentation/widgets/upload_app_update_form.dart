import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';

class UploadAppUpdateForm extends StatefulWidget {
  const UploadAppUpdateForm({super.key});

  @override
  State<UploadAppUpdateForm> createState() => _UploadAppUpdateFormState();
}

class _UploadAppUpdateFormState extends State<UploadAppUpdateForm> {
  final _formKey = GlobalKey<FormState>();
  final _versionController = TextEditingController();
  File? _apkFile;

  Future<void> _pickApk() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['apk'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _apkFile = File(result.files.single.path!);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _apkFile != null) {
      context.read<AdminBloc>().add(
            UploadAppUpdateEvent(
              apkFile: _apkFile!,
              version: _versionController.text.trim(),
            ),
          );
    } else if (_apkFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir APK dosyası seçin.')),
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
          Text('Yeni Güncelleme Yayınla (Backblaze B2)', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          TextFormField(
            controller: _versionController,
            decoration: const InputDecoration(
                labelText: 'Versiyon (örn: 1.2.0)',
                hintText: 'X.Y.Z formatında girin'),
            validator: (value) => value!.isEmpty ? 'Zorunlu Alan' : null,
          ),
          const SizedBox(height: 10),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.android, color: Colors.green),
            title: Text(_apkFile != null 
                ? 'Seçilen: ${_apkFile!.path.split('/').last}' 
                : 'APK Dosyası Seçilmedi'),
            subtitle: const Text('app-release.apk dosyasını seçin'),
            trailing: IconButton(
              icon: const Icon(Icons.upload_file, color: LustrousTheme.lustrousGold),
              onPressed: _pickApk,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
              child: const Text('GÜNCELLEMEYİ YAYINLA'),
            ),
          ),
        ],
      ),
    );
  }
}
