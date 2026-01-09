import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

import 'features/admin/data/datasources/admin_remote_data_source.dart';
import 'features/admin/data/repositories/admin_repository_impl.dart';
import 'features/admin/domain/repositories/admin_repository.dart';
import 'features/admin/domain/usecases/upload_feed_item.dart';
import 'features/admin/domain/usecases/upload_vault_item.dart';
import 'features/admin/domain/usecases/initialize_system_defaults.dart';
import 'features/admin/domain/usecases/upload_app_update.dart';
import 'features/admin/domain/usecases/get_users.dart';
import 'features/admin/domain/usecases/update_user_status.dart';
import 'features/admin/domain/usecases/delete_vault_item.dart';
import 'features/admin/domain/usecases/delete_feed_item.dart';
import 'features/admin/domain/usecases/delete_ticket.dart';
import 'features/admin/domain/usecases/get_support_tickets.dart';
import 'features/admin/domain/usecases/reply_to_ticket.dart';
import 'features/admin/domain/usecases/close_ticket.dart';
import 'features/admin/presentation/bloc/admin_bloc.dart';

import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/check_auth_status.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/domain/usecases/logout_user.dart';
import 'features/auth/domain/usecases/get_user_stream.dart';
import 'features/auth/domain/usecases/create_ticket.dart';
import 'features/auth/domain/usecases/send_user_message.dart';
import 'features/auth/domain/usecases/get_user_tickets.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/vault/data/datasources/vault_remote_data_source.dart';
import 'features/vault/data/repositories/vault_repository_impl.dart';
import 'features/vault/domain/repositories/vault_repository.dart';
import 'features/vault/domain/usecases/get_ebooks.dart';
import 'features/vault/presentation/bloc/vault_bloc.dart';
import 'features/feed/data/datasources/feed_remote_data_source.dart';
import 'features/feed/data/repositories/feed_repository_impl.dart';
import 'features/feed/domain/repositories/feed_repository.dart';
import 'features/feed/domain/usecases/get_feed.dart';
import 'features/feed/domain/usecases/toggle_like.dart';
import 'features/feed/domain/usecases/add_comment.dart';
import 'features/feed/domain/usecases/get_comments.dart';
import 'features/feed/domain/usecases/is_post_liked.dart';
import 'features/feed/domain/usecases/get_favorites.dart';
import 'core/services/biometric_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/update_service.dart';
import 'core/services/backblaze_service.dart';
import 'features/feed/presentation/bloc/feed_bloc.dart';

final sl = GetIt.instance; // Service Locator

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUser: sl(),
      registerUser: sl(),
      checkAuthStatus: sl(),
      logoutUser: sl(),
      getUserStream: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => CheckAuthStatus(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => GetUserStream(sl()));
  sl.registerLazySingleton(() => CreateTicket(sl()));
  sl.registerLazySingleton(() => SendUserMessage(sl()));
  sl.registerLazySingleton(() => GetUserTickets(sl()));

  // Admin Use Cases
  sl.registerLazySingleton(() => GetSupportTickets(sl()));
  sl.registerLazySingleton(() => ReplyToTicket(sl()));
  sl.registerLazySingleton(() => CloseTicket(sl()));
  sl.registerLazySingleton(() => DeleteTicket(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(auth: sl(), firestore: sl()),
  );

  //! Features - Vault
  // Bloc
  sl.registerFactory(() => VaultBloc(getEbooks: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetEbooks(sl()));

  // Repository
  sl.registerLazySingleton<VaultRepository>(
    () => VaultRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<VaultRemoteDataSource>(
    () => VaultRemoteDataSourceImpl(firestore: sl()),
  );

  //! Features - Feed
  // Bloc
  sl.registerFactory(() => FeedBloc(
      getFeed: sl(),
      toggleLike: sl(),
      addComment: sl(),
      getComments: sl(),
  ));

  // Use cases
  sl.registerLazySingleton(() => GetFeed(sl()));
  sl.registerLazySingleton(() => ToggleLike(sl()));
  sl.registerLazySingleton(() => AddComment(sl()));
  sl.registerLazySingleton(() => GetComments(sl()));
  sl.registerLazySingleton(() => IsPostLiked(sl()));
  sl.registerLazySingleton(() => GetFavorites(sl()));

  // Repository
  sl.registerLazySingleton<FeedRepository>(
    () => FeedRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<FeedRemoteDataSource>(
    () => FeedRemoteDataSourceImpl(firestore: sl()),
  );

  //! Features - Admin
  // Bloc
  sl.registerFactory(
    () => AdminBloc(
      uploadVaultItem: sl(),
      uploadFeedItem: sl(),
      initializeSystemDefaults: sl(),
      uploadAppUpdate: sl(),
      getUsers: sl(),
      updateUserStatus: sl(),
      deleteVaultItem: sl(),
      deleteFeedItem: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => UploadVaultItem(sl()));
  sl.registerLazySingleton(() => UploadFeedItem(sl()));
  sl.registerLazySingleton(() => InitializeSystemDefaults(sl()));
  sl.registerLazySingleton(() => UploadAppUpdate(sl()));
  sl.registerLazySingleton(() => GetUsers(sl()));
  sl.registerLazySingleton(() => UpdateUserStatus(sl()));
  sl.registerLazySingleton(() => DeleteVaultItem(sl()));
  sl.registerLazySingleton(() => DeleteFeedItem(sl()));
  // DeleteFeedItem registered in AdminBloc factory only, not as singleton if not needed, but wait it is needed for AdminBloc.
  // It is already registered in Admin Use Cases section? No, let's check.
  // Line 160: sl.registerLazySingleton(() => DeleteFeedItem(sl()));
  // Line 161: sl.registerLazySingleton(() => DeleteFeedItem(sl())); -> DUPLICATE
  // Removing Line 161.
  // GetSupportTickets and ReplyToTicket are already registered above under "Admin Use Cases"

  // Repository
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(firestore: sl(), firebaseStorage: sl(), backblazeService: sl()),
  );

  //! External
  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton(() => BiometricService());
  sl.registerLazySingleton(() => UpdateService());
  sl.registerLazySingleton(() => BackblazeService());
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
}
