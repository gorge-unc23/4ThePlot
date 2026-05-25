import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/models/user.dart';
import 'package:fourtheplot/pages/login/login_page.dart';
import 'package:fourtheplot/pages/main_wrapper.dart';
import 'package:fourtheplot/pages/signup/signup_draft.dart';
import 'package:fourtheplot/widgets/glassmorphism.dart';
import 'package:image_picker/image_picker.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _accountFormKey = GlobalKey<FormState>();
  final _specificsFormKey = GlobalKey<FormState>();
  final _draft = SignupDraft();
  final _picker = ImagePicker();

  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _categoriesController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  final _businessWebsiteController = TextEditingController();

  int _step = 0;
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _serverError;

  bool get _isServerConfigMode {
    return _emailController.text.trim().toLowerCase() == 'server';
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _categoriesController.dispose();
    _businessNameController.dispose();
    _businessDescriptionController.dispose();
    _businessWebsiteController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    FocusScope.of(context).unfocus();
    if (_step == 0) {
      if (!_accountFormKey.currentState!.validate()) return;
      _syncAccountDraft();
      if (_isServerConfigMode) {
        await _saveServerIp();
        return;
      }
      setState(() => _step = 1);
      return;
    }

    if (_step == 1) {
      if (_draft.avatarImage == null) {
        _showMessage('Select a profile photo.');
        return;
      }
      if (_draft.isBusiness && _draft.businessLogoImage == null) {
        _showMessage('Select a business logo.');
        return;
      }
      setState(() => _step = 2);
      return;
    }

    if (_step == 2) {
      if (!_specificsFormKey.currentState!.validate()) return;
      _syncSpecificsDraft();
      setState(() => _step = 3);
      return;
    }

    await _submitSignup();
  }

  void _handleBack() {
    if (_isSubmitting) return;

    setState(() => _step--);
  }

  Future<void> _saveServerIp() async {
    setState(() => _isSubmitting = true);
    await DatabaseHelper.instance.saveServerIp(_passwordController.text);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    _showMessage('Server set to ${DatabaseHelper.instance.serverIp}');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> _submitSignup() async {
    setState(() {
      _isSubmitting = true;
      _serverError = null;
    });

    final avatarResult = await DatabaseHelper.instance.uploadImage(
      _draft.avatarImage!,
    );
    if (!mounted) return;
    if (!avatarResult.success || avatarResult.data is! String) {
      setState(() {
        _isSubmitting = false;
        _step = 1;
      });
      _showMessage('Could not upload profile photo: ${avatarResult.message}');
      return;
    }

    String? logoUrl;
    if (_draft.isBusiness) {
      final logoResult = await DatabaseHelper.instance.uploadImage(
        _draft.businessLogoImage!,
      );
      if (!mounted) return;
      if (!logoResult.success || logoResult.data is! String) {
        setState(() {
          _isSubmitting = false;
          _step = 1;
        });
        _showMessage('Could not upload business logo: ${logoResult.message}');
        return;
      }
      logoUrl = logoResult.data as String;
    }

    final createResult = await DatabaseHelper.instance.createUser(
      _draft.toPayload(
        avatarUrl: avatarResult.data as String,
        businessLogoUrl: logoUrl,
      ),
    );
    if (!mounted) return;
    if (!createResult.success) {
      setState(() {
        _isSubmitting = false;
        _serverError = createResult.message;
      });
      return;
    }

    final loginResult = await DatabaseHelper.instance.login(
      _draft.email.trim(),
      _draft.password,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!loginResult.success) {
      _showMessage('Account created. Please log in.');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainWrapper()),
    );
  }

  void _syncAccountDraft() {
    _draft
      ..displayName = _displayNameController.text.trim()
      ..email = _emailController.text.trim()
      ..phone = _phoneController.text.trim()
      ..password = _passwordController.text
      ..confirmPassword = _confirmPasswordController.text;
  }

  void _syncSpecificsDraft() {
    _draft
      ..categoriesText = _categoriesController.text.trim()
      ..businessName = _businessNameController.text.trim()
      ..businessDescription = _businessDescriptionController.text.trim()
      ..businessWebsite = _businessWebsiteController.text.trim();
  }

  Future<void> _pickImage({required bool businessLogo}) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;
    setState(() {
      if (businessLogo) {
        _draft.businessLogoImage = image;
      } else {
        _draft.avatarImage = image;
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background/partyVibe.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Glassmorphism(
                  radius: 24,
                  blur: 14,
                  opacity: 0.45,
                  color: Colors.black,
                  padding: const EdgeInsets.all(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _subtitle,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                      ),
                      const SizedBox(height: 18),
                      _StepIndicator(step: _step),
                      const SizedBox(height: 18),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: KeyedSubtree(
                          key: ValueKey(_step),
                          child: _buildStep(),
                        ),
                      ),
                      if (_serverError != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _serverError!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          if (_step != 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isSubmitting ? null : _handleBack,
                                child: Text('Back'),
                              ),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _handleNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade500,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(_step == 3 ? 'Create account' : 'Next'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: TextButton(
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                  );
                                },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue.shade200,
                          ),
                          child: const Text('Already have an account? Log in'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _title {
    switch (_step) {
      case 1:
        return 'Add photos';
      case 2:
        return _draft.isBusiness ? 'Business profile' : 'Your interests';
      case 3:
        return 'Confirm signup';
      case 0:
      default:
        return 'Create account';
    }
  }

  String get _subtitle {
    switch (_step) {
      case 1:
        return 'Upload the photos used on your profile.';
      case 2:
        return _draft.isBusiness
            ? 'Tell users who is hosting the events.'
            : 'Help us personalize discovery.';
      case 3:
        return 'Review the details before creating your account.';
      case 0:
      default:
        return 'Sign up to start using 4ThePlot.';
    }
  }

  Widget _buildStep() {
    switch (_step) {
      case 1:
        return _buildPhotosStep();
      case 2:
        return _buildSpecificsStep();
      case 3:
        return _buildSummaryStep();
      case 0:
      default:
        return _buildAccountStep();
    }
  }

  Widget _buildAccountStep() {
    return Form(
      key: _accountFormKey,
      child: Column(
        children: [
          SegmentedButton<UserRole>(
            segments: const [
              ButtonSegment(value: UserRole.goer, label: Text('Goer')),
              ButtonSegment(value: UserRole.business, label: Text('Business')),
            ],
            selected: {_draft.role},
            onSelectionChanged: _isSubmitting
                ? null
                : (selection) {
                    setState(() => _draft.role = selection.first);
                  },
          ),
          const SizedBox(height: 12),
          _field(
            controller: _displayNameController,
            hint: 'Display name',
            icon: Icons.person_outline,
            validator: (value) {
              if (_isServerConfigMode) return null;
              return _required(value, 'Display name is required');
            },
          ),
          const SizedBox(height: 12),
          _field(
            controller: _emailController,
            hint: 'Email address',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() {}),
            validator: (value) {
              if ((value ?? '').trim().toLowerCase() == 'server') return null;
              final emailRegExp = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$',
              );
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!emailRegExp.hasMatch(value.trim())) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _field(
            controller: _phoneController,
            hint: 'Phone (optional)',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (_) => null,
          ),
          const SizedBox(height: 12),
          _passwordField(
            controller: _passwordController,
            hint: _isServerConfigMode ? 'New server IP' : 'Password',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return _isServerConfigMode
                    ? 'Server IP is required'
                    : 'Password is required';
              }
              if (!_isServerConfigMode && value.length < 5) {
                return 'Use at least 5 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _passwordField(
            controller: _confirmPasswordController,
            hint: 'Confirm password',
            validator: (value) {
              if (_isServerConfigMode) return null;
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value != _passwordController.text) {
                return 'Passwords must match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosStep() {
    return Column(
      children: [
        _PhotoPickerCard(
          title: 'Profile photo',
          image: _draft.avatarImage,
          emptyText: 'No profile photo selected',
          onPick: () => _pickImage(businessLogo: false),
          onRemove: () => setState(() => _draft.avatarImage = null),
        ),
        if (_draft.isBusiness) ...[
          const SizedBox(height: 12),
          _PhotoPickerCard(
            title: 'Business logo',
            image: _draft.businessLogoImage,
            emptyText: 'No business logo selected',
            onPick: () => _pickImage(businessLogo: true),
            onRemove: () => setState(() => _draft.businessLogoImage = null),
          ),
        ],
      ],
    );
  }

  Widget _buildSpecificsStep() {
    if (_draft.isBusiness) {
      return Form(
        key: _specificsFormKey,
        child: Column(
          children: [
            _field(
              controller: _businessNameController,
              hint: 'Business name',
              icon: Icons.storefront_outlined,
              validator: (value) => _required(value, 'Business name is required'),
            ),
            const SizedBox(height: 12),
            _field(
              controller: _businessDescriptionController,
              hint: 'Business description',
              icon: Icons.notes_outlined,
              minLines: 3,
              maxLines: 4,
              validator: (value) =>
                  _required(value, 'Business description is required'),
            ),
            const SizedBox(height: 12),
            _field(
              controller: _businessWebsiteController,
              hint: 'Website (optional)',
              icon: Icons.link,
              keyboardType: TextInputType.url,
              validator: (_) => null,
            ),
          ],
        ),
      );
    }

    return Form(
      key: _specificsFormKey,
      child: _field(
        controller: _categoriesController,
        hint: 'Preferred categories (comma separated)',
        icon: Icons.category_outlined,
        minLines: 2,
        maxLines: 3,
        validator: (_) => null,
      ),
    );
  }

  Widget _buildSummaryStep() {
    final rows = [
      _SummaryRow('Role', userRoleToString(_draft.role)),
      _SummaryRow('Name', _draft.displayName),
      _SummaryRow('Email', _draft.email),
      if (_draft.phone.isNotEmpty) _SummaryRow('Phone', _draft.phone),
      _SummaryRow('Avatar', _draft.avatarImage?.name ?? 'Selected'),
      if (_draft.isBusiness) ...[
        _SummaryRow('Business', _draft.businessName),
        _SummaryRow('Logo', _draft.businessLogoImage?.name ?? 'Selected'),
      ] else
        _SummaryRow(
          'Categories',
          _draft.categories.isEmpty ? 'None selected' : _draft.categories.join(', '),
        ),
      const _SummaryRow('Trusted', 'No'),
      const _SummaryRow('Rating', '0.0 (0 reviews)'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(children: rows),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_isSubmitting,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(hint, icon),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_isSubmitting,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(hint, Icons.lock_outline).copyWith(
        suffixIcon: IconButton(
          onPressed: _isSubmitting
              ? null
              : () => setState(() => _obscurePassword = !_obscurePassword),
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          tooltip: _obscurePassword ? 'Show password' : 'Hide password',
        ),
      ),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
      prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.blue.shade300, width: 1.5),
      ),
    );
  }

  String? _required(String? value, String message) {
    return value == null || value.trim().isEmpty ? message : null;
  }
}

class _StepIndicator extends StatelessWidget {
  final int step;

  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        final active = index <= step;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
            decoration: BoxDecoration(
              color: active ? Colors.blue.shade300 : Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}

class _PhotoPickerCard extends StatelessWidget {
  final String title;
  final XFile? image;
  final String emptyText;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _PhotoPickerCard({
    required this.title,
    required this.image,
    required this.emptyText,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (image == null)
            Container(
              height: 128,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Center(
                child: Text(
                  emptyText,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
                ),
              ),
            )
          else
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: 128,
                    width: double.infinity,
                    child: _ImagePreview(image: image!, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(image == null ? 'Select photo' : 'Replace photo'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final XFile image;
  final BoxFit fit;

  const _ImagePreview({required this.image, required this.fit});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(image.path, fit: fit);
    }
    return Image.file(File(image.path), fit: fit);
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.58)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
