import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';

/// A professional and reusable Login Page supporting Google Sign-In 
/// and a hidden Email Login backdoor for Play Store reviewers.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Service & Controllers
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State Management
  bool _isLoading = false;
  bool _isSettingPassword = false;
  bool _isEmailBackdoorActive = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Logic Methods ---

  Future<void> _handleGoogleSignIn() async {
    _toggleLoading(true);
    _clearError();

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
        // Transition to password setup after successful Google Login
        setState(() {
          _isSettingPassword = true;
          _isLoading = false;
        });
      } else {
        _toggleLoading(false);
      }
    } catch (e) {
      _setError('Gagal masuk dengan Google. Silakan coba lagi.');
      _toggleLoading(false);
    }
  }

  Future<void> _handleEmailSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _setError('Email dan password wajib diisi.');
      return;
    }

    _toggleLoading(true);
    _clearError();

    try {
      final result = await _authService.signInWithEmail(email, password);
      if (result != null && mounted) {
        Navigator.pop(context);
      } else {
        _setError('Email atau password salah.');
        _toggleLoading(false);
      }
    } catch (e) {
      _setError('Terjadi kesalahan teknis. Silakan coba lagi.');
      _toggleLoading(false);
    }
  }

  Future<void> _handleSavePassword() async {
    final password = _passwordController.text.trim();
    if (password.length < 6) {
      _setError('Password minimal harus 6 karakter.');
      return;
    }

    _toggleLoading(true);
    _clearError();

    final success = await _authService.updatePassword(password);
    if (mounted) {
      if (success) {
        Navigator.pop(context);
      } else {
        _setError('Gagal menyimpan password. Silakan coba lagi.');
        _toggleLoading(false);
      }
    }
  }

  // --- Helper Methods ---

  void _toggleLoading(bool value) {
    if (mounted) setState(() => _isLoading = value);
  }

  void _setError(String? message) {
    if (mounted) setState(() => _errorMessage = message);
  }

  void _clearError() => _setError(null);

  // --- UI Components ---

  @override
  Widget build(BuildContext context) {
    // Dynamic page title
    String title = 'Masuk';
    if (_isSettingPassword) title = 'Keamanan Akun';
    if (_isEmailBackdoorActive) title = 'Backdoor Login';

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: (_isSettingPassword || _isEmailBackdoorActive)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _isSettingPassword = false;
                  _isEmailBackdoorActive = false;
                  _clearError();
                }),
              )
            : null,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _isSettingPassword
                ? _buildPasswordSetupView()
                : _isEmailBackdoorActive
                    ? _buildEmailLoginView()
                    : _buildInitialView(),
          ),
        ),
      ),
    );
  }

  /// Default landing view with Google Login.
  Widget _buildInitialView() {
    return Column(
      key: const ValueKey('view_initial'),
      children: [
        // HIDDEN BACKDOOR: Long press this icon to enable email login
        GestureDetector(
          onLongPress: () {
            setState(() {
              _isEmailBackdoorActive = true;
              _clearError();
            });
            Feedback.forLongPress(context);
          },
          child: Icon(
            Icons.account_circle_outlined,
            size: 110,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Selamat Datang',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Masuk untuk sinkronisasi hasil pengamatan Anda ke semua perangkat.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        if (_errorMessage != null) _buildErrorLabel(),
        const SizedBox(height: 54),
        _isLoading
            ? const CircularProgressIndicator()
            : _buildGoogleSignInButton(),
      ],
    );
  }

  /// Hidden Email Login view (primarily for Play Store reviewers).
  Widget _buildEmailLoginView() {
    return Column(
      key: const ValueKey('view_backdoor'),
      children: [
        const Icon(Icons.admin_panel_settings_outlined, size: 80, color: Colors.blueGrey),
        const SizedBox(height: 32),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration('Email', Icons.email_outlined),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: _inputDecoration('Password', Icons.lock_outline),
        ),
        if (_errorMessage != null) _buildErrorLabel(),
        const SizedBox(height: 32),
        _isLoading
            ? const CircularProgressIndicator()
            : SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _handleEmailSignIn,
                  child: const Text('Masuk Backdoor'),
                ),
              ),
      ],
    );
  }

  /// Post-Google login view to set an optional account password.
  Widget _buildPasswordSetupView() {
    return Column(
      key: const ValueKey('view_password_setup'),
      children: [
        const Icon(Icons.security_outlined, size: 80, color: Colors.green),
        const SizedBox(height: 24),
        Text(
          'Tingkatkan Keamanan',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Buat password agar Anda bisa login menggunakan email di aplikasi mitra kami.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _passwordController,
          obscureText: true,
          autofocus: true,
          decoration: _inputDecoration('Password Baru', Icons.password),
        ),
        if (_errorMessage != null) _buildErrorLabel(),
        const SizedBox(height: 32),
        _isLoading
            ? const CircularProgressIndicator()
            : Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _handleSavePassword,
                      child: const Text('Simpan & Selesai'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Lewati untuk Sekarang'),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _handleGoogleSignIn,
        icon: CachedNetworkImage(
          imageUrl: 'https://www.gstatic.com/images/branding/product/1x/googleg_48dp.png',
          height: 24,
          placeholder: (context, url) => const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
          errorWidget: (context, url, error) => const Icon(Icons.login),
        ),
        label: const Text(
          'Lanjutkan dengan Google',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildErrorLabel() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        _errorMessage!,
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }
}
