import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database_service.dart';

class ResultsScreen extends StatelessWidget {
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Election Results')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // This line asks the database for the real names and counts
        future: _dbService.getCandidateVotes(), 
        builder: (context, snapshot) {
          // While the database is thinking...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // If something goes wrong or no one has voted...
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No data found. Ensure you have candidates in your database."));
          }

          // Data Analyst Logic: Transform database rows into Bar Chart objects
          List<BarChartGroupData> barGroups = [];
          for (int i = 0; i < snapshot.data!.length; i++) {
            double votes = snapshot.data![i]['vote_count'].toDouble();
            barGroups.add(
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(toY: votes, color: Colors.blue, width: 22, borderRadius: BorderRadius.circular(4))
              ]),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text("Candidate Standings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 25),
                AspectRatio(
                  aspectRatio: 1.7,
                  child: BarChart(
                    BarChartData(
                      barGroups: barGroups,
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        // THIS SHOWS THE NAMES AT THE BOTTOM
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              int index = value.toInt();
                              if (index >= 0 && index < snapshot.data!.length) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                    snapshot.data![index]['name'],
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}