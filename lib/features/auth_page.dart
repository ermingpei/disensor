import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/auth_service.dart';
import '../core/app_strings.dart';

/// Unified Login/Register Page for DiSensor
/// Features:
/// - Single page for both login and registration
/// - Password visibility toggle
/// - Forgot password flow
/// - OAuth options (Google, Apple)
/// - Anonymous mode with warning
class AuthPage extends StatefulWidget {
  final VoidCallback onAuthSuccess;

  const AuthPage({super.key, required this.onAuthSuccess});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passwordVisible = false;
  bool _showForgotPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Consumer<AuthService>(
          builder: (context, authService, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // Logo and Title
                  _buildHeader(),
                  const SizedBox(height: 48),

                  // Error Message
                  if (authService.errorMessage != null)
                    _buildErrorBanner(authService.errorMessage!),

                  // Main Form
                  _showForgotPassword
                      ? _buildForgotPasswordForm(authService)
                      : _buildLoginForm(authService),

                  const SizedBox(height: 24),

                  // Divider
                  if (!_showForgotPassword) ...[
                    _buildDivider(),
                    const SizedBox(height: 24),

                    // OAuth Buttons
                    _buildOAuthButtons(authService),
                    const SizedBox(height: 32),

                    // Anonymous Mode
                    _buildAnonymousOption(authService),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Icon
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/icon/icon.png',
            width: 80,
            height: 80,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.sensors,
              size: 80,
              color: Colors.cyanAccent,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Title
        Image.asset(
          'assets/icon/disensor_title.png',
          height: 40,
          errorBuilder: (_, __, ___) => const Text(
            'DiSensor',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.t('auth_subtitle'),
          style: TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent, fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent, size: 18),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).clearError();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(AuthService authService) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: AppStrings.t('email'),
              labelStyle: const TextStyle(color: Colors.white54),
              prefixIcon:
                  const Icon(Icons.email_outlined, color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.cyanAccent),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.t('email_required');
              }
              if (!value.contains('@')) {
                return AppStrings.t('email_invalid');
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password Field with visibility toggle
          TextFormField(
            controller: _passwordController,
            obscureText: !_passwordVisible,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: AppStrings.t('password'),
              labelStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54),
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white54,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.cyanAccent),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.t('password_required');
              }
              if (value.length < 6) {
                return AppStrings.t('password_too_short');
              }
              return null;
            },
          ),
          const SizedBox(height: 8),

          // Forgot Password Link
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _showForgotPassword = true;
                });
              },
              child: Text(
                AppStrings.t('forgot_password'),
                style: const TextStyle(color: Colors.cyanAccent, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Submit Button
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: authService.isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        final success =
                            await authService.signInOrSignUpWithEmail(
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
                        );
                        if (success && mounted) {
                          widget.onAuthSuccess();
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.cyanAccent.withOpacity(0.5),
              ),
              child: authService.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      AppStrings.t('login_register'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordForm(AuthService authService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.t('reset_password_title'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.t('reset_password_desc'),
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: AppStrings.t('email'),
            labelStyle: const TextStyle(color: Colors.white54),
            prefixIcon: const Icon(Icons.email_outlined, color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFF1E293B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: authService.isLoading
                ? null
                : () async {
                    if (_emailController.text.isNotEmpty) {
                      final success = await authService.resetPassword(
                        _emailController.text.trim(),
                      );
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppStrings.t('reset_email_sent')),
                            backgroundColor: Colors.green,
                          ),
                        );
                        setState(() {
                          _showForgotPassword = false;
                        });
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: authService.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    AppStrings.t('send_reset_email'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _showForgotPassword = false;
            });
          },
          child: Text(
            AppStrings.t('back_to_login'),
            style: const TextStyle(color: Colors.white54),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white24)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.t('or'),
            style: const TextStyle(color: Colors.white54),
          ),
        ),
        Expanded(child: Divider(color: Colors.white24)),
      ],
    );
  }

  Widget _buildOAuthButtons(AuthService authService) {
    return Column(
      children: [
        // Google Sign-In
        SizedBox(
          height: 48,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: authService.isLoading
                ? null
                : () async {
                    final success = await authService.signInWithGoogle();
                    if (success && mounted) {
                      widget.onAuthSuccess();
                    }
                  },
            icon: Image.network(
              'https://www.google.com/favicon.ico',
              width: 20,
              height: 20,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.g_mobiledata, size: 24),
            ),
            label: Text(AppStrings.t('continue_with_google')),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Apple Sign-In
        SizedBox(
          height: 48,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: authService.isLoading
                ? null
                : () async {
                    final success = await authService.signInWithApple();
                    if (success && mounted) {
                      widget.onAuthSuccess();
                    }
                  },
            icon: const Icon(Icons.apple, size: 24),
            label: Text(AppStrings.t('continue_with_apple')),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // WeChat placeholder - requires special SDK
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.t('wechat_coming_soon')),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble,
                size: 20, color: Color(0xFF07C160)),
            label: Text(AppStrings.t('continue_with_wechat')),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnonymousOption(AuthService authService) {
    return Column(
      children: [
        const Divider(color: Colors.white12),
        const SizedBox(height: 16),

        // Warning Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.amber, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.t('anonymous_warning'),
                  style: const TextStyle(color: Colors.amber, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        TextButton(
          onPressed: () async {
            await authService.continueAsAnonymous();
            if (mounted) {
              widget.onAuthSuccess();
            }
          },
          child: Text(
            AppStrings.t('continue_anonymous'),
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
