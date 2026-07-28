import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safed_prixod/core/core.dart';
import 'package:safed_prixod/core/api_config.dart';
import 'package:safed_prixod/core/app_providers.dart';
import 'package:safed_prixod/core/locale_provider.dart';
import 'package:safed_prixod/l10n/app_strings.dart';

final currentUserProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) async {
  return ref.watch(authApiProvider).fetchMe();
});

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static String _initials(Map<String, dynamic> user) {
    final first = user['first_name']?.toString().trim() ?? '';
    final last = user['last_name']?.toString().trim() ?? '';
    if (first.isEmpty && last.isEmpty) return '?';
    final a = first.isNotEmpty ? first[0] : '';
    final b = last.isNotEmpty ? last[0] : '';
    return '$a$b'.toUpperCase();
  }

  static String _fullName(Map<String, dynamic> user) {
    final first = user['first_name']?.toString().trim() ?? '';
    final last = user['last_name']?.toString().trim() ?? '';
    final name = [first, last].where((s) => s.isNotEmpty).join(' ');
    return name.isNotEmpty ? name : '—';
  }

  static String _groupsLabel(Map<String, dynamic> user) {
    final g = user['groups'];
    if (g is! List || g.isEmpty) return '—';
    return g.map((e) => e.toString()).join(', ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final async = ref.watch(currentUserProvider);

    return SafedScaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        actions: [
          async.maybeWhen(
            data: (user) => IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.profileEditTitle,
              onPressed: () => context.push(
                '/profile/edit',
                extra: {
                  'first_name': user['first_name']?.toString() ?? '',
                  'last_name': user['last_name']?.toString() ?? '',
                },
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(messageFromObject(e), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(currentUserProvider),
                  child: Text(l10n.tryAgain),
                ),
              ],
            ),
          ),
        ),
        data: (user) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(currentUserProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _ProfileHeader(
                initials: _initials(user),
                name: _fullName(user),
                phone: user['phone']?.toString() ?? '—',
                role: _groupsLabel(user),
                l10n: l10n,
                onEdit: () => context.push(
                  '/profile/edit',
                  extra: {
                    'first_name': user['first_name']?.toString() ?? '',
                    'last_name': user['last_name']?.toString() ?? '',
                  },
                ),
              ),
              const SizedBox(height: 20),
              _Section(
                child: _ProfileTile(
                  icon: Icons.notifications_outlined,
                  title: l10n.profileNotifications,
                  onTap: () => context.push('/notifications'),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context, ref),
                  icon: const Icon(Icons.logout, color: AppTheme.priceRed),
                  label: Text(
                    l10n.profileLogout,
                    style: const TextStyle(
                      color: AppTheme.priceRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.priceRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                ApiConfig.appDisplayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = ref.read(l10nProvider);
        return AlertDialog(
          title: Text(l10n.profileLogout),
          content: Text(l10n.profileLogoutConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.dialogNo),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.dialogYes),
            ),
          ],
        );
      },
    );
    if (ok != true) return;
    await ref.read(tokenStorageProvider).clear();
    ref.read(accessTokenProvider.notifier).state = null;
    if (context.mounted) context.go('/login');
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.initials,
    required this.name,
    required this.phone,
    required this.role,
    required this.l10n,
    required this.onEdit,
  });

  final String initials;
  final String name;
  final String phone;
  final String role;
  final AppStrings l10n;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.12),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Material(
                    color: AppTheme.primaryGreen,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onEdit,
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.phone_outlined, label: l10n.phone, value: phone),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.badge_outlined,
            label: l10n.profileRole,
            value: role,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
          ],
          child,
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
