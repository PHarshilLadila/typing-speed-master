import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserActivityProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  Map<DateTime, int> _activityData = {};
  bool _isLoading = false;

  Map<DateTime, int> get activityData => _activityData;
  bool get isLoading => _isLoading;
  Future<void> fetchActivityData(String userId, int year) async {
    try {
      _isLoading = true;
      notifyListeners();

      final startDate = DateTime(year, 1, 1);
      final endDate = DateTime(year, 12, 31);

      dev.log('Fetching activity data for user: $userId, year: $year');

      final response = await _supabase
          .from('activity_logs')
          .select()
          .eq('user_id', userId)
          .gte('activity_date', startDate.toIso8601String().split('T')[0])
          .lte('activity_date', endDate.toIso8601String().split('T')[0])
          .order('activity_date', ascending: true);

      final newActivityData = <DateTime, int>{};

      for (var log in response) {
        try {
          final date = DateTime.parse(log['activity_date']);
          final normalizedDate = DateTime(date.year, date.month, date.day);
          newActivityData[normalizedDate] = log['test_count'] as int;
        } catch (e) {
          dev.log('Error parsing activity log: $e');
        }
      }

      _activityData = newActivityData;

      dev.log('Loaded ${_activityData.length} activity days for $year');
      if (_activityData.isNotEmpty) {
        dev.log(
          '📅 Activity data sample: ${_activityData.entries.take(5).toList()}',
        );
      }
    } catch (e) {
      dev.log('Error fetching activity data: $e');
      if (e is PostgrestException) {
        dev.log('Postgrest error: ${e.message}');
        dev.log('Details: ${e.details}');
      }
      _activityData = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recordActivity(String userId) async {
    try {
      final today = DateTime.now();
      final dateOnly = DateTime(today.year, today.month, today.day);
      final dateString = dateOnly.toIso8601String().split('T')[0];

      dev.log('Recording activity for user: $userId on $dateString');

      final existing =
          await _supabase
              .from('activity_logs')
              .select()
              .eq('user_id', userId)
              .eq('activity_date', dateString)
              .maybeSingle();

      if (existing != null) {
        final newCount = (existing['test_count'] as int) + 1;

        dev.log('Updating existing activity: $newCount tests');

        await _supabase
            .from('activity_logs')
            .update({
              'test_count': newCount,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('activity_date', dateString);

        _activityData[dateOnly] = newCount;
        dev.log('Updated activity count to $newCount');
      } else {
        dev.log('Creating new activity record');

        final insertData = {
          'user_id': userId,
          'activity_date': dateString,
          'test_count': 1,
        };

        dev.log('Insert data: $insertData');

        final response =
            await _supabase.from('activity_logs').insert(insertData).select();

        dev.log('Insert response: $response');

        _activityData[dateOnly] = 1;
        dev.log('Created new activity record');
      }

      notifyListeners();
    } catch (e) {
      dev.log('Error recording activity: $e');
      if (e is PostgrestException) {
        dev.log('Postgrest error: ${e.message}');
        dev.log('Details: ${e.details}');
        dev.log('Hint: ${e.hint}');
        dev.log('Code: ${e.code}');
      }
    }
  }

  int getActivityLevel(int testCount) {
    if (testCount == 0) return 0;
    if (testCount <= 2) return 1;
    if (testCount <= 5) return 2;
    if (testCount <= 10) return 3;
    return 4;
  }

  void clearData() {
    _activityData.clear();
    notifyListeners();
  }

  Future<void> forceRefreshActivity(String userId, int year) async {
    try {
      _isLoading = true;
      notifyListeners();

      _activityData.clear();
      notifyListeners();
      await fetchActivityData(userId, year);

      dev.log('Activity data forcefully refreshed for $year');
    } catch (e) {
      dev.log('Error in forceRefreshActivity: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
