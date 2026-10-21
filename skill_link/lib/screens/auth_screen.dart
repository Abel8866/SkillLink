import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialMode = AuthMode.signIn});

  final AuthMode initialMode;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum AuthMode { signIn, register }

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AuthMode _mode;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _profileRetryAvailable = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isRegistration => _mode == AuthMode.register;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _profileRetryAvailable = false;
    });

    try {
      if (_isRegistration) {
        await AuthService.instance.register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await AuthService.instance.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on ProfileCreationException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _profileRetryAvailable = true;
      });
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = _friendlyAuthError(error));
    } catch (error) {
      debugPrint('Authentication failed: $error');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _retryProfile() async {
    setState(() => _isSubmitting = true);
    try {
      await AuthService.instance.retryProfileCreation(
        name: _nameController.text,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _errorMessage =
            'Profile setup is still unavailable. Please try again later.',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Enter your email first to reset it.');
      return;
    }
    try {
      await AuthService.instance.sendPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent if the account exists.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _errorMessage = _friendlyAuthError(error));
    }
  }

  String _friendlyAuthError(FirebaseAuthException error) {
    return switch (error.code) {
      'email-already-in-use' => 'An account already uses this email.',
      'invalid-email' => 'Enter a valid email address.',
      'weak-password' => 'Use a stronger password with at least 6 characters.',
      'invalid-credential' ||
      'user-not-found' ||
      'wrong-password' => 'The email or password is incorrect.',
      'network-request-failed' =>
        'Check your internet connection and try again.',
      _ => error.message ?? 'Authentication failed. Please try again.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegistration ? 'Create Account' : 'Sign In'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Icon(
              Icons.lock_person_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              _isRegistration ? 'Join SkillLink' : 'Welcome back',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _isRegistration
                  ? 'Create your customer account to manage your SkillLink activity.'
                  : 'Sign in to access your account and profile.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            if (_isRegistration)
              _field(
                controller: _nameController,
                label: 'Full name',
                icon: Icons.person_outline_rounded,
                validator: (value) => value == null || value.trim().length < 2
                    ? 'Enter your full name'
                    : null,
              ),
            _field(
              controller: _emailController,
              label: 'Email address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null ||
                    !RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(value.trim())) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            _field(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              obscureText: true,
              validator: (value) => value == null || value.length < 6
                  ? 'Password must be at least 6 characters'
                  : null,
            ),
            if (_isRegistration)
              _field(
                controller: _confirmPasswordController,
                label: 'Confirm password',
                icon: Icons.lock_reset_outlined,
                obscureText: true,
                validator: (value) => value != _passwordController.text
                    ? 'Passwords do not match'
                    : null,
              ),
            if (!_isRegistration)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isSubmitting ? null : _resetPassword,
                  child: const Text('Forgot password?'),
                ),
              ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              if (_profileRetryAvailable)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _isSubmitting ? null : _retryProfile,
                    child: const Text('Retry profile setup'),
                  ),
                ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isRegistration ? 'Create Account' : 'Sign In'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _isSubmitting
                  ? null
                  : () => setState(() {
                      _mode = _isRegistration
                          ? AuthMode.signIn
                          : AuthMode.register;
                      _errorMessage = null;
                    }),
              child: Text(
                _isRegistration
                    ? 'Already have an account? Sign in'
                    : 'New to SkillLink? Create an account',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
      ),
    );
  }
}
