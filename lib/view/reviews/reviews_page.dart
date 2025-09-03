import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../controller/provider/review_provider.dart';
import '../../utils/textStyles.dart';
import '../../utils/colors.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({Key? key}) : super(key: key);

  String _formatCreated(dynamic created) {
    if (created == null) return '';
    DateTime? dt;
    try {
      if (created is int) {
        dt = DateTime.fromMillisecondsSinceEpoch(created);
      } else if (created is String) {
        dt = DateTime.tryParse(created);
      } else if (created is DateTime) {
        dt = created;
      }
    } catch (_) {
      dt = null;
    }

    if (dt == null) return created.toString();

    final local = dt.toLocal();
    final now = DateTime.now();
    final twoDigits = (int n) => n.toString().padLeft(2, '0');
    final timePart = '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day) {
      return timePart; // same day -> show only time
    }
    return '${local.day}/${local.month}/${local.year} $timePart';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'آراء العملاء',
              style: AppTextStyles.heading20Bold.copyWith(
                color: white,
                fontWeight: FontWeight.bold,
              ),
            ),
            titleSpacing: 00.0,
            centerTitle: true,
            toolbarHeight: 80,
            toolbarOpacity: 0.8,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(25),
                bottomLeft: Radius.circular(25),
              ),
            ),
            elevation: 0.00,
            backgroundColor: lightOrange,
            foregroundColor: Colors.white,
          ),
          body: Consumer<ReviewsProvider>(
            builder: (context, provider, child) {
              final reviews = provider.reviews;
              if (reviews.isEmpty) {
                return Center(child: Text('لا توجد آراء بعد'));
              }
      
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: reviews.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final r = reviews[index];
                  final name = r['name'] ?? 'مستخدم';
                  final rating = (r['rating'] is num)
                      ? (r['rating'] as num).toDouble()
                      : double.tryParse('${r['rating']}') ?? 0.0;
                  final text = r['text'] ?? '';
                  final created = _formatCreated(r['createdAt']);
      
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: AppTextStyles.body16Bold,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 8),
                              RatingBarIndicator(
                                rating: rating,
                                itemBuilder: (context, _) =>
                                    const Icon(Icons.star, color: Colors.amber),
                                itemCount: 5,
                                itemSize: 18.0,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(text, textAlign: TextAlign.right),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              created,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
