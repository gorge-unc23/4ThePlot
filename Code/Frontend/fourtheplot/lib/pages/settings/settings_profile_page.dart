import 'package:flutter/material.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/pages/main_wrapper.dart';
import 'package:fourtheplot/pages/settings/settings_shared.dart';

class SettingsProfilePage extends StatefulWidget {
  const SettingsProfilePage({super.key});

  @override
  State<SettingsProfilePage> createState() => _SettingsProfilePageState();
}

class _SettingsProfilePageState extends State<SettingsProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _avatarController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = MainWrapper.loggedInUser;
    _nameController = TextEditingController(text: user.displayName);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone ?? '');
    _avatarController = TextEditingController(text: user.avatarUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final current = MainWrapper.loggedInUser;
    final updated = current.copyWith(
      displayName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      avatarUrl: _avatarController.text.trim().isEmpty
          ? null
          : _avatarController.text.trim(),
    );
    await DatabaseHelper.instance.saveUser(updated);
    MainWrapper.loggedInUser = updated;
    if (!mounted) return;
    setState(() => _isSaving = false);
    _showMessage('Profile updated locally.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsShell(
      title: 'Profile',
      subtitle: 'Update your account details',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildField(_nameController, 'Display name', Icons.person_outline),
            const SizedBox(height: 12),
            _buildField(
              _emailController,
              'Email',
              Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _buildField(
              _phoneController,
              'Phone',
              Icons.phone_outlined,
              required: false,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _buildField(
              _avatarController,
              'Avatar URL',
              Icons.image_outlined,
              required: false,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: Text(_isSaving ? 'Saving...' : 'Save profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = true,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: required
          ? (value) =>
              value == null || value.trim().isEmpty ? '$label is required' : null
          : null,
    );
  }
}
