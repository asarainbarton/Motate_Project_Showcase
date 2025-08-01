import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/journal_entry.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000';
  // static const String baseUrl = 'http://10.0.2.2:8000'; // For Android emulator
  // Use 'http://localhost:8000' for iOS simulator or web
  
  static Future<Map<String, dynamic>> addEntry(String text, String emoji) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/entry'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text, 'emoji': emoji}),
      );
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to add entry'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getEntries({int limit = 50, int offset = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/entries?limit=$limit&offset=$offset'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final entries = (data['entries'] as List)
            .map((entry) => JournalEntry.fromJson(entry))
            .toList();
        return {'success': true, 'entries': entries};
      } else {
        return {'success': false, 'error': 'Failed to load entries'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateEntry(int id, {String? text, String? emoji}) async {
    try {
      final body = <String, dynamic>{};
      if (text != null) body['text'] = text;
      if (emoji != null) body['emoji'] = emoji;
      
      final response = await http.put(
        Uri.parse('$baseUrl/entries/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to update entry'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteEntry(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/entries/$id'),
      );
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to delete entry'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getWeeklyStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stats/weekly'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['weekly_counts']};
      } else {
        return {'success': false, 'error': 'Failed to load weekly stats'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getCommonEmotions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stats/common_emotions'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final emotions = (data['common_emotions'] as List)
            .map((emotion) => CommonEmotion.fromJson(emotion))
            .toList();
        return {'success': true, 'emotions': emotions};
      } else {
        return {'success': false, 'error': 'Failed to load common emotions'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getSentimentDistribution() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stats/sentiment_distribution'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['sentiment_distribution']};
      } else {
        return {'success': false, 'error': 'Failed to load sentiment distribution'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> exportCSV() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/export/csv'));
      
      if (response.statusCode == 200) {
        try {
          // Try to get the documents directory
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/journal_entries.csv');
          await file.writeAsBytes(response.bodyBytes);
          return {'success': true, 'path': file.path};
        } catch (pathError) {
          // Fallback: Return the CSV data directly for manual handling
          return {
            'success': true, 
            'csvData': response.body,
            'message': 'CSV data ready - please copy the content manually'
          };
        }
      } else {
        return {'success': false, 'error': 'Failed to export CSV'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
}
