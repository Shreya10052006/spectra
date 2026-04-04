import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/profile_provider.dart';
import '../../models/user_profile.dart';
import '../../widgets/spectra_button.dart';
import '../../widgets/spectra_card.dart';
import '../../navigation/bottom_nav.dart';

/// SPECTRA — Onboarding Journey
/// 11 screens to personalize the experience for autistic individuals.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 11;

  // Temporary state for the current draft profile
  late UserProfile _draftProfile;

  @override
  void initState() {
    super.initState();
    _draftProfile = UserProfile.empty();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() async {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    provider.updateProfile(_draftProfile);
    
    // Set the state in the provider - this will trigger InitialRouter to rebuild
    // and replace the entire OnboardingScreen with BottomNavShell automatically.
    await provider.completeOnboarding();
    
    // Removed redundant Navigator.push which was causing a race condition
    // with the InitialRouter's reactive rebuild.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator (Header)
            if (_currentPage > 0 && _currentPage < _totalPages - 2)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_currentPage) / (_totalPages - 3),
                    backgroundColor: AppColors.primarySoft,
                    color: AppColors.primary,
                    minHeight: 6,
                  ),
                ),
              ),

            // Page View for Onboarding Steps
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Controlled by buttons
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _WelcomeStep(onStart: _nextPage),
                  _NameStep(
                    onNext: (name) {
                      _draftProfile.name = name;
                      _nextPage();
                    },
                  ),
                  _SelectionStep(
                    question: "What is your age group?",
                    options: const ["10–15", "16–20", "21–30"],
                    onSelected: (val) {
                      _draftProfile.ageGroup = val;
                      _nextPage();
                    },
                  ),
                  _SelectionStep(
                    question: "What is your current role?",
                    options: const ["Student", "Adult", "Other"],
                    onSelected: (val) {
                      _draftProfile.role = val;
                      _nextPage();
                    },
                  ),
                  _SelectionStep(
                    question: "How do you feel about noise?",
                    options: const ["Comfortable", "Neutral", "Sensitive"],
                    onSelected: (val) {
                      _draftProfile.noiseSensitivity = val;
                      _nextPage();
                    },
                  ),
                  _SelectionStep(
                    question: "How do you feel in crowded places?",
                    options: const ["Comfortable", "Sometimes uncomfortable", "Uncomfortable"],
                    onSelected: (val) {
                      _draftProfile.socialComfort = val;
                      _nextPage();
                    },
                  ),
                  _SelectionStep(
                    question: "How would you like to communicate?",
                    options: const ["Text", "Voice", "Both"],
                    onSelected: (val) {
                      _draftProfile.communication = val;
                      _nextPage();
                    },
                  ),
                  _MultiSelectStep(
                    question: "What situations feel uncomfortable?",
                    options: const ["Loud sounds", "Crowds", "Talking to strangers", "Waiting in lines"],
                    onNext: (selected) {
                      _draftProfile.triggers = selected;
                      _nextPage();
                    },
                  ),
                  _MultiSelectStep(
                    question: "What are your interests?",
                    subtitle: "Choose what you like (Optional)",
                    options: const ["Food", "Music", "Games", "Travel"],
                    isOptional: true,
                    onNext: (selected) {
                      _draftProfile.interests = selected;
                      _nextPage();
                    },
                  ),
                  _ProcessingStep(onComplete: _nextPage),
                  _CompletionStep(onDone: _completeOnboarding),
                ],
              ),
            ),

            // Back Button (Footer)
            if (_currentPage > 0 && _currentPage < _totalPages - 2)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: TextButton(
                  onPressed: _previousPage,
                  child: Text(
                    "Go Back",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ONBOARDING STEP WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _WelcomeStep extends StatelessWidget {
  final VoidCallback onStart;
  const _WelcomeStep({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 64),
          ),
          const SizedBox(height: 48),
          Text(
            "Welcome to SPECTRA",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Text(
            "We’ll personalize your experience to make things easier for you.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 64),
          SpectraButton(
            label: "Get Started",
            onPressed: onStart,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              // FOR DEMO: Immediate skip to home
              Provider.of<ProfileProvider>(context, listen: false).completeOnboarding();
            },
            child: Text(
              "Skip to Dashboard (Demo)",
              style: TextStyle(color: AppColors.primary.withOpacity(0.6)),
            ),
          ),
        ],
      ),
    );
  }
}

class _NameStep extends StatefulWidget {
  final Function(String) onNext;
  const _NameStep({required this.onNext});

  @override
  State<_NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<_NameStep> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("What should we\ncall you?", style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text("This helps us personalize our chats (Optional)", style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 48),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Enter your name"),
          ),
          const SizedBox(height: 64),
          Center(
            child: SpectraButton(
              label: "Continue",
              onPressed: () => widget.onNext(_controller.text),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionStep extends StatelessWidget {
  final String question;
  final List<String> options;
  final Function(String) onSelected;

  const _SelectionStep({required this.question, required this.options, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 48),
          ...options.map((opt) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SpectraCard(
              onTap: () => onSelected(opt),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(opt, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _MultiSelectStep extends StatefulWidget {
  final String question;
  final String? subtitle;
  final List<String> options;
  final bool isOptional;
  final Function(List<String>) onNext;

  const _MultiSelectStep({required this.question, this.subtitle, required this.options, this.isOptional = false, required this.onNext});

  @override
  State<_MultiSelectStep> createState() => _MultiSelectStepState();
}

class _MultiSelectStepState extends State<_MultiSelectStep> {
  final List<String> _selected = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.question, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700)),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(widget.subtitle!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 40),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widget.options.map((opt) {
              final isSelected = _selected.contains(opt);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selected.remove(opt);
                    } else {
                      _selected.add(opt);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.primarySoft, width: 1.5),
                  ),
                  child: Text(
                    opt,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 64),
          Center(
            child: SpectraButton(
              label: widget.isOptional && _selected.isEmpty ? "Skip" : "Continue",
              onPressed: () => widget.onNext(_selected),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessingStep extends StatefulWidget {
  final VoidCallback onComplete;
  const _ProcessingStep({required this.onComplete});

  @override
  State<_ProcessingStep> createState() => _ProcessingStepState();
}

class _ProcessingStepState extends State<_ProcessingStep> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), widget.onComplete);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
          const SizedBox(height: 48),
          Text(
            "Setting up your personalized\nexperience…",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CompletionStep extends StatelessWidget {
  final VoidCallback onDone;
  const _CompletionStep({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.secondarySoft, shape: BoxShape.circle),
            child: Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 64),
          ),
          const SizedBox(height: 48),
          Text(
            "You’re all set!",
            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Text(
            "SPECTRA is now tailored to your preferences. Let’s begin your journey.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 64),
          SpectraButton(label: "Start Journey", onPressed: onDone),
        ],
      ),
    );
  }
}
