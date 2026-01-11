import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/auth_service.dart';
import '../core/app_strings.dart';

/// Unified Login/Register Page for DiSensor
/// Features:
/// - Email/Password login & registration
/// - OAuth options (Google, Apple, WeChat, Alipay)
/// - Anonymous mode with warning
/// - Email verification pending state
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
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _passwordVisible = false;
  bool _showForgotPassword = false;
  bool _isEmailMode = true; // true = email, false = phone
  bool _otpSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Consumer<AuthService>(
          builder: (context, authService, _) {
            // Show email verification pending screen
            if (authService.pendingEmailVerification) {
              return _buildVerificationPendingScreen(authService);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 32),

                  // Error Message
                  if (authService.errorMessage != null)
                    _buildErrorBanner(authService.errorMessage!),

                  // Forgot Password Form or Main Login
                  if (_showForgotPassword)
                    _buildForgotPasswordForm(authService)
                  else ...[
                    // Login Mode Toggle (Email / Phone)
                    _buildLoginModeToggle(),
                    const SizedBox(height: 20),

                    // Email or Phone Login Form
                    if (_isEmailMode)
                      _buildEmailForm(authService)
                    else
                      _buildPhoneForm(authService),

                    const SizedBox(height: 24),
                    _buildDivider(),
                    const SizedBox(height: 20),

                    // OAuth Buttons Row
                    _buildOAuthButtonsRow(authService),
                    const SizedBox(height: 28),

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
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/icon/icon.png',
            width: 72,
            height: 72,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.sensors,
              size: 72,
              color: Colors.cyanAccent,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Image.asset(
          'assets/icon/disensor_title.png',
          height: 36,
          errorBuilder: (_, __, ___) => const Text(
            'DiSensor',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.t('auth_subtitle'),
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildVerificationPendingScreen(AuthService authService) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mark_email_unread,
              size: 80, color: Colors.cyanAccent),
          const SizedBox(height: 24),
          Text(
            AppStrings.t('verify_email_title'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.t('verify_email_desc'),
            style: const TextStyle(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Resend button
          OutlinedButton.icon(
            onPressed: authService.isLoading
                ? null
                : () async {
                    final success = await authService.resendVerificationEmail();
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppStrings.t('verification_resent')),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
            icon: authService.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh),
            label: Text(AppStrings.t('resend_verification')),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.cyanAccent,
              side: const BorderSide(color: Colors.cyanAccent),
            ),
          ),
          const SizedBox(height: 16),

          // Back to login
          TextButton(
            onPressed: () {
              authService.clearPendingVerification();
              authService.signOut();
            },
            child: Text(
              AppStrings.t('back_to_login'),
              style: const TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
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

  /// Login mode toggle (Email / Phone)
  Widget _buildLoginModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _isEmailMode = true;
                _otpSent = false;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isEmailMode ? Colors.cyanAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppStrings.t('email_login'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isEmailMode ? Colors.black : Colors.white54,
                    fontWeight:
                        _isEmailMode ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _showComingSoon(AppStrings.t('phone_login')),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      AppStrings.t('phone_login'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontWeight: FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        AppStrings.languageCode == 'zh' ? '即将' : 'Soon',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Phone OTP login form (placeholder for future use)
  Widget _buildPhoneForm(AuthService authService) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
              label: AppStrings.t('phone_number'),
              icon: Icons.phone_outlined,
              hint: '+1 234 567 8900',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.languageCode == 'zh'
                    ? '请输入手机号'
                    : 'Phone required';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          if (_otpSent) ...[
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                label: AppStrings.t('verification_code'),
                icon: Icons.pin_outlined,
              ),
              validator: (value) {
                if (value == null || value.length < 4) {
                  return AppStrings.languageCode == 'zh'
                      ? '请输入验证码'
                      : 'OTP required';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
          ],
          _buildSubmitButton(
            authService: authService,
            label: _otpSent
                ? AppStrings.t('verify_and_login')
                : AppStrings.t('send_code'),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (!_otpSent) {
                  final success = await authService.sendPhoneOtp(
                    _phoneController.text.trim(),
                  );
                  if (success && mounted) {
                    setState(() => _otpSent = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppStrings.t('code_sent')),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  final success = await authService.verifyPhoneOtp(
                    phone: _phoneController.text.trim(),
                    otp: _otpController.text.trim(),
                  );
                  if (success && mounted) {
                    widget.onAuthSuccess();
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmailForm(AuthService authService) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
              label: AppStrings.t('email'),
              icon: Icons.email_outlined,
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
          const SizedBox(height: 14),
          TextFormField(
            controller: _passwordController,
            obscureText: !_passwordVisible,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
              label: AppStrings.t('password'),
              icon: Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white54,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _passwordVisible = !_passwordVisible),
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
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => setState(() => _showForgotPassword = true),
              child: Text(
                AppStrings.t('forgot_password'),
                style: const TextStyle(color: Colors.cyanAccent, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildSubmitButton(
            authService: authService,
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final success = await authService.signInOrSignUpWithEmail(
                  email: _emailController.text.trim(),
                  password: _passwordController.text,
                );
                if (success && authService.isEmailVerified && mounted) {
                  widget.onAuthSuccess();
                }
              }
            },
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
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(
            label: AppStrings.t('email'),
            icon: Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 24),
        _buildSubmitButton(
          authService: authService,
          label: AppStrings.t('send_reset_email'),
          onPressed: () async {
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
                setState(() => _showForgotPassword = false);
              }
            }
          },
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _showForgotPassword = false),
          child: Text(
            AppStrings.t('back_to_login'),
            style: const TextStyle(color: Colors.white54),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton({
    required AuthService authService,
    required VoidCallback onPressed,
    String? label,
  }) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: authService.isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyanAccent,
          foregroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          disabledBackgroundColor: Colors.cyanAccent.withValues(alpha: 0.5),
        ),
        child: authService.isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.black, strokeWidth: 2),
              )
            : Text(
                label ?? AppStrings.t('login_register'),
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.white24)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.t('or'),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
        const Expanded(child: Divider(color: Colors.white24)),
      ],
    );
  }

  /// OAuth buttons displayed in a row with icons
  Widget _buildOAuthButtonsRow(AuthService authService) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Google (Enabled) - Official Logo
        _buildOAuthImageButton(
          imagePath: 'assets/icon/google_logo.png',
          label: 'Google',
          bgColor: Colors.white,
          enabled: true,
          onPressed: () async {
            final success = await authService.signInWithGoogle();
            if (success && mounted) {
              widget.onAuthSuccess();
            }
          },
        ),

        // Apple (Coming Soon)
        _buildOAuthIconButton(
          icon: Icons.apple,
          label: 'Apple',
          color: Colors.white,
          bgColor: Colors.black,
          enabled: false,
          onPressed: () => _showComingSoon('Apple'),
        ),

        // WeChat (Coming Soon)
        _buildOAuthIconButton(
          icon: Icons.wechat,
          label: AppStrings.languageCode == 'zh' ? '微信' : 'WeChat',
          color: Colors.white,
          bgColor: const Color(0xFF07C160),
          enabled: false,
          onPressed: () => _showComingSoon(
              AppStrings.languageCode == 'zh' ? '微信' : 'WeChat'),
        ),

        // Alipay (Coming Soon) - Official Logo
        _buildOAuthImageButton(
          imagePath: 'assets/icon/alipay_logo.png',
          label: AppStrings.languageCode == 'zh' ? '支付宝' : 'Alipay',
          bgColor: const Color(0xFF1677FF),
          enabled: false,
          onPressed: () => _showComingSoon(
              AppStrings.languageCode == 'zh' ? '支付宝' : 'Alipay'),
        ),
      ],
    );
  }

  /// OAuth button with image asset
  Widget _buildOAuthImageButton({
    required String imagePath,
    required String label,
    required Color bgColor,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: enabled ? bgColor : bgColor.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: enabled ? Colors.white24 : Colors.white12,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    width: 40,
                    height: 40,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.login, color: Colors.grey, size: 28),
                  ),
                ),
              ),
            ),
            if (!enabled)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    AppStrings.languageCode == 'zh' ? '即将' : 'Soon',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: enabled ? Colors.white70 : Colors.white38,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildOAuthIconButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: enabled ? bgColor : bgColor.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: enabled ? Colors.white24 : Colors.white12,
                  ),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
            ),
            if (!enabled)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    AppStrings.languageCode == 'zh' ? '即将' : 'Soon',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: enabled ? Colors.white70 : Colors.white38,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  void _showComingSoon(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.languageCode == 'zh'
              ? '$provider 登录即将上线！'
              : '$provider login coming soon!',
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildAnonymousOption(AuthService authService) {
    return Column(
      children: [
        // Button first, then warning
        TextButton(
          onPressed: () async {
            await authService.continueAsAnonymous();
            if (mounted) {
              widget.onAuthSuccess();
            }
          },
          child: Text(
            AppStrings.t('continue_anonymous'),
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.amber, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppStrings.t('anonymous_warning'),
                  style: const TextStyle(color: Colors.amber, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 14),
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.white54, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFF1E293B),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.cyanAccent),
      ),
      errorStyle: const TextStyle(fontSize: 11),
    );
  }
}
