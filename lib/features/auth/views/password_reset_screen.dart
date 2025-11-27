import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nova_tasks/core/widgets/app_text.dart';
import 'package:nova_tasks/core/widgets/primary_button.dart';
import 'package:nova_tasks/core/widgets/primary_text_field.dart';
import 'package:nova_tasks/features/auth/viewmodels/password_reset_viewmodel.dart';

class PasswordResetScreen extends StatelessWidget {
  const PasswordResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PasswordResetViewModel(),
      child: const _PasswordResetView(),
    );
  }
}

class _PasswordResetView extends StatelessWidget {
  const _PasswordResetView();

  void _handleSubmit(BuildContext context) {
    context.read<PasswordResetViewModel>().submit(
      onSuccess: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password successfully changed!')),
      ),
      onError: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to change password, try again.')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PasswordResetViewModel>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const AppText(
          'Set New Password',
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                const _LogoBadge(),
                const SizedBox(height: 24),
                _ResetCard(
                  viewModel: viewModel,
                  onSubmit: () => _handleSubmit(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResetCard extends StatelessWidget {
  const _ResetCard({required this.viewModel, required this.onSubmit});

  final PasswordResetViewModel viewModel;
  final VoidCallback onSubmit;

  bool get _showStrength => viewModel.newPasswordController.text.isNotEmpty;

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
              'Create New Password',
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 8),
            AppText(
              'Your new password must be different from previously used passwords.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            PrimaryTextField(
              label: 'New Password',
              hint: 'Enter new password',
              controller: viewModel.newPasswordController,
              textInputAction: TextInputAction.next,
              validator: viewModel.validatePassword,
              prefixIcon: Icons.lock_outline_rounded,
              isPassword: true,
            ),
            if (_showStrength) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: viewModel.strengthColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: viewModel.passwordStrength,
                        child: Container(
                          decoration: BoxDecoration(
                            color: viewModel.strengthColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppText(
                    viewModel.strengthLabel,
                    color: viewModel.strengthColor,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            PrimaryTextField(
              label: 'Confirm New Password',
              hint: 'Re-enter password',
              controller: viewModel.confirmPasswordController,
              textInputAction: TextInputAction.done,
              validator: viewModel.validateConfirmPassword,
              prefixIcon: Icons.lock_outline_rounded,
              isPassword: true,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: viewModel.isSubmitting ? 'Resetting...' : 'Reset Password',
              onPressed: viewModel.isSubmitting ? null : onSubmit,
            ),
            if (!viewModel.isSubmitting &&
                viewModel.formKey.currentState?.validate() == true)
              Container(
                margin: const EdgeInsets.only(top: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2ED8A7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    AppText(
                      'Password successfully changed!',
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
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
