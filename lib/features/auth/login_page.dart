import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import '../../core/navigation.dart';
import '../../providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegister = false;
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    final auth = ref.read(authRepositoryProvider);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    try {
      if (_isRegister) {
        await auth.signUp(email: email, password: password);
        if (!mounted) return;
        _showMessage('註冊成功!若收到驗證信,請先到信箱完成驗證再登入。');
        setState(() => _isRegister = false);
      } else {
        await auth.signInWithPassword(email: email, password: password);
        if (!mounted) return;
        _showMessage('登入成功');
        popPage(context);
      }
    } on AuthException catch (error) {
      if (mounted) _showMessage('操作失敗:${error.message}');
    } catch (_) {
      if (mounted) _showMessage('操作失敗,請稍後再試');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('請先在上方填入你的 Email');
      return;
    }
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(email);
      if (mounted) _showMessage('重設密碼信已寄出,請到信箱查收');
    } catch (_) {
      if (mounted) _showMessage('寄送失敗,請稍後再試');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(_isRegister ? '註冊帳號' : '登入'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Icon(Icons.school,
                  size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                _isRegister ? '建立帳號,開始分享你的教學好點子' : '歡迎回來,老師!',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty || !email.contains('@')) {
                    return '請輸入正確的 Email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '密碼',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value ?? '').length < 6 ? '密碼至少 6 碼' : null,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isRegister ? '註冊' : '登入'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() => _isRegister = !_isRegister),
                child: Text(_isRegister ? '已有帳號?改為登入' : '還沒有帳號?註冊一個'),
              ),
              if (!_isRegister)
                TextButton(
                  onPressed: _busy ? null : _forgotPassword,
                  child: const Text('忘記密碼'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
