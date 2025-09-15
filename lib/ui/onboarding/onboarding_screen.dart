import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/themes/app_theme.dart';
import '../core/widgets/common_widgets.dart';
import 'onboarding_view_model.dart';

/// Multi-page onboarding screen for new users
class OnboardingScreen extends StatefulWidget {
  final String userId;

  const OnboardingScreen({
    super.key,
    required this.userId,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: LoadingOverlay(
            isLoading: viewModel.isLoading,
            message: 'Setting up your profile...',
            child: SafeArea(
              child: Column(
                children: [
                  // Progress indicator
                  _buildProgressIndicator(viewModel),
                  
                  // Page content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (page) => viewModel.setCurrentPage(page),
                      children: [
                        _buildWelcomePage(viewModel),
                        _buildCopingPreferencePage(viewModel),
                        _buildTrustedContactPage(viewModel),
                      ],
                    ),
                  ),
                  
                  // Navigation buttons
                  _buildNavigationButtons(viewModel),
                  
                  // Error message
                  if (viewModel.errorMessage != null)
                    _buildErrorMessage(viewModel.errorMessage!),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(OnboardingViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= viewModel.currentPage;
          final isCompleted = index < viewModel.currentPage;
          
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: index < 2 ? AppTheme.spacingS : 0,
              ),
              child: Row(
                children: [
                  // Circle indicator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppTheme.primaryColor
                          : isActive
                              ? AppTheme.primaryColor.withOpacity(0.7)
                              : Colors.grey.shade300,
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive ? Colors.white : Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  
                  // Progress line
                  if (index < 2)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.only(left: AppTheme.spacingS),
                        color: isCompleted
                            ? AppTheme.primaryColor
                            : Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomePage(OnboardingViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Welcome illustration
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            ),
            child: const Icon(
              Icons.favorite,
              size: 80,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          
          Text(
            'Welcome to Your Wellness Journey',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingL),
          
          Text(
            'Let\'s take a few moments to personalize your experience. This will help us provide better support for your emotional wellbeing.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXL),
          
          // Features preview
          _buildFeaturesList(),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      (Icons.psychology, 'AI companion "Kanha" for support'),
      (Icons.favorite_border, 'Track your emotional journey'),
      (Icons.groups, 'Connect with trusted contacts'),
      (Icons.games, 'Engaging activities and mini-games'),
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
          child: Row(
            children: [
              Icon(
                feature.$1,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Text(
                  feature.$2,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCopingPreferencePage(OnboardingViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.spacingXL),
          
          Text(
            'What helps you cope with stress?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          Text(
            'Choose the activity that you find most helpful when feeling overwhelmed or stressed.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade700,
                ),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: AppTheme.spacingM,
                mainAxisSpacing: AppTheme.spacingM,
              ),
              itemCount: CopingPreference.values.length,
              itemBuilder: (context, index) {
                final preference = CopingPreference.values[index];
                final isSelected = viewModel.selectedCopingPreference == preference;
                
                return GestureDetector(
                  onTap: () => viewModel.setCopingPreference(preference),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      color: isSelected
                          ? AppTheme.primaryColor.withOpacity(0.1)
                          : Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          preference.emoji,
                          style: const TextStyle(fontSize: 40),
                        ),
                        const SizedBox(height: AppTheme.spacingS),
                        Text(
                          preference.displayName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? AppTheme.primaryColor : Colors.black87,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustedContactPage(OnboardingViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.spacingXL),
          
          Text(
            'Add a trusted contact',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          
          Text(
            'We\'ll only contact this person if you explicitly ask us to, or in emergency situations.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade700,
                ),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Name field
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Contact Name *',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    onChanged: viewModel.setTrustedContactName,
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // Relationship dropdown
                  DropdownButtonFormField<ContactRelationship>(
                    value: viewModel.contactRelationship,
                    decoration: const InputDecoration(
                      labelText: 'Relationship',
                      prefixIcon: Icon(Icons.family_restroom),
                    ),
                    items: ContactRelationship.values.map((relationship) {
                      return DropdownMenuItem(
                        value: relationship,
                        child: Text(relationship.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        viewModel.setContactRelationship(value);
                      }
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // Phone field
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                      hintText: '+1 (555) 123-4567',
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: viewModel.setTrustedContactPhone,
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // Email field
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: 'contact@example.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: viewModel.setTrustedContactEmail,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  
                  // Info note
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.blue.shade200),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade600),
                        const SizedBox(width: AppTheme.spacingS),
                        Expanded(
                          child: Text(
                            'Provide at least one contact method (phone or email)',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildNavigationButtons(OnboardingViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Row(
        children: [
          // Back button
          if (!viewModel.isFirstPage)
            Expanded(
              child: SecondaryButton(
                text: 'Back',
                onPressed: () {
                  viewModel.previousPage();
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          
          if (!viewModel.isFirstPage) const SizedBox(width: AppTheme.spacingM),
          
          // Next/Complete button
          Expanded(
            flex: viewModel.isFirstPage ? 1 : 1,
            child: PrimaryButton(
              text: viewModel.isLastPage ? 'Complete Setup' : 'Continue',
              onPressed: viewModel.canProceedFromCurrentPage
                  ? () {
                      if (viewModel.isLastPage) {
                        viewModel.submitOnboarding();
                      } else {
                        viewModel.nextPage();
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    }
                  : null,
              isDisabled: !viewModel.canProceedFromCurrentPage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingL),
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
}