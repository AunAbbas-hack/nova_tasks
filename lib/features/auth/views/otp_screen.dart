import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nova_tasks/core/widgets/app_text.dart';
import 'package:nova_tasks/core/widgets/primary_button.dart';
import 'package:nova_tasks/features/auth/viewmodels/otp_viewmodel.dart';
import 'package:nova_tasks/features/auth/views/login_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, this.email});

  final String? email;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late final OtpViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = OtpViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OtpViewModel>.value(
      value: _viewModel,
      child: _OtpView(email: widget.email),
    );
  }
}

class _OtpView extends StatelessWidget {
  const _OtpView({required this.email});

  final String? email;

  void _handleVerify(BuildContext context) {
    context.read<OtpViewModel>().verifyCode(
      onSuccess: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code verified successfully!')),
      ),
      onError: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid code, please try again.')),
      ),
    );
  }

  void _handleResend(BuildContext context) {
    context.read<OtpViewModel>().resendCode(
      onSuccess: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent to your email.')),
      ),
      onError: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to resend OTP, try again.')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OtpViewModel>();

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
                  _OtpCard(
                    viewModel: viewModel,
                    email: email,
                    onVerify: () => _handleVerify(context),
                    onResend: () => _handleResend(context),
                  ),
                  const SizedBox(height: 32),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    label: const Text('Back to Login'),
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

class _OtpCard extends StatelessWidget {
  const _OtpCard({
    required this.viewModel,
    required this.onVerify,
    required this.onResend,
    this.email,
  });

  final OtpViewModel viewModel;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final String? email;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText(
            'Check your email',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          AppText(
            "We've sent a 6-digit code to\n${email ?? 'you@example.com'}",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: AppText('Verification Code', fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _OtpFields(viewModel: viewModel),
          const SizedBox(height: 24),
          PrimaryButton(
            label: viewModel.isSubmitting ? 'Verifying...' : 'Verify Code',
            onPressed: viewModel.isSubmitting ? null : onVerify,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: viewModel.isSubmitting ? null : onResend,
            child: AppText(
              "Didn't receive the code? Resend OTP",
              color: Colors.lightBlueAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpFields extends StatelessWidget {
  const _OtpFields({required this.viewModel});

  final OtpViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        viewModel.codeControllers.length,
        (index) => SizedBox(
          width: 48,
          child: TextFormField(
            controller: viewModel.codeControllers[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            decoration: const InputDecoration(counterText: ''),
            onChanged: (value) {
              if (value.length == 1 &&
                  index < viewModel.codeControllers.length - 1) {
                FocusScope.of(context).nextFocus();
              } else if (value.isEmpty && index > 0) {
                FocusScope.of(context).previousFocus();
              }
            },
          ),
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
