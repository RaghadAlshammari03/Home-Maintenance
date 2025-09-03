import 'package:flutter/material.dart';

// Utility functions for order status mapping.
// These functions strictly match the exact strings returned by
// ServiceOrderServices.orderStatus(int).

const String STATUS_PREPARATION = 'SERVICE_UNDER_PREPERATION';
const String STATUS_ACCEPTED = 'SERVICE_ACCEPTED_BY_TECHNICIAN';
const String STATUS_ON_THE_WAY = 'TECHNICIAN_ON_THE_WAY';
const String STATUS_DELIVERED = 'SERVICE_DELIVERED';

String normalizeToCanonical(String raw) {
  final s = raw.trim();
  if (s == STATUS_PREPARATION) return STATUS_PREPARATION;
  if (s == STATUS_ACCEPTED) return STATUS_ACCEPTED;
  if (s == STATUS_ON_THE_WAY) return STATUS_ON_THE_WAY;
  if (s == STATUS_DELIVERED) return STATUS_DELIVERED;
  // If it doesn't match exactly, return the original trimmed value to preserve it.
  return s;
}

String statusToArabic(String raw) {
  final c = normalizeToCanonical(raw);
  switch (c) {
    case STATUS_PREPARATION:
      return 'قيد التحضير';
    case STATUS_ACCEPTED:
      return 'تم القبول';
    case STATUS_ON_THE_WAY:
      return 'في الطريق';
    case STATUS_DELIVERED:
      return 'مكتمل';
    default:
      // Preserve user-provided label if available, otherwise unknown
      return c.isEmpty ? 'غير معروف' : c;
  }
}

Color statusToColor(String raw) {
  final c = normalizeToCanonical(raw);
  switch (c) {
    case STATUS_PREPARATION:
      return Colors.orange.shade600;
    case STATUS_ACCEPTED:
      return Colors.blue.shade600;
    case STATUS_ON_THE_WAY:
      return Colors.indigo.shade600;
    case STATUS_DELIVERED:
      return Colors.green.shade800;
    default:
      return Colors.blueGrey.shade700;
  }
}

bool isTrackable(String raw) {
  final c = normalizeToCanonical(raw);
  // Only when technician is on the way do we show tracking
  return c == STATUS_ON_THE_WAY;
}
