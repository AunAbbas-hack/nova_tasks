import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nova_tasks/navigation_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:nova_tasks/core/widgets/app_text.dart';
import 'package:nova_tasks/core/widgets/primary_button.dart';
import 'package:nova_tasks/core/widgets/primary_text_field.dart';
import 'package:nova_tasks/features/auth/views/forgot_password_screen.dart';
import 'package:nova_tasks/features/auth/viewmodels/login_viewmodel.dart';
import 'package:nova_tasks/features/auth/views/signup_screen.dart';

import '../../../core/services/notificationservices/notification_services.dart';
import '../../../core/theme/app_colors.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginViewModel>.value(
      value: _viewModel,
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  void _handleLogin(BuildContext context,) {
    context.read<LoginViewModel>().submit(
      onSuccess: ()async {
      final user=  FirebaseAuth.instance.currentUser;
      if (user != null) {
        await PushNotificationService().init();
        await PushNotificationService().saveUserToken(userId: user.uid);
      }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const NavigationWrapper()),
        );
      },
      onError: () {
        Get.snackbar("", "",
          titleText: Text("Error",style: TextStyle(color: AppColors.error),),
          messageText: Text("Login Failed",style: TextStyle(color: AppColors.textPrimary),),
          backgroundColor: AppColors.background
        );
      } );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<LoginViewModel>();

    return Scaffold(
      body: SafeArea(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Form(
                      key: viewModel.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const _LogoBadge(),
                          const SizedBox(height: 12),
                          AppText(
                            'Nova Tasks',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                          const SizedBox(height: 28),
                          _LoginFormCard(
                            viewModel: viewModel,
                            onSubmit: () => _handleLogin(context),
                          ),
                          const SizedBox(height: 24),
                          Text.rich(
                            TextSpan(
                              text: "Don't have an account? ",
                              children: [
                                TextSpan(
                                  text: 'Sign Up',
                                  style: const TextStyle(
                                    color: Colors.lightBlueAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => const SignupScreen(),
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
            ),
    );
  }
}

class _LoginFormCard extends StatelessWidget {
  const _LoginFormCard({required this.viewModel, required this.onSubmit});

  final LoginViewModel viewModel;
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
            'Welcome Back!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Log in to manage your daily tasks',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          PrimaryTextField(
            label: 'Email',
            hint: 'you@example.com',
            controller: viewModel.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: viewModel.validateEmail,
            prefixIcon: Icons.mail_outline_rounded,
            errorText: viewModel.emailError,
          ),
          const SizedBox(height: 20),
          PrimaryTextField(
            label: 'Password',
            hint: 'Enter your password',
            controller: viewModel.passwordController,
            textInputAction: TextInputAction.done,
            validator: viewModel.validatePassword,
            prefixIcon: Icons.lock_outline_rounded,
            errorText: viewModel.passwordError,
            isPassword: true,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Hook into Forgot Password flow.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgotPasswordScreen(),
                  ),
                );
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Colors.lightBlueAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: viewModel.isSubmitting ? 'Logging In...' : 'Log In',
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
                child: Text('or', style: TextStyle(color: Colors.white70)),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: viewModel.isSubmitting
                ? null
                : () {
              viewModel.signUpWithGoogle(onSuccess: ()async{
                final user=  FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await PushNotificationService().init();
                  await PushNotificationService().saveUserToken(userId: user.uid);
                }
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>NavigationWrapper()));
              });
                  },
            icon: Image.asset(
              'assets/images/icons-google-logo.png',
              width: 24,
              height: 24,
            ),
            label: const Text('Sign in with Google'),
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
