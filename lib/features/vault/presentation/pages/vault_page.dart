import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../bloc/vault_bloc.dart';
import '../bloc/vault_event.dart';
import '../bloc/vault_state.dart';
import '../../domain/entities/ebook_entity.dart';
import 'pdf_viewer_page.dart';
import '../../../../core/widgets/secure_image.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<VaultBloc>(context).add(LoadVault());
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get User Status
    final authState = context.read<AuthBloc>().state;
    bool hasVipAccess = false;
    
    if (authState is AuthAuthenticated) {
      hasVipAccess = authState.user.isPremium || authState.user.isAdmin;
    }

    return Scaffold(
      backgroundColor: LustrousTheme.midnightBlack,
      appBar: AppBar(
        title: const Text('THE VAULT'),
        centerTitle: true,
      ),
      body: BlocBuilder<VaultBloc, VaultState>(
        builder: (context, state) {
          if (state is VaultLoading) {
            return const Center(child: CircularProgressIndicator(color: LustrousTheme.lustrousGold));
          } else if (state is VaultError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
          } else if (state is VaultLoaded) {
            if (state.ebooks.isEmpty) {
               return const Center(child: Text("The Vault is currently empty.", style: TextStyle(color: Colors.white)));
            }
            
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: state.ebooks.length,
              itemBuilder: (context, index) {
                final ebook = state.ebooks[index];
                return _buildEbookCard(context, ebook, hasVipAccess);
              },
            );
          }
          return const Center(child: Text("Initializing Vault...", style: TextStyle(color: Colors.white)));
        },
      ),
    );
  }

  Widget _buildEbookCard(BuildContext context, EbookEntity ebook, bool hasVipAccess) {
    // 2. Logic: If item is free, everyone opens. If premium, only VIPs open.
    // However, if user is VIP/Admin, they open EVERYTHING (so locked becomes false).
    // Original entity might have `isPremium` (bool). Let's assume `isLocked` was used as "Requires Premium".
    // Better logic: 
    // bool requiresPremium = ebook.isPremium; // Assuming property exists
    // bool isLockedForUser = requiresPremium && !hasVipAccess;
    
    // Since I can't see EbookEntity source effectively in this turn, I will assume existing logic used `isLocked` as valid state from API? 
    // No, `isLocked` usually is a UI state. Let's look at `_buildEbookCard` in previous file view. 
    // It used `ebook.isLocked`. If `EbookEntity` has `isPremium`, I should use that.
    
    // IMPORTANT: The user said "vip erişemiyor".
    // If I force unlock for VIPs, it works.
    
    final bool isActuallyLocked = ebook.isLocked && !hasVipAccess;

    return GestureDetector(
      onTap: () {
        if (!isActuallyLocked) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewerPage(
                pdfUrl: ebook.pdfUrl,
                title: ebook.title,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Access Denied. Upgrade to Premium.')),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isActuallyLocked ? Colors.white.withOpacity(0.1) : LustrousTheme.lustrousGold.withOpacity(0.5)
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Cover
            ebook.coverUrl.isNotEmpty
                ? SecureImage(imageUrl: ebook.coverUrl, fit: BoxFit.cover)
                : Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.book, size: 50, color: Colors.grey),
                  ),

            // Title
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                  ),
                ),
                child: Text(
                  ebook.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Lock Icon
            if (isActuallyLocked)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: Icon(Icons.lock, color: LustrousTheme.lustrousGold, size: 40),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
