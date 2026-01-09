import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class UserManagementSection extends StatefulWidget {
  const UserManagementSection({super.key});

  @override
  State<UserManagementSection> createState() => _UserManagementSectionState();
}

class _UserManagementSectionState extends State<UserManagementSection> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(FetchUsersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator(color: LustrousTheme.lustrousGold));
        }

        if (state is AdminUsersLoaded) {
          return _buildUserList(state.users);
        }

        // Handle success/reloading states by checking if we have data or need to re-fetch
        // For simplicity, if state is Uploading or Success (from toggle), we might want to keep showing list
        // Ideally we'd have a persisted list in the Bloc state or separated states.
        // But since Bloc emits new states, we might lose the list if we don't carry it over.
        // Simple fix: Always fetch on init, and after update we re-fetch which triggers Loading -> Loaded.
        
        return Center(
          child: TextButton.icon(
             icon: const Icon(Icons.refresh, color: LustrousTheme.lustrousGold),
             label: const Text("Listeyi Yenile", style: TextStyle(color: Colors.white)),
             onPressed: () => context.read<AdminBloc>().add(FetchUsersEvent()),
          ),
        );
      },
    );
  }

  Widget _buildUserList(List<UserEntity> users) {
    if (users.isEmpty) {
      return const Center(child: Text('Kullanıcı bulunamadı.', style: TextStyle(color: Colors.white70)));
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(), // Nested in singlechildscrollview
      shrinkWrap: true,
      itemCount: users.length,
      separatorBuilder: (ctx, i) => const Divider(color: Colors.white10),
      itemBuilder: (ctx, i) {
        final user = users[i];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: user.isPremium ? LustrousTheme.lustrousGold : Colors.white10,
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: user.isBanned ? Colors.red : (user.isPremium ? LustrousTheme.lustrousGold : Colors.grey[800]),
              child: Icon(
                user.isBanned ? Icons.block : (user.isPremium ? Icons.star : Icons.person),
                color: user.isBanned || user.isPremium ? Colors.black : Colors.white,
              ),
            ),
            title: Text(
              user.email,
              style: TextStyle(
                color: user.isBanned ? Colors.red : Colors.white,
                fontWeight: FontWeight.bold,
                decoration: user.isBanned ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              user.uid,
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // VIP Toggle
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("VIP", style: TextStyle(color: LustrousTheme.lustrousGold, fontSize: 10)),
                    SizedBox(
                      height: 30,
                      child: Switch(
                        value: user.isPremium,
                        activeColor: LustrousTheme.lustrousGold,
                        onChanged: (val) {
                          context.read<AdminBloc>().add(UpdateUserStatusEvent(uid: user.uid, isPremium: val));
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                // Ban Button
                IconButton(
                  icon: Icon(
                    user.isBanned ? Icons.check_circle : Icons.block,
                    color: user.isBanned ? Colors.green : Colors.red,
                  ),
                  tooltip: user.isBanned ? "Yasağı Kaldır" : "Yasakla (Ban)",
                  onPressed: () {
                     context.read<AdminBloc>().add(UpdateUserStatusEvent(uid: user.uid, isBanned: !user.isBanned));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
