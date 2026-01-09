import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../vault/presentation/bloc/vault_bloc.dart';
import '../../../vault/presentation/bloc/vault_state.dart';
import '../../../vault/presentation/bloc/vault_event.dart'; // Import if needed for LoadVault (optional)
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';

class AdminVaultList extends StatefulWidget {
  const AdminVaultList({super.key});

  @override
  State<AdminVaultList> createState() => _AdminVaultListState();
}

class _AdminVaultListState extends State<AdminVaultList> {
  @override
  void initState() {
    super.initState();
    // Ensure Vault is loaded (it should be streaming, but good to trigger if not)
    context.read<VaultBloc>().add(LoadVault());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VaultBloc, VaultState>(
      builder: (context, state) {
        if (state is VaultLoading) {
          return const Center(child: CircularProgressIndicator(color: LustrousTheme.lustrousGold));
        } else if (state is VaultError) {
          return Text('Hata: ${state.message}', style: const TextStyle(color: Colors.red));
        } else if (state is VaultLoaded) {
          if (state.ebooks.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Kasa boş.', style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.ebooks.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.grey),
            itemBuilder: (context, index) {
              final item = state.ebooks[index];
              return ListTile(
                leading: item.coverUrl.isNotEmpty
                    ? Image.network(item.coverUrl, width: 40, height: 60, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.book, color: LustrousTheme.lustrousGold))
                    : const Icon(Icons.book, color: LustrousTheme.lustrousGold),
                title: Text(item.title, style: const TextStyle(color: Colors.white)),
                subtitle: Text(item.author, style: const TextStyle(color: Colors.grey)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: Colors.grey[900],
                        title: const Text('Sil?', style: TextStyle(color: Colors.white)),
                        content: Text('"${item.title}" silinecek. Emin misin?', style: const TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              context.read<AdminBloc>().add(DeleteVaultItemEvent(item.id));
                            },
                            child: const Text('SİL', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
        return const SizedBox.shrink(); // Initial state
      },
    );
  }
}
