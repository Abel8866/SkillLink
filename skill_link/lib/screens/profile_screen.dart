import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';
import '../services/image_upload_service.dart';
import '../services/admin_service.dart';
import '../services/user_profile_service.dart';
import '../theme/app_colors.dart';
import '../widgets/profile_image.dart';
import 'auth_screen.dart';
import 'my_bookings_screen.dart';
import 'premium_screen.dart';
import 'provider_registration_screen.dart';
import 'provider_registrations_screen.dart';
import 'admin_dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AuthService.instance,
      builder: (context, _) =>
          _ProfileContent(user: AuthService.instance.currentUser),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSignedIn = user != null;
    final name = isSignedIn ? user!.displayName?.trim() ?? '' : '';
    final initials = _initials(name);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text(
              'Profile',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your account and services',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            if (isSignedIn)
              StreamBuilder(
                stream: UserProfileService.instance.profileStream(user!.uid),
                builder: (context, snapshot) {
                  final imageUrl =
                      snapshot.data?.data()?['profileImageUrl'] as String?;
                  return _AccountSummary(
                    isSignedIn: true,
                    name: name,
                    email: user!.email,
                    initials: initials,
                    imageUrl: imageUrl,
                    onEditProfileImage: () =>
                        _updateProfileImage(context, imageUrl),
                    onSignIn: () => _openAuth(context, AuthMode.signIn),
                    onCreateAccount: () =>
                        _openAuth(context, AuthMode.register),
                    onSignOut: () => _confirmSignOut(context),
                  );
                },
              )
            else
              _AccountSummary(
                isSignedIn: false,
                name: name,
                email: null,
                initials: 'SL',
                onSignIn: () => _openAuth(context, AuthMode.signIn),
                onCreateAccount: () => _openAuth(context, AuthMode.register),
                onSignOut: () => _confirmSignOut(context),
              ),
            const SizedBox(height: 28),
            if (isSignedIn)
              FutureBuilder<bool>(
                future: AdminService.instance.isAdmin(),
                builder: (context, snapshot) {
                  if (snapshot.data != true) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 28),
                    child: _GroupedSurface(
                      children: [
                        _MenuRow(
                          icon: Icons.admin_panel_settings_outlined,
                          title: 'Admin Dashboard',
                          subtitle: 'Review provider applications',
                          onTap: () =>
                              _push(context, const AdminDashboardScreen()),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const _SectionHeader(title: 'Your Activity'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionTile(
                    icon: Icons.event_note_rounded,
                    title: 'My Bookings',
                    subtitle: 'Requests and history',
                    onTap: () => _push(context, const MyBookingsScreen()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionTile(
                    icon: Icons.assignment_rounded,
                    title: 'Provider Registration',
                    subtitle: 'View your submissions',
                    onTap: () =>
                        _push(context, const ProviderRegistrationsScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const _SectionHeader(title: 'For Service Providers'),
            const SizedBox(height: 12),
            _GroupedSurface(
              children: [
                _MenuRow(
                  icon: Icons.person_add_alt_1_rounded,
                  title: 'Register as a Service Provider',
                  subtitle: 'Showcase your skills and reach more customers',
                  onTap: () =>
                      _push(context, const ProviderRegistrationScreen()),
                ),
                _MenuRow(
                  icon: Icons.storefront_rounded,
                  title: 'Grow Your Business',
                  subtitle: 'Get discovered by more local customers',
                  onTap: () => _push(context, const PremiumScreen()),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const _SectionHeader(title: 'Support & Information'),
            const SizedBox(height: 12),
            _GroupedSurface(
              children: [
                _MenuRow(
                  icon: Icons.help_outline_rounded,
                  title: 'Help and Support',
                  subtitle: 'Get help with using SkillLink',
                  onTap: () => _showInfo(
                    context,
                    'Help and Support',
                    'For this local MVP, support contact details are not connected yet.',
                  ),
                ),
                _MenuRow(
                  icon: Icons.info_outline_rounded,
                  title: 'About SkillLink',
                  subtitle: 'Find trusted local services near you',
                  onTap: () => _showInfo(
                    context,
                    'About SkillLink',
                    'SkillLink is a local-services marketplace demo for Addis Ababa.',
                  ),
                ),
                _MenuRow(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Information',
                  subtitle: isSignedIn
                      ? 'Account data is secured with Firebase'
                      : 'Browse publicly or create an account',
                  onTap: () => _showInfo(
                    context,
                    'Privacy Information',
                    'Your account profile is stored securely in Firebase. '
                        'Bookings and provider registrations remain stored locally on this device.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    if (name.trim().isEmpty) return 'SL';
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts
        .take(2)
        .map((part) => part.substring(0, 1))
        .join()
        .toUpperCase();
  }

  static void _openAuth(BuildContext context, AuthMode mode) {
    _push(context, AuthScreen(initialMode: mode));
  }

  static Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'You can continue browsing SkillLink without signing in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await AuthService.instance.signOut();
    } catch (error) {
      debugPrint('Sign out failed: $error');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not sign out. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static Future<void> _updateProfileImage(
    BuildContext context,
    String? previousUrl,
  ) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final image = await ImageUploadService.instance.pickImage(source);
      if (image == null) return;
      final user = AuthService.instance.currentUser;
      if (user == null) return;
      final url = await ImageUploadService.instance.upload(
        file: image,
        path: 'account/${user.uid}/profileImage',
      );
      await UserProfileService.instance.updateProfileImage(
        uid: user.uid,
        imageUrl: url,
      );
      if (previousUrl != null && previousUrl != url) {
        await ImageUploadService.instance.deleteIfPresent(previousUrl);
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile photo updated.')));
    } on ImageValidationException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      debugPrint('Profile image update failed: $error');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update your profile photo.')),
      );
    }
  }

  static void _showInfo(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}

class _AccountSummary extends StatelessWidget {
  const _AccountSummary({
    required this.isSignedIn,
    required this.name,
    required this.email,
    required this.initials,
    this.imageUrl,
    this.onEditProfileImage,
    required this.onSignIn,
    required this.onCreateAccount,
    required this.onSignOut,
  });

  final bool isSignedIn;
  final String name;
  final String? email;
  final String initials;
  final String? imageUrl;
  final VoidCallback? onEditProfileImage;
  final VoidCallback onSignIn;
  final VoidCallback onCreateAccount;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A142B4A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ProfileImage(url: imageUrl, initials: initials, radius: 30),
                  if (isSignedIn)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Material(
                        color: AppColors.secondary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: onEditProfileImage,
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(5),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSignedIn
                          ? (name.isEmpty ? 'SkillLink member' : name)
                          : 'Welcome to SkillLink',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSignedIn
                          ? (email ?? 'Account email unavailable')
                          : 'Sign in to manage your account and bookings.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    if (isSignedIn) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Customer account',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.secondaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isSignedIn)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onSignOut,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign Out'),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onSignIn,
                    child: const Text('Sign In'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCreateAccount,
                    child: const Text('Create Account'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 132),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.secondaryDark),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupedSurface extends StatelessWidget {
  const _GroupedSurface({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1)
              const Divider(height: 1, indent: 64, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          minVerticalPadding: 12,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 21),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
