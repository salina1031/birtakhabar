import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/news_tip.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

/// Lets residents submit a local news tip with an optional photo.
/// Submissions land in `newsTips` with status = pending and are reviewed by
/// an administrator before anything is published (Scope 3.3 / Literature
/// Review re: Paudel, 2022, on unverified Facebook reporting).
class SubmitTipScreen extends StatefulWidget {
  const SubmitTipScreen({super.key});

  @override
  State<SubmitTipScreen> createState() => _SubmitTipScreenState();
}

class _SubmitTipScreenState extends State<SubmitTipScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _firestore = FirestoreService();
  File? _image;
  bool _submitting = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<String?> _uploadImage(String tipId) async {
    if (_image == null) return null;
    final ref = FirebaseStorage.instance.ref('newsTips/$tipId.jpg');
    await ref.putFile(_image!);
    return ref.getDownloadURL();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    setState(() => _submitting = true);
    try {
      final tipId = DateTime.now().millisecondsSinceEpoch.toString();
      final imageUrl = await _uploadImage(tipId);

      final tip = NewsTip(
        id: tipId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl,
        submittedByName: user.name,
        submittedByUid: user.uid,
        contactPhone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        submittedAt: DateTime.now(),
      );
      await _firestore.submitTip(tip);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanks! Your tip was submitted for review.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not submit tip: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit a News Tip')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.fact_check_outlined, color: AppTheme.accent, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Every tip is reviewed by our editorial team before publishing.',
                          style: TextStyle(fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _image == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, color: Colors.grey.shade500, size: 32),
                              const SizedBox(height: 8),
                              Text('Add a photo (optional)', style: TextStyle(color: Colors.grey.shade600)),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_image!, fit: BoxFit.cover),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'What happened?', hintText: 'e.g. Water pipe burst near Mahendra Chowk'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please add a short title' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Details',
                    hintText: 'Where, when, and any details you can share...',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => (v == null || v.trim().length < 10) ? 'Please add a bit more detail' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Contact number (optional)'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Submit Tip'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
