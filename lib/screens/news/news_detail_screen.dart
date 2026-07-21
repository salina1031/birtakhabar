import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../models/news_article.dart';
import '../../services/firestore_service.dart';
import '../../providers/saved_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_indicator.dart';

class NewsDetailScreen extends StatefulWidget {
  final String articleId;
  const NewsDetailScreen({super.key, required this.articleId});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final _firestore = FirestoreService();
  late Future<NewsArticle> _future;

  @override
  void initState() {
    super.initState();
    _future = _firestore.getArticle(widget.articleId);
    _firestore.incrementViewCount(widget.articleId);
  }

  @override
  Widget build(BuildContext context) {
    final savedProvider = context.watch<SavedProvider>();

    return Scaffold(
      body: FutureBuilder<NewsArticle>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingIndicator();
          }
          final article = snapshot.data!;
          final color = AppTheme.categoryColor(article.category.name);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: article.imageUrl != null ? 220 : 0,
                backgroundColor: AppTheme.primary,
                flexibleSpace: article.imageUrl != null
                    ? FlexibleSpaceBar(
                        background: CachedNetworkImage(
                          imageUrl: article.imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(color: Colors.grey.shade300),
                        ),
                      )
                    : null,
                actions: [
                  IconButton(
                    icon: Icon(
                      savedProvider.isSaved(article.id) ? Icons.bookmark : Icons.bookmark_border,
                    ),
                    onPressed: () => savedProvider.toggle(article),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () => Share.share('${article.title}\n\nvia ${AppStrings.appName}'),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              article.category.label,
                              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (article.isVerified)
                            Row(
                              children: [
                                Icon(Icons.verified, size: 14, color: Colors.green.shade600),
                                const SizedBox(width: 3),
                                Text('Verified', style: TextStyle(fontSize: 12, color: Colors.green.shade600)),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        article.title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${article.authorName} · ${DateFormat.yMMMd().add_jm().format(article.publishedAt)}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      const Divider(height: 32),
                      Text(
                        article.body,
                        style: const TextStyle(fontSize: 16, height: 1.6),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
