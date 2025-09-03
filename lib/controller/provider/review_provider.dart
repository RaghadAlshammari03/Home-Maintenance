import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ReviewsProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _reviews = [];
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child(
    'reviews',
  );
  StreamSubscription<DatabaseEvent>? _sub;

  ReviewsProvider() {
    _startListener();
  }

  List<Map<String, dynamic>> get reviews => List.unmodifiable(_reviews);

  void _startListener() {
    _sub = _dbRef.onValue.listen(
      (event) {
        final value = event.snapshot.value;
        _reviews.clear();
        if (value == null) {
          notifyListeners();
          return;
        }

        try {
          final map = Map<String, dynamic>.from(value as Map);
          map.forEach((key, raw) {
            try {
              final entry = Map<String, dynamic>.from(raw as Map);
              // normalize createdAt which might be number or string
              dynamic created = entry['createdAt'];
              if (created is int) {
                entry['createdAt'] = DateTime.fromMillisecondsSinceEpoch(
                  created,
                ).toIso8601String();
              } else if (created is String) {
                // keep as-is
              }
              entry['id'] = key;
              _reviews.add(entry);
            } catch (_) {}
          });

          // sort newest first by createdAt if available
          _reviews.sort((a, b) {
            final aTime =
                DateTime.tryParse(
                  a['createdAt'] ?? '',
                )?.millisecondsSinceEpoch ??
                0;
            final bTime =
                DateTime.tryParse(
                  b['createdAt'] ?? '',
                )?.millisecondsSinceEpoch ??
                0;
            return bTime.compareTo(aTime);
          });

          notifyListeners();
        } catch (e) {
          // parsing failed - just notify with empty list
          notifyListeners();
        }
      },
      onError: (err) {
        // ignore for now
      },
    );
  }

  /// Persist a review to Firebase; listener will pick it up and add to local list.
  Future<void> addReviewPersist({
    required String name,
    required double rating,
    required String text,
    required String orderID,
  }) async {
    final payload = {
      'name': name,
      'rating': rating,
      'text': text,
      'orderID': orderID,
      // use server timestamp for consistent ordering
      'createdAt': ServerValue.timestamp,
    };
    try {
      await _dbRef.push().set(payload);
    } catch (e) {
      rethrow;
    }
  }

  void addReview({
    required String name,
    required double rating,
    required String text,
    required String orderID,
  }) {
    final review = {
      'name': name,
      'rating': rating,
      'text': text,
      'orderID': orderID,
      'createdAt': DateTime.now().toIso8601String(),
    };
    _reviews.insert(0, review);
    notifyListeners();
  }

  void clear() {
    _reviews.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
