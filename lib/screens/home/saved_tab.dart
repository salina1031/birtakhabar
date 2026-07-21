import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/saved_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/news_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../news/news_detail_screen.dart';

class SavedTab extends StatelessWidget {
  const SavedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final savedProvider = context.watch<SavedProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Articles')),
      body: savedProvider.isLoading
          ? const LoadingIndicator()
          : savedProvider.savedArticles.isEmpty
              ? const EmptyState(
                  icon: Icons.bookmark_border,
                  title: 'Nothing saved yet',
                  subtitle: 'Tap the bookmark icon on any article to read it later.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: savedProvider.savedArticles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final article = savedProvider.savedArticles[i];
                    return NewsCard(
                      article: article,
                      isSaved: true,
                      onSaveToggle: () => savedProvider.toggle(article),
                      onShare: () => Share.share(
                        '${article.title}\n\nvia ${AppStrings.appName}',
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => NewsDetailScreen(articleId: article.id),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
