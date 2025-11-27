import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nova_tasks/core/widgets/app_text.dart';
import 'package:nova_tasks/core/widgets/primary_button.dart';
import 'package:nova_tasks/core/widgets/primary_text_field.dart';
import 'package:nova_tasks/features/auth/viewmodels/forgot_password_viewmodel.dart';
import 'package:nova_tasks/features/auth/views/login_screen.dart';
import 'package:nova_tasks/features/auth/views/otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final ForgotPasswordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ForgotPasswordViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ForgotPasswordViewModel>.value(
      value: _viewModel,
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatelessWidget {
  const _ForgotPasswordView();

  void _handleSubmit(BuildContext context) {
    context.read<ForgotPasswordViewModel>().sendVerificationCode(
      onSuccess: (email) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => OtpScreen(email: email)),
        );
      },
      onError: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong, try again.')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<ForgotPasswordViewModel>();

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _LogoBadge(),
                  const SizedBox(height: 16),
                  AppText(
                    'NovaTasks',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  _ForgotPasswordCard(
                    viewModel: viewModel,
                    onSubmit: () => _handleSubmit(context),
                  ),
                  const SizedBox(height: 24),
                  Text.rich(
                    TextSpan(
                      text: 'Remembered your password? ',
                      children: [
                        TextSpan(
                          text: 'Log In',
                          style: const TextStyle(
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute<void>(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
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

class _ForgotPasswordCard extends StatelessWidget {
  const _ForgotPasswordCard({required this.viewModel, required this.onSubmit});

  final ForgotPasswordViewModel viewModel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 45,
            offset: Offset(0, 30),
          ),
        ],
      ),
      child: Form(
        key: viewModel.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Forgot Password?',
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 8),
            AppText(
              "Enter your email and we'll send you a link to reset your password.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            PrimaryTextField(
              label: 'Email',
              hint: 'you@example.com',
              controller: viewModel.emailController,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.emailAddress,
              validator: viewModel.validateEmail,
              prefixIcon: Icons.mail_outline_rounded,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: viewModel.isSubmitting ? 'Sending...' : 'Send Reset Link',
              onPressed: viewModel.isSubmitting ? null : onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.task_alt_rounded, color: primary, size: 40),
    );
  }
}
