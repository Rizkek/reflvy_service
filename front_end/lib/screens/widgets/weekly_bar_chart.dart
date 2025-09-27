import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> daily; // each: {date, totalLow, totalMedium, totalHigh}
  final double height;

  const WeeklyBarChart({
    super.key,
    required this.daily,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure we have at most 7 bars
    final data = daily.take(7).toList();

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          maxY: _suggestMaxY(data),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _suggestInterval(data),
            getDrawingHorizontalLine: (value) => FlLine(
              color: const Color(0xFFE5E7EB),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: _suggestInterval(data),
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                  final label = _dayLabel(data[idx]['date'] as String?);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(data.length, (i) {
            final low = (data[i]['totalLow'] ?? 0) as int;
            final med = (data[i]['totalMedium'] ?? 0) as int;
            final high = (data[i]['totalHigh'] ?? 0) as int;
            double sum = (low + med + high).toDouble();
            if (sum == 0) sum = 1; // avoid divide by zero

            // Create 3 rods per group slightly offset
            return BarChartGroupData(
              x: i,
              barsSpace: 3,
              barRods: [
                BarChartRodData(toY: low.toDouble(), color: const Color(0xFF10B981), width: 6, borderRadius: BorderRadius.circular(2)),
                BarChartRodData(toY: med.toDouble(), color: const Color(0xFFF59E0B), width: 6, borderRadius: BorderRadius.circular(2)),
                BarChartRodData(toY: high.toDouble(), color: const Color(0xFFEF4444), width: 6, borderRadius: BorderRadius.circular(2)),
              ],
            );
          }),
        ),
      ),
    );
  }

  double _suggestInterval(List<Map<String, dynamic>> data) {
    int maxVal = 0;
    for (final d in data) {
      final l = (d['totalLow'] ?? 0) as int;
      final m = (d['totalMedium'] ?? 0) as int;
      final h = (d['totalHigh'] ?? 0) as int;
      maxVal = [maxVal, l, m, h].reduce((a, b) => a > b ? a : b);
    }
    if (maxVal <= 4) return 1;
    if (maxVal <= 10) return 2;
    if (maxVal <= 25) return 5;
    if (maxVal <= 50) return 10;
    if (maxVal <= 100) return 20;
    if (maxVal <= 200) return 40;
    return 50;
  }

  double _suggestMaxY(List<Map<String, dynamic>> data) {
    int maxVal = 0;
    for (final d in data) {
      final l = (d['totalLow'] ?? 0) as int;
      final m = (d['totalMedium'] ?? 0) as int;
      final h = (d['totalHigh'] ?? 0) as int;
      maxVal = [maxVal, l, m, h].reduce((a, b) => a > b ? a : b);
    }
    final interval = _suggestInterval(data);
    final steps = ((maxVal + interval) / interval).ceil();
    return steps * interval;
  }

  String _dayLabel(String? fullDate) {
    // Expecting format like "September 27, 2025"; we only need weekday (id) + dd/MM
    try {
      final dt = DateTime.parse(_toIsoDate(fullDate!));
      const days = ['min', 'sen', 'sel', 'rab', 'kam', 'jum', 'sab']; // DateTime weekday: Mon=1..Sun=7
      final day = days[dt.weekday % 7];
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      return '$day\n$dd/$mm';
    } catch (_) {
      return '';
    }
  }

  String _toIsoDate(String raw) {
    // Convert "September 27, 2025" -> "2025-09-27"
    final parts = raw.split(',');
    if (parts.length < 2) return raw;
    final year = parts[1].trim();
    final monthDay = parts[0].trim().split(' ');
    if (monthDay.length < 2) return raw;
    final monthName = monthDay[0].toLowerCase();
    final day = monthDay[1].padLeft(2, '0');
    const months = {
      'january': '01', 'february': '02', 'march': '03', 'april': '04', 'may': '05', 'june': '06',
      'july': '07', 'august': '08', 'september': '09', 'october': '10', 'november': '11', 'december': '12'
    };
    final mm = months[monthName] ?? '01';
    return '$year-$mm-$day';
  }
}
