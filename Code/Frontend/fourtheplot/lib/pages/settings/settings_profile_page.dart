import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/pages/main_wrapper.dart';
import 'package:fourtheplot/pages/settings/settings_shared.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedAvatar;
  String? _avatarUrl;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  ScaffoldMessengerState? _scaffoldMessenger;

  @override
  void initState() {
    super.initState();
    final user = MainWrapper.loggedInUser;
    _nameController = TextEditingController(text: user.displayName);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone ?? '');
    _avatarUrl = user.avatarUrl;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
  }

  @override
  void dispose() {
    _scaffoldMessenger?.clearSnackBars();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;
    setState(() => _selectedAvatar = image);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    var avatarUrl = _avatarUrl;
    final selectedAvatar = _selectedAvatar;
    if (selectedAvatar != null) {
      setState(() => _isUploadingAvatar = true);
      final uploadResult = await DatabaseHelper.instance.uploadCoverImage(
        selectedAvatar,
      );
      if (!mounted) return;
      setState(() => _isUploadingAvatar = false);
      if (!uploadResult.success || uploadResult.data is! String) {
        setState(() => _isSaving = false);
        _showMessage('Could not upload profile photo: ${uploadResult.message}');
        return;
      }
      avatarUrl = uploadResult.data as String;
    }

    final current = MainWrapper.loggedInUser;
    final payload = {
      'display_name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      'avatar_url': avatarUrl,
    };
    final updateResult = await DatabaseHelper.instance.updateUser(
      current.id,
      payload,
    );
    if (!mounted) return;
    if (!updateResult.success) {
      setState(() => _isSaving = false);
      _showMessage('Could not update profile: ${updateResult.message}');
      return;
    }

    final updated = current.copyWith(
      displayName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      avatarUrl: avatarUrl,
    );
    await DatabaseHelper.instance.saveUser(updated);
    MainWrapper.loggedInUser = updated;
    if (!mounted) return;
    setState(() {
      _avatarUrl = avatarUrl;
      _selectedAvatar = null;
      _isSaving = false;
    });
    _showMessage('Profile updated.');
  }

  void _showMessage(String message) {
    final messenger = _scaffoldMessenger ?? ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
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
            _buildAvatarPreview(),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isSaving ? null : _pickAvatar,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Choose profile photo'),
            ),
            const SizedBox(height: 18),
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
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: Text(
                  _isUploadingAvatar
                      ? 'Uploading photo...'
                      : _isSaving
                          ? 'Saving...'
                          : 'Save profile',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPreview() {
    final selectedAvatar = _selectedAvatar;
    final avatarUrl = _avatarUrl?.trim();

    Widget image;
    if (selectedAvatar != null) {
      image = _SelectedAvatarPreview(image: selectedAvatar);
    } else if (avatarUrl != null && avatarUrl.isNotEmpty) {
      image = Image.network(
        avatarUrl,
        width: 104,
        height: 104,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _avatarFallback(),
      );
    } else {
      image = _avatarFallback();
    }

    return ClipOval(
      child: SizedBox(width: 104, height: 104, child: image),
    );
  }

  Widget _avatarFallback() {
    final source = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : MainWrapper.loggedInUser.displayName;
    return Container(
      width: 104,
      height: 104,
      color: const Color(0xFF22D3EE).withValues(alpha: 0.18),
      child: Center(
        child: Text(
          source.isNotEmpty ? source[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 32,
          ),
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

class _SelectedAvatarPreview extends StatelessWidget {
  final XFile image;

  const _SelectedAvatarPreview({required this.image});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(image.path, width: 104, height: 104, fit: BoxFit.cover);
    }
    return Image.file(
      File(image.path),
      width: 104,
      height: 104,
      fit: BoxFit.cover,
    );
  }
}
