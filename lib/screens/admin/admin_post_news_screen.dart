import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/news_article.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';

class AdminPostNewsScreen extends StatefulWidget {
  const AdminPostNewsScreen({super.key});

  @override
  State<AdminPostNewsScreen> createState() => _AdminPostNewsScreenState();
}

class _AdminPostNewsScreenState extends State<AdminPostNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _firestore = FirestoreService();
  NewsCategory _category = NewsCategory.local;
  bool _submitting = false;

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    setState(() => _submitting = true);
    try {
      final article = NewsArticle(
        id: '',
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        category: _category,
        authorName: user.name,
        authorId: user.uid,
        publishedAt: DateTime.now(),
      );
      await _firestore.publishArticle(article);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Article published.')));
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publish News Article')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<NewsCategory>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: NewsCategory.values
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Headline'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a headline' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _bodyController,
                  maxLines: 8,
                  decoration: const InputDecoration(labelText: 'Article body', alignLabelWithHint: true),
                  validator: (v) => (v == null || v.trim().length < 20) ? 'Article body is too short' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL (optional)'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitting ? null : _publish,
                  child: _submitting
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Publish'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
