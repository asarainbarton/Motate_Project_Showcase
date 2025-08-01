import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
};

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with TickerProviderStateMixin {
  Map<String, int> weeklyCounts = {};
  List<CommonEmotion> commonEmotions = [];
  Map<String, int> sentimentDistribution = {};
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchStats() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    // Fetch all stats concurrently
    final results = await Future.wait([
      ApiService.getWeeklyStats(),
      ApiService.getCommonEmotions(),
      ApiService.getSentimentDistribution(),
    ]);

    if (mounted) {
      setState(() {
        _loading = false;
        
        if (results[0]['success']) {
          weeklyCounts = Map<String, int>.from(results[0]['data']);
        }
        
        if (results[1]['success']) {
          commonEmotions = results[1]['emotions'];
        }
        
        if (results[2]['success']) {
          sentimentDistribution = Map<String, int>.from(results[2]['data']);
        }
      });
    }
  }

  void _exportCSV() async {
    final result = await ApiService.exportCSV();
    
    if (result['success']) {
      if (result.containsKey('path')) {
        // File was successfully saved
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV exported to ${result['path']}'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (result.containsKey('csvData')) {
        // Fallback: Show CSV data in a dialog for manual copying
        _showCSVDataDialog(result['csvData']);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCSVDataDialog(String csvData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('CSV Export Data'),
          content: Container(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                Text(
                  'Copy the CSV data below:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: SelectableText(
                      csvData,
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeeklyMoodChart() {
    if (weeklyCounts.isEmpty) {
      return _buildEmptyState('No weekly data available');
    }

    final data = weeklyCounts.entries.toList();
    double maxValue = data.map((e) => e.value.toDouble()).reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Mood Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: data.asMap().entries.map((entry) {
                    int index = entry.key;
                    MapEntry<String, int> item = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: item.value.toDouble(),
                          color: Colors.blue,
                          width: 20,
                          borderRadius: BorderRadius.zero,
                          rodStackItems: [
                            BarChartRodStackItem(
                              0,
                              item.value.toDouble(),
                              Colors.blue,
                              BorderSide(color: Colors.white, width: 1),
                            ),
                          ],
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            String emoji = data[index].key;
                            return Text(
                              emoji,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: maxValue ~/ 5 + 1,
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonEmotionsChart() {
    if (commonEmotions.isEmpty) {
      return _buildEmptyState('No emotion data available');
    }

    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Most Common Emotions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 24),
            // Horizontal bar chart (list view of emotions)
            ...commonEmotions.map((emotion) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(emotion.emoji, style: TextStyle(fontSize: 28)),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: emotion.count / (commonEmotions.isNotEmpty ? commonEmotions.first.count : 1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green[400],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    '${emotion.count}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentChart() {
    if (sentimentDistribution.isEmpty) {
      return _buildEmptyState('No sentiment data available');
    }

    final data = sentimentDistribution.entries.toList();
    int total = data.map((e) => e.value).reduce((a, b) => a + b);
    
    // Colors for different sentiments
    List<Color> colors = [
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.blue,
      Colors.purple,
    ];

    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Sentiment Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: data.asMap().entries.map((entry) {
                    int index = entry.key;
                    MapEntry<String, int> item = entry.value;
                    double percentage = (item.value / total) * 100;
                    return PieChartSectionData(
                      color: index < colors.length ? colors[index] : Colors.grey,
                      value: item.value.toDouble(),
                      title: '${percentage.toStringAsFixed(1)}%',
                      radius: 50,
                      titleStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            SizedBox(height: 16),
            // Legend
            ...data.asMap().entries.map((entry) {
              int index = entry.key;
              MapEntry<String, int> item = entry.value;
              double percentage = (item.value / total) * 100;
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: index < colors.length ? colors[index] : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      '${item.key}: ${item.value} entries (${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Mood Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchStats,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _exportCSV,
            tooltip: 'Export CSV',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Weekly'),
            Tab(text: 'Common'),
            Tab(text: 'Sentiment'),
          ],
        ),
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading analytics...'),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(child: _buildWeeklyMoodChart()),
                SingleChildScrollView(child: _buildCommonEmotionsChart()),
                SingleChildScrollView(child: _buildSentimentChart()),
              ],
            ),
    );
  }
}
