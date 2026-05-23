import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;  // Changed from 'body' to match Django
  final String? type;
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,  // Changed
    this.type,
    required this.isRead,
    this.data,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      message: json['message'] ?? json['body'] ?? '',  // Try 'message' first, fallback to 'body'
      type: json['type'],
      isRead: json['is_read'] ?? false,
      data: json['data'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
  
  // Helper method to get display text
  String get displayMessage => message;
}

class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.getNotifications();
      _notifications = data.map((item) => AppNotification.fromJson(item)).toList();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      _error = null;
      _isLoading = false;
      notifyListeners();
      print('✅ Loaded ${_notifications.length} notifications, $_unreadCount unread');
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print('❌ Error loading notifications: $e');
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      _unreadCount = await _apiService.getUnreadNotificationCount();
      notifyListeners();
      print('📊 Unread count: $_unreadCount');
    } catch (e) {
      print('❌ Error loading unread count: $e');
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      await _apiService.markNotificationRead(notificationId);
      
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] = AppNotification(
          id: _notifications[index].id,
          title: _notifications[index].title,
          message: _notifications[index].message,
          type: _notifications[index].type,
          isRead: true,
          data: _notifications[index].data,
          createdAt: _notifications[index].createdAt,
        );
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      await _apiService.markAllNotificationsRead();
      
      // Update local state
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = AppNotification(
            id: _notifications[i].id,
            title: _notifications[i].title,
            message: _notifications[i].message,
            type: _notifications[i].type,
            isRead: true,
            data: _notifications[i].data,
            createdAt: _notifications[i].createdAt,
          );
        }
      }
      _unreadCount = 0;
      notifyListeners();
      print('✅ All notifications marked as read');
      return true;
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
      return false;
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _apiService.deleteNotification(notificationId);
      
      // Remove from local list
      _notifications.removeWhere((n) => n.id == notificationId);
      
      // Recalculate unread count
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
      print('✅ Notification deleted');
      return true;
    } catch (e) {
      print('❌ Error deleting notification: $e');
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  void reset() {
    _notifications = [];
    _isLoading = false;
    _error = null;
    _unreadCount = 0;
    notifyListeners();
  }
}