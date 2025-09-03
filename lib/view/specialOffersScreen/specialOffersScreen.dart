import 'package:baligny/utils/textStyles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class SpecialOffersScreen extends StatefulWidget {
  const SpecialOffersScreen({super.key});

  @override
  State<SpecialOffersScreen> createState() => _SpecialOffersScreenState();
}

class _SpecialOffersScreenState extends State<SpecialOffersScreen> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  bool showOffers = true; // default: offers
  final _couponController = TextEditingController();
  bool _isRedeeming = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _redeemCoupon(String code) async {
    if (code.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('أدخل كود الكوبون')));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب تسجيل الدخول لاسترداد الكوبون')),
      );
      return;
    }

    setState(() => _isRedeeming = true);

    try {
      // 1) Lookup couponId by code
      final codeSnap = await _db.child('CouponCodes').child(code).get();
      if (!codeSnap.exists || codeSnap.value == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('كود الكوبون غير موجود')));
        return;
      }
      final couponId = codeSnap.value.toString();

      // 2) Read coupon details
      final couponSnap = await _db.child('Coupons').child(couponId).get();
      if (!couponSnap.exists || couponSnap.value == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('الكوبون غير صالح')));
        return;
      }

      final couponMap = Map<String, dynamic>.from(couponSnap.value as Map);

      final isActive = couponMap['isActive'] == true;
      if (!isActive) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('الكوبون غير مفعل')));
        return;
      }

      final validUntilStr = couponMap['validUntil'] as String?;
      if (validUntilStr != null && validUntilStr.isNotEmpty) {
        try {
          final validUntil = DateTime.parse(validUntilStr);
          if (DateTime.now().isAfter(validUntil)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('انتهت صلاحية الكوبون')),
            );
            return;
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
        // mutableData is provided by the API and holds the current node value
        if (mutableData == null) return Transaction.abort();

        int current = 0;
        final val = mutableData.value;
        if (val == null) {
          current = 0;
        } else if (val is int) {
          current = val;
        } else if (val is Map) {
          // previous shape might store {"count": N, ...}
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
          // if previous value was timestamp or other scalar, treat as 1
          current = 1;
        }

        if (perUserLimit != null && current >= perUserLimit) {
          return Transaction.abort();
        }

        // set to a map so we can store count and later merge a lastRedeemed timestamp
        mutableData.value = {'count': current + 1};
        return Transaction.success(mutableData);
      });

      if (!userTxResult.committed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تجاوزت الحد المسموح لكل مستخدم للكوبون'),
          ),
        );
        return;
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
              // remove the node
              mutableData.value = null;
            } else {
              mutableData.value = {'count': newVal};
            }
            return Transaction.success(mutableData);
          });
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('انتهت صلاحية الكمية المتاحة من الكوبون'),
          ),
        );
        return;
      }

      // 5) Record last redeemed timestamp (merge with existing count map)
      try {
        await userRef.update({'lastRedeemed': ServerValue.timestamp});
      } catch (_) {}

      final percent = couponMap['percent']?.toString() ?? '0';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم استرداد الكوبون بنجاح - خصم $percent%')),
      );
      _couponController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء محاولة استرداد الكوبون')),
      );
    } finally {
      setState(() => _isRedeeming = false);
    }
  }

  Widget _buildToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => setState(() => showOffers = true),
          style: ElevatedButton.styleFrom(
            backgroundColor: showOffers ? Colors.blue : Colors.grey[300],
            foregroundColor: showOffers ? Colors.white : Colors.black,
          ),
          child: const Text('العروض'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => setState(() => showOffers = false),
          style: ElevatedButton.styleFrom(
            backgroundColor: !showOffers ? Colors.blue : Colors.grey[300],
            foregroundColor: !showOffers ? Colors.white : Colors.black,
          ),
          child: const Text('الكوبونات'),
        ),
      ],
    );
  }

  Widget _buildOffersView() {
    return StreamBuilder<DatabaseEvent>(
      stream: _db.child('Offers').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final ev = snapshot.data;
        if (ev == null || ev.snapshot.value == null) {
          return Center(
            child: Text('لا توجد عروض حالياً', style: AppTextStyles.body14),
          );
        }
        final raw = ev.snapshot.value as Map<dynamic, dynamic>;
        final offers = raw.values.map((v) {
          if (v is Map) return Map<String, dynamic>.from(v);
          return <String, dynamic>{};
        }).toList();

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: offers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final o = offers[index];
            final title = o['title']?.toString() ?? '';
            final desc = o['description']?.toString() ?? '';
            final valid = o['validUntil']?.toString();
            String validText = '';
            if (valid != null && valid.isNotEmpty) {
              try {
                validText = DateTime.parse(
                  valid,
                ).toLocal().toString().split(' ')[0];
              } catch (_) {}
            }
            final discount = o['discountPercent']?.toString();

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: AppTextStyles.body16Bold),
                          const SizedBox(height: 6),
                          Text(
                            desc,
                            style: AppTextStyles.body14,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          if (validText.isNotEmpty)
                            Text(
                              'صالح حتى $validText',
                              style: AppTextStyles.small12,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (discount != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${discount}%',
                          style: AppTextStyles.body14Bold,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCouponsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    decoration: const InputDecoration(labelText: 'كود الكوبون'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isRedeeming
                      ? null
                      : () => _redeemCoupon(_couponController.text.trim()),
                  child: _isRedeeming
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('استرداد'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<DatabaseEvent>(
          stream: _db.child('Coupons').onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final ev = snapshot.data;
            if (ev == null || ev.snapshot.value == null) {
              return Center(
                child: Text(
                  'لا توجد كوبونات متاحة',
                  style: AppTextStyles.body14,
                ),
              );
            }
            final raw = ev.snapshot.value as Map<dynamic, dynamic>;
            final coupons = raw.entries.map((e) {
              final v = e.value;
              if (v is Map)
                return Map<String, dynamic>.from(v)..['id'] = e.key.toString();
              return <String, dynamic>{'id': e.key.toString()};
            }).toList();

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: coupons.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final c = coupons[index];
                final percent = c['percent']?.toString() ?? '';
                final code = c['code']?.toString() ?? c['id']?.toString() ?? '';
                final valid = c['validUntil']?.toString();
                String validText = '';
                if (valid != null && valid.isNotEmpty) {
                  try {
                    validText = DateTime.parse(
                      valid,
                    ).toLocal().toString().split(' ')[0];
                  } catch (_) {}
                }
                final isActive = c['isActive'] == true;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(code, style: AppTextStyles.body16Bold),
                              const SizedBox(height: 6),
                              if (percent.isNotEmpty)
                                Text(
                                  'خصم $percent%',
                                  style: AppTextStyles.body14Bold,
                                ),
                              const SizedBox(height: 6),
                              if (validText.isNotEmpty)
                                Text(
                                  'صالح حتى $validText',
                                  style: AppTextStyles.small12,
                                ),
                              const SizedBox(height: 6),
                              Text(
                                isActive ? 'مفعل' : 'غير مفعل',
                                style: AppTextStyles.small12,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: isActive && !_isRedeeming
                              ? () => _redeemCoupon(code)
                              : null,
                          child: const Text('استرداد'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('العروض والكوبونات'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            _buildToggleButtons(),
            const SizedBox(height: 12),
            if (showOffers) _buildOffersView() else _buildCouponsView(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
