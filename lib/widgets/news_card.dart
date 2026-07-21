import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/news_article.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;
  final bool isSaved;
  final VoidCallback onSaveToggle;
  final VoidCallback onShare;

  const NewsCard({
    super.key,
    required this.article,
    required this.onTap,
    required this.isSaved,
    required this.onSaveToggle,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.categoryColor(article.category.name);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: article.imageUrl!,
                    width: 92,
                    height: 92,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 92,
                      height: 92,
                      color: Colors.grey.shade200,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 92,
                      height: 92,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                )
              else
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.newspaper, color: color),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            article.category.label,
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeago.format(article.publishedAt),
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            size: 20,
                            color: isSaved ? AppTheme.primary : Colors.grey.shade600,
                          ),
                          onPressed: onSaveToggle,
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(Icons.share_outlined, size: 20, color: Colors.grey.shade600),
                          onPressed: onShare,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
