import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/upload_feed_item.dart';
import '../../domain/usecases/upload_vault_item.dart';
import '../../domain/usecases/initialize_system_defaults.dart';
import '../../domain/usecases/upload_app_update.dart';
import '../../domain/usecases/get_users.dart';
import '../../domain/usecases/update_user_status.dart';
import 'dart:io';
import 'admin_event.dart';
import 'admin_state.dart';

import '../../domain/usecases/delete_vault_item.dart';

import '../../domain/usecases/delete_feed_item.dart';

// ... imports

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final UploadVaultItem uploadVaultItem;
  final UploadFeedItem uploadFeedItem;
  final InitializeSystemDefaults initializeSystemDefaults;
  final UploadAppUpdate uploadAppUpdate;
  final GetUsers getUsers;
  final UpdateUserStatus updateUserStatus;
  final DeleteVaultItem deleteVaultItem;
  final DeleteFeedItem deleteFeedItem;

  AdminBloc({
    required this.uploadVaultItem,
    required this.uploadFeedItem,
    required this.initializeSystemDefaults,
    required this.uploadAppUpdate,
    required this.getUsers,
    required this.updateUserStatus,
    required this.deleteVaultItem,
    required this.deleteFeedItem,
  }) : super(AdminInitial()) {
    on<UploadVaultItemEvent>(_onUploadVaultItem);
    on<UploadFeedItemEvent>(_onUploadFeedItem);
    on<InitializeSystemEvent>(_onInitializeSystem);
    on<UploadAppUpdateEvent>(_onUploadAppUpdate);
    on<FetchUsersEvent>(_onFetchUsers);
    on<UpdateUserStatusEvent>(_onUpdateUserStatus);
    on<DeleteVaultItemEvent>(_onDeleteVaultItem);
    on<DeleteFeedItemEvent>(_onDeleteFeedItem);
  }

  // ... (previous methods)

  Future<void> _onDeleteFeedItem(
    DeleteFeedItemEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminUploading());
    try {
      await deleteFeedItem(event.id);
      emit(const AdminSuccess('Akış İçeriği Silindi'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  // ... (rest)


  // ... (previous methods)

  Future<void> _onDeleteVaultItem(
    DeleteVaultItemEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminUploading()); // Or a specific deleting state
    try {
      await deleteVaultItem(event.id);
      emit(const AdminSuccess('Kasa Öğesi Silindi'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  // ... (rest of methods)


  Future<void> _onUploadVaultItem(
    UploadVaultItemEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminUploading());
    try {
      await uploadVaultItem(
        title: event.title,
        author: event.author,
        description: event.description,
        price: event.price,
        isPremium: event.isPremium,
        imageUrl: event.imageUrl,
        pdfUrl: event.pdfUrl,
      );
      emit(const AdminSuccess('Kasa Öğesi Başarıyla Yüklendi'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> _onUploadFeedItem(
    UploadFeedItemEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminUploading());
    try {
      await uploadFeedItem(
        title: event.title,
        content: event.content,
        imageUrl: event.imageUrl,
      );
      emit(const AdminSuccess('Akış Öğesi Başarıyla Yüklendi'));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> _onInitializeSystem(
    InitializeSystemEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminUploading());
    try {
      await initializeSystemDefaults();
      emit(const AdminSuccess('Sistem Varsayılanları Başarıyla Başlatıldı'));
    } catch (e) {
    }
  }

  Future<void> _onUploadAppUpdate(
    UploadAppUpdateEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminUploading());
    try {
      final File apkFile = event.apkFile as File;
      final String version = event.version;
      
      // 1. Upload to Cloud
      await uploadAppUpdate(
        apkFile: apkFile,
        version: version,
      );

      // 2. Archive Locally (Auto-Backup)
      try {
        await _archiveApkLocally(apkFile, version);
        emit(const AdminSuccess('Güncelleme Başarıyla Yayınlandı ve Arşivlendi! 🚀'));
      } catch (e) {
        // If archive fails, still success for upload
        emit(const AdminSuccess('Yayınlandı (Arşivleme Hatası: Yetki Yok)'));
      }
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> _archiveApkLocally(File sourceFile, String version) async {
    // Request Storage Permission
    // On Android 13+, this might need READ_MEDIA..., but for Downloads we try best effort.
    // WRITE_EXTERNAL_STORAGE is key for older androids.
    
    // Simple check. Real implementation might need more robust permission handling depending on OS.
    // For now, we assume user grants it or we have scoped access.
    
    final safeVersion = version.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w.-]'), '');
    final fileName = 'LustrousLux_v$safeVersion.apk';

    // Target Path: /storage/emulated/0/Download/LustrousBackups/
    final Directory downloadDir = Directory('/storage/emulated/0/Download');
    if (await downloadDir.exists()) {
        final Directory backupDir = Directory('${downloadDir.path}/LustrousBackups');
        if (!await backupDir.exists()) {
            await backupDir.create(recursive: true);
        }
        
        final String targetPath = '${backupDir.path}/$fileName';
        await sourceFile.copy(targetPath);
    }
  }
  Future<void> _onFetchUsers(
    FetchUsersEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final users = await getUsers();
      emit(AdminUsersLoaded(users));
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }

  Future<void> _onUpdateUserStatus(
    UpdateUserStatusEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminUploading()); 
    try {
      await updateUserStatus(
        uid: event.uid,
        isPremium: event.isPremium,
        isBanned: event.isBanned,
      );
      add(FetchUsersEvent());
    } catch (e) {
      emit(AdminFailure(e.toString()));
    }
  }
}
