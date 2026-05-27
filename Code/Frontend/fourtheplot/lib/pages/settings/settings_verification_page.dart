import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/models/admin/admin_models.dart';
import 'package:fourtheplot/pages/main_wrapper.dart';
import 'package:fourtheplot/pages/settings/settings_shared.dart';

class SettingsVerificationPage extends StatefulWidget {
  const SettingsVerificationPage({super.key});

  @override
  State<SettingsVerificationPage> createState() =>
      _SettingsVerificationPageState();
}

class _SettingsVerificationPageState extends State<SettingsVerificationPage> {
  List<AdminHostVerificationRequest> _requests = const [];
  _SelectedDocument? _document;
  String _documentType = 'identity';
  bool _isLoading = true;
  bool _isSubmitting = false;
  int? _deletingRequestId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (MainWrapper.loggedInUser.hostCredibility?.trusted == true) {
      _isLoading = false;
      return;
    }
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await DatabaseHelper.instance.getMyHostVerificationRequests();
    if (!mounted) return;
    if (!result.success || result.data is! List<AdminHostVerificationRequest>) {
      setState(() {
        _requests = const [];
        _isLoading = false;
        _errorMessage = result.message;
      });
      return;
    }
    setState(() {
      _requests = result.data as List<AdminHostVerificationRequest>;
      _isLoading = false;
    });
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: false,
    );
    final file = result?.files.single;
    if (file == null || file.path == null) return;
    if (!file.name.toLowerCase().endsWith('.pdf')) {
      _showMessage('Only PDF documents are allowed.');
      return;
    }
    setState(() {
      _document = _SelectedDocument(
        type: _documentType,
        path: file.path!,
        name: file.name,
      );
    });
  }

  Future<void> _submitRequest() async {
    final document = _document;
    if (document == null) {
      _showMessage('Select a PDF document first.');
      return;
    }

    setState(() => _isSubmitting = true);
    final createResult =
        await DatabaseHelper.instance.createMyHostVerificationRequest();
    if (!mounted) return;
    if (!createResult.success ||
        createResult.data is! AdminHostVerificationRequest) {
      setState(() => _isSubmitting = false);
      _showMessage(
        'Could not create verification request: ${createResult.message}',
      );
      return;
    }

    final request = createResult.data as AdminHostVerificationRequest;
    final uploadResult = await DatabaseHelper.instance.uploadHostVerificationPdf(
      path: document.path,
      filename: document.name,
    );
    if (!mounted) return;
    if (!uploadResult.success || uploadResult.data is! Map<String, dynamic>) {
      setState(() => _isSubmitting = false);
      _showMessage('Could not upload document: ${uploadResult.message}');
      return;
    }

    final documentUrl =
        (uploadResult.data as Map<String, dynamic>)['documentUrl']?.toString();
    if (documentUrl == null || documentUrl.isEmpty) {
      setState(() => _isSubmitting = false);
      _showMessage('Upload did not return a document URL.');
      return;
    }

    final documentResult =
        await DatabaseHelper.instance.addMyHostVerificationDocument(
      request.id,
      documentType: document.type,
      documentUrl: documentUrl,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!documentResult.success) {
      _showMessage('Could not attach document: ${documentResult.message}');
      return;
    }

    setState(() => _document = null);
    _showMessage('Verification request created.');
    await _loadRequests();
  }

  Future<void> _deleteRequest(AdminHostVerificationRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete request?'),
        content: const Text(
          'This verification request and its documents will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _deletingRequestId = request.id);
    final result = await DatabaseHelper.instance.deleteMyHostVerificationRequest(
      request.id,
    );
    if (!mounted) return;
    setState(() => _deletingRequestId = null);
    if (!result.success) {
      _showMessage('Could not delete request: ${result.message}');
      return;
    }
    setState(() {
      _requests = _requests.where((item) => item.id != request.id).toList();
    });
    _showMessage('Verification request deleted.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = MainWrapper.loggedInUser;
    final trusted = user.hostCredibility?.trusted == true;
    return SettingsShell(
      title: 'Verification',
      subtitle: 'Trusted status and documents',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      trusted ? Icons.verified : Icons.error_outline,
                      color: trusted
                          ? const Color(0xFF34D399)
                          : const Color(0xFFFACC15),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      trusted ? 'Trusted account' : 'Untrusted account',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  trusted
                      ? 'Your account is verified for trusted host activity.'
                      : 'Upload verification documents for admin review.',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          if (trusted)
            const SettingsCard(
              child: Text(
                'No further action is required.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          else ...[
            const SizedBox(height: 16),
            _buildRequestsSection(),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _documentType,
              decoration: const InputDecoration(labelText: 'Document type'),
              items: const [
                DropdownMenuItem(value: 'identity', child: Text('Identity')),
                DropdownMenuItem(
                  value: 'proof_of_address',
                  child: Text('Proof of address'),
                ),
                DropdownMenuItem(
                  value: 'business_document',
                  child: Text('Business document'),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _documentType = value ?? 'identity'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isSubmitting ? null : _pickDocument,
              icon: const Icon(Icons.upload_file),
              label: const Text('Choose PDF document'),
            ),
            const SizedBox(height: 12),
            if (_document != null)
              SettingsCard(
                child: Text(
                  '${_document!.type.replaceAll('_', ' ')}\n${_document!.name}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                child: Text(_isSubmitting ? 'Submitting...' : 'Submit for review'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequestsSection() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_errorMessage != null) {
      return SettingsCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Could not load requests: $_errorMessage',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _loadRequests,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }
    if (_requests.isEmpty) {
      return const SettingsCard(
        child: Text(
          'You have no verification requests yet.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your requests', style: settingsSectionTitleStyle),
        const SizedBox(height: 10),
        ..._requests.map(_buildRequestCard),
      ],
    );
  }

  Widget _buildRequestCard(AdminHostVerificationRequest request) {
    final deleting = _deletingRequestId == request.id;
    return SettingsCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.status.replaceAll('_', ' '),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${request.documents.length} document(s)',
                  style: const TextStyle(color: Colors.white54),
                ),
                if (request.reviewReason?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    request.reviewReason!,
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: deleting ? null : () => _deleteRequest(request),
            tooltip: 'Delete request',
            icon: deleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }
}

class _SelectedDocument {
  final String type;
  final String path;
  final String name;

  const _SelectedDocument({
    required this.type,
    required this.path,
    required this.name,
  });
}
