import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fcm/DemoScreen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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

 
  static Future<void> scheduleDailyNotification() async {
    try {
     // Konfigurasi plugin notifikasi lokal
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _notificationsPlugin.initialize(initializationSettings);

      // Set timezone agar notifikasi sesuai dengan waktu lokal
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      print("---sini");

      // Logika pengecekan dan tampilan notifikasi
      Timer.periodic(const Duration(minutes: 1), (timer) async {
        final DateTime now = DateTime.now();
        final DateTime scheduledDate =
            tz.TZDateTime(tz.local, now.year, now.month, now.day, 9);
            print(scheduledDate);

        if (now.isAfter(scheduledDate)) {
          // Panggil fungsi fetchDataFromAPI untuk memeriksa API
          bool hasData = await fetchDataFromAPI();
          print("fetch");

          if (hasData) {
            // Panggil fungsi showNotification jika API mengembalikan data
            await showNotification(hasData);
          }
        }
      });
      
    } catch (e) {
      print(e);
    }
}

static Future<void> showNotification(data) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    // 'your_channel_description',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await _notificationsPlugin.show(
    0,
    'Judul Notifikasi',
    'Konten $data',
    platformChannelSpecifics,
  );
}

static Future<bool> fetchDataFromAPI() async {
  return true;
  // Panggil API dan ambil data
  // Lakukan pemrosesan data sesuai kebutuhan Anda
  // Misalnya, jika data ada, return true; jika tidak, return false
}

}