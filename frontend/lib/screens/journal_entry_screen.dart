import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'stats_screen.dart';
import 'entries_history_screen.dart';

const Map<String, String> emojiToText = {
  '🙂': 'Happy',
  '😢': 'Sad',
  '😠': 'Angry',
  '😍': 'Love',
  '😴': 'Sleepy',
  '🤔': 'Thinking',
  '😱': 'Shocked',
};

class JournalEntryScreen extends StatefulWidget {
  @override
  _JournalEntryScreenState createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedEmoji = '🙂';
  bool _loading = false;
  final List<String> _availableEmojis = ['🙂', '😢', '😠', '😍', '😴', '🤔', '😱'];

  void _submitEntry() async {
    if (_controller.text.trim().isEmpty) {
      _showSnackBar('Please enter some text', isError: true);
      return;
    }

    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    final result = await ApiService.addEntry(_controller.text.trim(), _selectedEmoji);

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }

    if (result['success']) {
      if (mounted) {
        setState(() {
          _controller.clear();
        });
      }
      final data = result['data'];
      _showSnackBar(
        'Entry added! AI detected: ${data['sentiment']} (${(data['score'] * 100).toStringAsFixed(1)}% confidence)',
        isError: false,
      );
    } else {
      _showSnackBar(result['error'], isError: true);
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

  void _goToStats() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StatsScreen()),
    );
  }

  void _goToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EntriesHistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Emotion Journal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: _goToHistory,
            tooltip: 'View History',
          ),
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: _goToStats,
            tooltip: 'View Stats',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.edit_note,
                      size: 48,
                      color: Colors.blue[600],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'How are you feeling today?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Share your thoughts and let AI analyze your mood',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Text Input Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Journal Entry',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _controller,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Write about your day, feelings, thoughts...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Emoji Selection Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Your Mood',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _availableEmojis.map((emoji) {
                        final isSelected = _selectedEmoji == emoji;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedEmoji = emoji;
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue[100] : Colors.grey[100],
                              border: Border.all(
                                color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
                                width: isSelected ? 3 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  emoji,
                                  style: TextStyle(fontSize: 32),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  emojiToText[emoji] ?? emoji,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? Colors.blue[800] : Colors.grey[600],
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _loading ? null : _submitEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: _loading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Analyzing...', style: TextStyle(fontSize: 16)),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send),
                        SizedBox(width: 8),
                        Text('Submit Entry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
