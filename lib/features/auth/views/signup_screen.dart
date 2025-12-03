import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nova_tasks/core/theme/app_colors.dart';
import 'package:nova_tasks/features/home/presentation/views/home_screen.dart';
import 'package:nova_tasks/navigation_wrapper.dart';
import 'package:provider/provider.dart';

import 'package:nova_tasks/core/widgets/app_text.dart';
import 'package:nova_tasks/core/widgets/primary_button.dart';
import 'package:nova_tasks/core/widgets/primary_text_field.dart';
import 'package:nova_tasks/features/auth/viewmodels/signup_viewmodel.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late final SignupViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SignupViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignupViewModel>.value(
      value: _viewModel,
      child: const _SignupView(),
    );
  }
}

class _SignupView extends StatelessWidget {
  const _SignupView();

  void _handleSignup(BuildContext context) {
    context.read<SignupViewModel>().submit(
      onSuccess: () {
        Get.snackbar("Verify Email", "Verification email sent. Please check inbox.",
        titleText: Text("Verify Email",style: TextStyle(color: AppColors.textPrimary),),
          messageText: Text("Verification email sent. Please check inbox.",style: TextStyle(color: AppColors.textPrimary),),
        );
        Navigator.pop(context);
      },
      onError: () => Get.snackbar("Error", "Sign up failed ",
          messageText: Text("Sign Up Failed",style: TextStyle(color: AppColors.textPrimary),)
          ,colorText: Colors.black,titleText: Text("Error",style: TextStyle(color: AppColors.error),),backgroundColor: AppColors.background)
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<SignupViewModel>();

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: viewModel.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const _LogoBadge(),
                    const SizedBox(height: 12),
                    AppText(
                      'TaskFlow',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                    const SizedBox(height: 28),
                    _SignupFormCard(
                      viewModel: viewModel,
                      onSubmit: () => _handleSignup(context),
                    ),
                    const SizedBox(height: 24),
                    Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: const TextStyle(
                              color: Colors.lightBlueAccent,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Navigator.of(context).pop(),
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
      ),
    );
  }
}

class _SignupFormCard extends StatelessWidget {
  const _SignupFormCard({required this.viewModel, required this.onSubmit});

  final SignupViewModel viewModel;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get Starterd',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start to manage your daily tasks',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          PrimaryTextField(
            label: 'Full Name',
            hint: 'Enter your full name',
            controller: viewModel.nameController,
            textInputAction: TextInputAction.next,
            validator: viewModel.validateName,
            prefixIcon: Icons.person_outline_rounded,

          ),
          const SizedBox(height: 20),
          PrimaryTextField(
            errorText: viewModel.emailError,
            label: 'Email',
            hint: 'Enter your email',
            controller: viewModel.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: viewModel.validateEmail,
            prefixIcon: Icons.mail_outline_rounded,
          ),
          const SizedBox(height: 20),
          PrimaryTextField(
            label: 'Password',
            hint: 'Enter your password',
            controller: viewModel.passwordController,
            textInputAction: TextInputAction.next,
            validator: viewModel.validatePassword,
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
          ),
          const SizedBox(height: 20),
          PrimaryTextField(
            label: 'Confirm Password',
            hint: 'Re-enter your password',
            controller: viewModel.confirmPasswordController,
            textInputAction: TextInputAction.done,
            validator: viewModel.validateConfirmPassword,
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: viewModel.isSubmitting ? 'Signing Up...' : 'Sign Up',
            icon: viewModel.isSubmitting ? Icons.hourglass_bottom_rounded : null,
            isSpinning: viewModel.isSubmitting,
            onPressed: viewModel.isSubmitting ? null : onSubmit,
          ),


          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('OR', style: TextStyle(color: Colors.white70)),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: viewModel.isSubmitting
                ? null
                : () {
                   viewModel.signUpWithGoogle(onSuccess: (){
                     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>NavigationWrapper()));
                   });
                  },
            icon: Image.asset(
              'assets/images/icons-google-logo.png',
              width: 24,
              height: 24,
            ),
            label: const Text('Continue with Google'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white30),
              minimumSize: const Size.fromHeight(56),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'By continuing, you agree to our Terms of Service and Privacy Policy.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
            ),
          ),
        ],
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
