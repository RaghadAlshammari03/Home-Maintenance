import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SpecialOffersService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  /// Attempts to redeem a coupon code for the current authenticated user.
  /// Returns a map with keys: success (bool), message (String), percent (String?).
  Future<Map<String, dynamic>> redeemCoupon(String code) async {
    if (code.trim().isEmpty) {
      return {'success': false, 'message': 'أدخل كود الكوبون'};
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'success': false, 'message': 'يجب تسجيل الدخول لاسترداد الكوبون'};
    }

    try {
      // 1) Lookup couponId by code
      final codeSnap = await _db.child('CouponCodes').child(code).get();
      if (!codeSnap.exists || codeSnap.value == null) {
        return {'success': false, 'message': 'كود الكوبون غير موجود'};
      }
      final couponId = codeSnap.value.toString();

      // 2) Read coupon details
      final couponSnap = await _db.child('Coupons').child(couponId).get();
      if (!couponSnap.exists || couponSnap.value == null) {
        return {'success': false, 'message': 'الكوبون غير صالح'};
      }

      final couponMap = Map<String, dynamic>.from(couponSnap.value as Map);

      final isActive = couponMap['isActive'] == true;
      if (!isActive) {
        return {'success': false, 'message': 'الكوبون غير مفعل'};
      }

      final validUntilStr = couponMap['validUntil'] as String?;
      if (validUntilStr != null && validUntilStr.isNotEmpty) {
        try {
          final validUntil = DateTime.parse(validUntilStr);
          if (DateTime.now().isAfter(validUntil)) {
            return {'success': false, 'message': 'انتهت صلاحية الكوبون'};
          }
        } catch (_) {
          // ignore parse errors and proceed
        }
      }

      final perUserLimit = couponMap['perUserLimit'] is int
          ? couponMap['perUserLimit'] as int
          : (couponMap['perUserLimit'] is String
                ? int.tryParse(couponMap['perUserLimit'])
                : null);
      final usageLimit = couponMap['usageLimit'] is int
          ? couponMap['usageLimit'] as int
          : (couponMap['usageLimit'] is String
                ? int.tryParse(couponMap['usageLimit'])
                : null);

      // 3) Per-user counter transaction (supports perUserLimit > 1)
      final userRef = _db
          .child('CouponRedemptions')
          .child(couponId)
          .child(user.uid);
      final userTxResult = await userRef.runTransaction((dynamic mutableData) {
        if (mutableData == null) return Transaction.abort();

        int current = 0;
        final val = mutableData.value;
        if (val == null) {
          current = 0;
        } else if (val is int) {
          current = val;
        } else if (val is Map) {
          try {
            final v = val['count'];
            if (v is int)
              current = v;
            else
              current = int.tryParse(v.toString()) ?? 1;
          } catch (_) {
            current = 1;
          }
        } else {
          current = 1;
        }

        if (perUserLimit != null && current >= perUserLimit) {
          return Transaction.abort();
        }

        mutableData.value = {'count': current + 1};
        return Transaction.success(mutableData);
      });

      if (!userTxResult.committed) {
        return {
          'success': false,
          'message': 'تجاوزت الحد المسموح لكل مستخدم للكوبون',
        };
      }

      // 4) Transaction on global usage counter. If this fails, roll back the user counter.
      final usageRef = _db.child('CouponUsageCounts').child(couponId);
      final globalTxResult = await usageRef.runTransaction((
        dynamic mutableData,
      ) {
        if (mutableData == null) return Transaction.abort();

        int current = 0;
        final val = mutableData.value;
        if (val != null) {
          if (val is int) {
            current = val;
          } else {
            try {
              current = int.parse(val.toString());
            } catch (_) {
              current = 0;
            }
          }
        }

        if (usageLimit != null && current >= usageLimit) {
          return Transaction.abort();
        }

        mutableData.value = current + 1;
        return Transaction.success(mutableData);
      });

      if (!globalTxResult.committed) {
        // rollback user increment
        try {
          await userRef.runTransaction((dynamic mutableData) {
            if (mutableData == null) return Transaction.success(mutableData);

            int cur = 0;
            final val = mutableData.value;
            if (val == null)
              cur = 0;
            else if (val is int)
              cur = val;
            else if (val is Map) {
              try {
                final v = val['count'];
                if (v is int)
                  cur = v;
                else
                  cur = int.tryParse(v.toString()) ?? 1;
              } catch (_) {
                cur = 1;
              }
            } else {
              cur = 1;
            }

            final newVal = cur - 1;
            if (newVal <= 0) {
              mutableData.value = null;
            } else {
              mutableData.value = {'count': newVal};
            }
            return Transaction.success(mutableData);
          });
        } catch (_) {}

        return {
          'success': false,
          'message': 'انتهت صلاحية الكمية المتاحة من الكوبون',
        };
      }

      // 5) Record last redeemed timestamp (merge with existing count map)
      try {
        await userRef.update({'lastRedeemed': ServerValue.timestamp});
      } catch (_) {}

      final percent = couponMap['percent']?.toString() ?? '0';
      return {
        'success': true,
        'message': 'تم استرداد الكوبون بنجاح - خصم $percent%',
        'percent': percent,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء محاولة استرداد الكوبون',
      };
    }
  }
}
