import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fcm/DemoScreen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class LocalNotificationService{
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize(BuildContext context) {
    // initializationSettings  for Android
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    );

     _notificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? id) async {
        print("onSelectNotification");
        if (id!.isNotEmpty) {
          print("Router Value1234 $id");

          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: (context) => DemoScreen(
          //       // id: id,
          //     ),
          //   ),
          // );
          Navigator.push(context, MaterialPageRoute(builder: (context) => DemoScreen(id: id,)));

          
        }
      },
    );
  }

  static void createanddisplaynotification(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "pushnotificationapp",
          "pushnotificationappchannel",
          importance: Importance.max,
          priority: Priority.high,
        ),
      );

      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: message.data['_id'],
      );
    } on Exception catch (e) {
      print(e);
    }
  }

  // static void scheduleNotification(title, body) async {
  //   try {
  //     final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  //     const NotificationDetails notificationDetails = NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         "pushnotificationapp",
  //         "pushnotificationappchannel",
  //         importance: Importance.max,
  //         priority: Priority.high,
  //       ),
  //     );
  //     print('show');
  //     await _notificationsPlugin.zonedSchedule(
  //       id,
  //       "message.notification!.title",
  //       "message.notification!.body",
  //       tz.TZDateTime.now(tz.local).add(Duration(
  //         seconds: 1)),
  //       notificationDetails,
  //       uiLocalNotificationDateInterpretation:
  //         UILocalNotificationDateInterpretation.absoluteTime,
  //     androidAllowWhileIdle:
  //         true,
  //     );
  //   } on Exception catch (e) {
  //     print(e);
  //   }
  // }

  // static Future<void> scheduleDailyNotification() async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //           'your_channel_id', 'your_channel_name',
  //           importance: Importance.max,
  //           priority: Priority.high,
  //           showWhen: false);

  //   const NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);

  //   tz.initializeTimeZones();
  //   final String timeZoneName = tz.local.name;
  //   tz.setLocalLocation(tz.getLocation(timeZoneName));

  //   await _notificationsPlugin.zonedSchedule(
  //       0,
  //       'Judul Notifikasi',
  //       'Isi Notifikasi',
  //       _nextInstanceOfNineAM(),
  //       platformChannelSpecifics,
  //       androidAllowWhileIdle: true,
  //       uiLocalNotificationDateInterpretation:
  //           UILocalNotificationDateInterpretation.absoluteTime);
  // }

  static tz.TZDateTime _nextInstanceOfNineAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 9);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // static scheduleDailyNotification() async {
  //   try {
  //     const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //         AndroidNotificationDetails(
  //       'channel_id',
  //       'channel_name',
  //       // 'channel_description',
  //       importance: Importance.max,
  //       priority: Priority.high,
  //     );

  //     const NotificationDetails platformChannelSpecifics =
  //         NotificationDetails(android: androidPlatformChannelSpecifics);

  //     await _notificationsPlugin.showDailyAtTime(
  //       0,
  //       'Judul Notifikasi',
  //       'Pesan Notifikasi',
  //       Time(20, 42, 0),
  //       platformChannelSpecifics,
  //     );
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  static Future<void> scheduleWeekdayNotification(BuildContext context) async {
    try {
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
              'weekday_channel_id',
              'Weekday Channel',
              // 'Channel for weekday notifications',
              importance: Importance.max,
              priority: Priority.high,
              sound: RawResourceAndroidNotificationSound('notification_sound'),
              playSound: true,
              enableVibration: true);
      const IOSNotificationDetails iOSPlatformChannelSpecifics =
          IOSNotificationDetails();
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics);

      // Menghitung durasi hingga pukul 09:00 berikutnya
      tz.initializeTimeZones();
      final now = DateTime.now();
      final nextNotificationTime = DateTime(now.year, now.month, now.day, 9);
      tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9);
      if (scheduledDate.isBefore(now)) {
        // Jika waktu notifikasi sudah lewat hari ini, maka jadwalkan untuk besok
        scheduledDate.add(const Duration(days: 1));
      }

      // Mengatur jadwal notifikasi pada hari kerja (Senin-Jumat) pada pukul 09:00
      for (int i = 1; i <= 5; i++) {
        // 1 = Senin, 2 = Selasa, dst.
        if (scheduledDate.weekday == i) {
          await _notificationsPlugin.zonedSchedule(
              i,
              'Judul Notifikasi',
              'Isi notifikasi',
              scheduledDate,
              platformChannelSpecifics,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              androidAllowWhileIdle: true);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${e}'),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'ACTION',
          onPressed: () { },
        ),
      ));
    }
    
  }
}