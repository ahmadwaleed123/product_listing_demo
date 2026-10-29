import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:product_listing_demo/core/routing/app_routes.dart';
import 'package:product_listing_demo/core/widgets/app_button.dart';
import 'package:product_listing_demo/core/widgets/app_text_field.dart';
import 'package:product_listing_demo/features/auth/store/auth_store.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final _authStore = context.read<AuthStore>();
  late final _usernameController = TextEditingController(text: _authStore.username);
  late final _passwordController = TextEditingController(text: _authStore.password);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    final success = await _authStore.login();
    if (!mounted || !success) return;
    Navigator.pushReplacementNamed(context, AppRoutes.products);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.storefront_outlined, size: 56.r, color: theme.colorScheme.primary),
                  SizedBox(height: 24.h),
                  Text('Welcome back', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  SizedBox(height: 6.h),
                  Text(
                    'Sign in to browse the product catalogue.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  SizedBox(height: 32.h),
                  AppTextField(
                    label: 'Username',
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.username],
                    onChanged: _authStore.setUsername,
                  ),
                  SizedBox(height: 16.h),
                  Consumer<AuthStore>(
                    builder: (_, auth, _) => AppTextField(
                      label: 'Password',
                      controller: _passwordController,
                      obscureText: auth.obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onChanged: auth.setPassword,
                      onSubmitted: (_) => _login(),
                      suffixIcon: IconButton(
                        onPressed: auth.togglePasswordVisibility,
                        icon: Icon(
                          auth.obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 22.r,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 28.h),
                  Consumer<AuthStore>(
                    builder: (_, auth, _) => AppButton(
                      text: 'Sign in',
                      isLoading: auth.isLoading,
                      onPressed: auth.canSubmit ? _login : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
