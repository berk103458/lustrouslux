import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_state.dart';
import '../bloc/admin_event.dart';
import '../widgets/upload_feed_item_form.dart';
import '../widgets/upload_vault_item_form.dart';
import '../widgets/upload_app_update_form.dart';
import '../widgets/user_management_section.dart';
import '../widgets/admin_vault_list.dart';
import '../widgets/admin_feed_list.dart';
import 'admin_support_page.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../injection_container.dart' as di;

// TODO: Replace with the actual Admin UID provided by the user
const String kAdminUid = '2LZOwDBqDWdOafZKSw3femX1zhz1'; 

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.uid != kAdminUid) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erişim Reddedildi')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Bu sayfaya erişim yetkiniz yok.'),
              const SizedBox(height: 8),
              if (user != null)
                 SelectableText(
                  'Kullanıcı UID: ${user.uid}', // Copy this UID to kAdminUid
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              else
                 const Text('Giriş yapmış kullanıcı yok.'),
            ],
          ),
        ),
      );
    }

    return BlocProvider(
      create: (_) => di.sl<AdminBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Yönetici Paneli'),
          backgroundColor: Colors.black,
          foregroundColor: LustrousTheme.lustrousGold,
        ),
        body: BlocConsumer<AdminBloc, AdminState>(
          listener: (context, state) {
            if (state is AdminSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is AdminFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is AdminUploading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
    const SizedBox(height: 16),
    Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
                di.sl<NotificationService>().showVipNotification(
                title: 'LUSTROUS LUX',
                body: 'Çekim alanına hoşgeldiniz. Kasa açıldı.',
                );
            },
            icon: const Icon(Icons.notifications_active, color: Color(0xFFD4AF37)),
            label: const Text('VIP SİNYAL TESTİ'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFD4AF37)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
                context.read<AdminBloc>().add(InitializeSystemEvent());
            },
            icon: const Icon(Icons.settings_system_daydream, color: Colors.cyanAccent),
            label: const Text('SİSTEM DB BAŞLAT'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.cyanAccent,
                side: const BorderSide(color: Colors.cyanAccent),
            ),
          ),
        ),
    ],
    ),
    const SizedBox(height: 8),
    SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
        onPressed: () {
             Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSupportPage()));
        },
        icon: const Icon(Icons.headset_mic, color: Colors.orange),
        label: const Text('DESTEK TALEPLERİ'),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.orange,
            side: const BorderSide(color: Colors.orange),
        ),
        ),
    ),
    const SizedBox(height: 24),

                  _buildSectionHeader('Kasa Yönetimi'),
                  const UploadVaultItemForm(),
                  const SizedBox(height: 16),
                  const Text('Mevcut İçerikler (Silmek için yana kaydır veya butona bas)', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  const AdminVaultList(),
                  const Divider(color: LustrousTheme.lustrousGold, height: 40),
                  _buildSectionHeader('Akış Yönetimi'),
                  const UploadFeedItemForm(),
                  const SizedBox(height: 16),
                  const Text('Mevcut Paylaşımlar', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  const AdminFeedList(),
                  const Divider(color: LustrousTheme.lustrousGold, height: 40),
                  _buildSectionHeader('Sistem Güncelleme'),
                  const UploadAppUpdateForm(),
                  const Divider(color: LustrousTheme.lustrousGold, height: 40),
                  _buildSectionHeader('Kullanıcı Yönetimi (VIP & Ban)'),
                  const UserManagementSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          const Icon(Icons.admin_panel_settings, color: LustrousTheme.lustrousGold),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: LustrousTheme.lustrousGold,
            ),
          ),
        ],
      ),
    );
  }
}
