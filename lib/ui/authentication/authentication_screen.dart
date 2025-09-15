import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/themes/app_theme.dart';
import '../core/widgets/common_widgets.dart';
import 'authentication_view_model.dart';

/// Main authentication screen with sign in and sign up options
class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  // Sign in form controllers
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();

  // Sign up form controllers
  final _signUpNameController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _signUpConfirmPasswordController = TextEditingController();

  bool _isSignInPasswordVisible = false;
  bool _isSignUpPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _signUpConfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthenticationViewModel>(
        builder: (context, authViewModel, child) {
          return LoadingOverlay(
            isLoading: authViewModel.isLoading,
            message: 'Signing you in...',
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Column(
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: AppTheme.spacingXL),
                    
                    // Tab bar
                    _buildTabBar(),
                    const SizedBox(height: AppTheme.spacingL),
                    
                    // Tab content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildSignInForm(authViewModel),
                          _buildSignUpForm(authViewModel),
                        ],
                      ),
                    ),
                    
                    // Error message
                    if (authViewModel.errorMessage != null)
                      _buildErrorMessage(authViewModel.errorMessage!),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
          ),
          child: const Icon(
            Icons.psychology,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Text(
          'Welcome to Chaos Clinic',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          'Your companion for emotional wellbeing',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade700,
        tabs: const [
          Tab(text: 'Sign In'),
          Tab(text: 'Sign Up'),
        ],
      ),
    );
  }

  Widget _buildSignInForm(AuthenticationViewModel viewModel) {
    return Form(
      key: _signInFormKey,
      child: Column(
        children: [
          // Email field
          TextFormField(
            controller: _signInEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Password field
          TextFormField(
            controller: _signInPasswordController,
            obscureText: !_isSignInPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isSignInPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isSignInPasswordVisible = !_isSignInPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.spacingS),
          
          // Forgot password link
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showForgotPasswordDialog(viewModel),
              child: const Text('Forgot Password?'),
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          
          // Sign in button
          PrimaryButton(
            text: 'Sign In',
            width: double.infinity,
            onPressed: () => _signIn(viewModel),
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Divider
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                child: Text(
                  'or',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Google sign in button
          SecondaryButton(
            text: 'Continue with Google',
            icon: Icons.g_mobiledata, // Placeholder - would use Google icon
            width: double.infinity,
            onPressed: () => viewModel.signInWithGoogle(),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm(AuthenticationViewModel viewModel) {
    return Form(
      key: _signUpFormKey,
      child: Column(
        children: [
          // Name field
          TextFormField(
            controller: _signUpNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Email field
          TextFormField(
            controller: _signUpEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Password field
          TextFormField(
            controller: _signUpPasswordController,
            obscureText: !_isSignUpPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isSignUpPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isSignUpPasswordVisible = !_isSignUpPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Confirm password field
          TextFormField(
            controller: _signUpConfirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _signUpPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.spacingL),
          
          // Sign up button
          PrimaryButton(
            text: 'Create Account',
            width: double.infinity,
            onPressed: () => _signUp(viewModel),
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Divider
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                child: Text(
                  'or',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          // Google sign up button
          SecondaryButton(
            text: 'Sign up with Google',
            icon: Icons.g_mobiledata,
            width: double.infinity,
            onPressed: () => viewModel.signInWithGoogle(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      margin: const EdgeInsets.only(top: AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  void _signIn(AuthenticationViewModel viewModel) {
    if (_signInFormKey.currentState?.validate() ?? false) {
      viewModel.signInWithEmail(
        _signInEmailController.text.trim(),
        _signInPasswordController.text,
      );
    }
  }

  void _signUp(AuthenticationViewModel viewModel) {
    if (_signUpFormKey.currentState?.validate() ?? false) {
      viewModel.createAccount(
        _signUpEmailController.text.trim(),
        _signUpPasswordController.text,
        _signUpNameController.text.trim(),
      );
    }
  }

  void _showForgotPasswordDialog(AuthenticationViewModel viewModel) {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email address to receive a password reset link.'),
            const SizedBox(height: AppTheme.spacingM),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            text: 'Send Reset Link',
            onPressed: () {
              if (emailController.text.trim().isNotEmpty) {
                viewModel.sendPasswordResetEmail(emailController.text.trim());
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset email sent!'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}