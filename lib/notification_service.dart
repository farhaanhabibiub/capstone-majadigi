import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _reminderKey = 'etibi_reminder_ts';
  static const _etibiChannelId = 'etibi_reminder_channel';
  static const _statusChannelId = 'klinik_hoaks_status_channel';

  static Future<void> initialize() async {
    tz_data.initializeTimeZones();
    try {
      final localTz = DateTime.now().timeZoneName;
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);
  }

  static Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ── E-TIBI Reminder ────────────────────────────────────────────────────────

  static Future<void> scheduleEtibiReminder({required int daysLater}) async {
    await requestPermissions();
    final scheduledDate = tz.TZDateTime.now(tz.local).add(
      Duration(days: daysLater),
    );
    await _plugin.zonedSchedule(
      1001,
      'Pengingat Skrining TBC 🩺',
      'Waktunya melakukan skrining E-TIBI kembali. Jaga kesehatanmu!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _etibiChannelId,
          'E-TIBI Reminder',
          channelDescription: 'Pengingat skrining TBC berkala',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_reminderKey, scheduledDate.millisecondsSinceEpoch);
  }

  static Future<void> cancelEtibiReminder() async {
    await _plugin.cancel(1001);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_reminderKey);
  }

  static Future<bool> isReminderScheduled() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_reminderKey);
    if (ts == null) return false;
    return DateTime.fromMillisecondsSinceEpoch(ts).isAfter(DateTime.now());
  }

  static Future<DateTime?> getReminderDate() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_reminderKey);
    if (ts == null) return null;
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    return dt.isAfter(DateTime.now()) ? dt : null;
  }

  // ── Klinik Hoaks Status Update ─────────────────────────────────────────────

  static Future<void> showStatusUpdateNotification({
    required String tiketId,
    required String newStatus,
  }) async {
    await requestPermissions();
    await _plugin.show(
      tiketId.hashCode,
      'Status Tiket Diperbarui 📋',
      'Tiket $tiketId sekarang berstatus "$newStatus"',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _statusChannelId,
          'Status Klinik Hoaks',
          channelDescription: 'Notifikasi perubahan status tiket Klinik Hoaks',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}
