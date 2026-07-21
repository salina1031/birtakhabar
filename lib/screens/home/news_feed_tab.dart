import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/news_provider.dart';
import '../../providers/saved_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/news_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../news/news_detail_screen.dart';

class NewsFeedTab extends StatelessWidget {
  const NewsFeedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final newsProvider = context.watch<NewsProvider>();
    final savedProvider = context.watch<SavedProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CategoryChip(
                    label: 'All',
                    selected: newsProvider.selectedCategory == null,
                    onTap: () => context.read<NewsProvider>().selectCategory(null),
                  ),
                  ...NewsCategory.values.map(
                    (c) => CategoryChip(
                      label: c.label,
                      selected: newsProvider.selectedCategory == c,
                      onTap: () => context.read<NewsProvider>().selectCategory(c),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: newsProvider.isLoading
                ? const LoadingIndicator()
                : newsProvider.articles.isEmpty
                    ? const EmptyState(
                        icon: Icons.newspaper_outlined,
                        title: 'No news yet in this category',
                        subtitle: 'Check back soon or try another category.',
                      )
                    : RefreshIndicator(
                        onRefresh: () async {},
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                          itemCount: newsProvider.articles.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final article = newsProvider.articles[i];
                            return NewsCard(
                              article: article,
                              isSaved: savedProvider.isSaved(article.id),
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
                      ),
          ),
        ],
      ),
    );
  }
}
