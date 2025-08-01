import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';
import '../services/api_service.dart';

const Map<String, String> emojiToText = {
  '🙂': 'Happy',
  '😢': 'Sad',
  '😠': 'Angry',
  '😍': 'Love',
  '😴': 'Sleepy',
  '🤔': 'Thinking',
  '😱': 'Shocked',
  '🤗': 'Hugging',
};

class EntriesHistoryScreen extends StatefulWidget {
  @override
  _EntriesHistoryScreenState createState() => _EntriesHistoryScreenState();
}

class _EntriesHistoryScreenState extends State<EntriesHistoryScreen> {
  List<JournalEntry> _entries = [];
  bool _loading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    final result = await ApiService.getEntries();

    if (mounted) {
      setState(() {
        _loading = false;
        if (result['success']) {
          _entries = result['entries'];
        } else {
          _showSnackBar(result['error'], isError: true);
        }
      });
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showEditDialog(JournalEntry entry) {
    final TextEditingController textController = TextEditingController(text: entry.text);
    String selectedEmoji = entry.emoji;
    final List<String> availableEmojis = ['🙂', '😢', '😠', '😍', '😴', '🤔', '😱', '🤗'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Entry Text',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                Text('Select Emoji:', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: availableEmojis.map((emoji) {
                    final isSelected = selectedEmoji == emoji;
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          selectedEmoji = emoji;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          emoji,
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateEntry(entry.id!, textController.text, selectedEmoji);
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateEntry(int id, String text, String emoji) async {
    final result = await ApiService.updateEntry(id, text: text, emoji: emoji);
    
    if (result['success']) {
      _showSnackBar('Entry updated successfully!', isError: false);
      _loadEntries(); // Refresh the list
    } else {
      _showSnackBar(result['error'], isError: true);
    }
  }

  Future<void> _deleteEntry(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Entry'),
        content: Text('Are you sure you want to delete this entry? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await ApiService.deleteEntry(id);
      
      if (result['success']) {
        _showSnackBar('Entry deleted successfully!', isError: false);
        _loadEntries(); // Refresh the list
      } else {
        _showSnackBar(result['error'], isError: true);
      }
    }
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Journal History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadEntries,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading entries...'),
                ],
              ),
            )
          : _entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No entries yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Start writing your first journal entry!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with emoji, date, and actions
                            Row(
                              children: [
                                Text(
                                  entry.emoji,
                                  style: TextStyle(fontSize: 24),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('MMM dd, yyyy').format(entry.createdAt),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('hh:mm a').format(entry.createdAt),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showEditDialog(entry);
                                    } else if (value == 'delete') {
                                      _deleteEntry(entry.id!);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 18),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, size: 18, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Delete', style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            
                            // Entry text
                            Text(
                              entry.text,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 12),
                            
                            // Sentiment analysis result
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getSentimentColor(entry.sentiment).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getSentimentColor(entry.sentiment).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.psychology,
                                    size: 16,
                                    color: _getSentimentColor(entry.sentiment),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    '${entry.sentiment} (${(entry.sentimentScore * 100).toStringAsFixed(1)}%)',
                                    style: TextStyle(
                                      color: _getSentimentColor(entry.sentiment),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
