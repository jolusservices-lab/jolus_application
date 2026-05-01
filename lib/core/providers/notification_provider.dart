import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  final _supabase = Supabase.instance.client;

  // Stream para notificar a la UI sobre nuevas notificaciones entrantes
  final _newNotificationController = StreamController<NotificationModel>.broadcast();
  Stream<NotificationModel> get onNewNotification => _newNotificationController.stream;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  RealtimeChannel? _channel;

  Future<void> fetchNotifications(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Buscamos notificaciones específicas del usuario o generales (user_id is null)
      final data = await _supabase
          .from('notificaciones')
          .select()
          .or('user_id.eq.$userId,user_id.is.null')
          .order('created_at', ascending: false);

      _notifications = (data as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notificaciones')
          .update({'leido': true})
          .eq('id', notificationId);
      
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          title: _notifications[index].title,
          body: _notifications[index].body,
          createdAt: _notifications[index].createdAt,
          type: _notifications[index].type,
          isRead: true,
          data: _notifications[index].data,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  void setupRealtimeListener(String userId) {
    if (_channel != null) return;

    _channel = _supabase
        .channel('public:notificaciones')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notificaciones',
          callback: (payload) {
            final newJson = payload.newRecord;
            if (newJson['user_id'] == null || newJson['user_id'] == userId) {
              final newNotif = NotificationModel.fromJson(newJson);
              _notifications.insert(0, newNotif);
              _newNotificationController.add(newNotif); // Notificamos el nuevo evento
              notifyListeners();
            }
          },
        )
        .subscribe();
  }

  void clearNotifications() {
    _notifications = [];
    if (_channel != null) {
      _supabase.removeChannel(_channel!);
      _channel = null;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _newNotificationController.close();
    super.dispose();
  }
}
