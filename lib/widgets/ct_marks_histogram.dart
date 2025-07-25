import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ct_mark_entry.dart';

class CtMarksHistogram extends StatelessWidget {
  final Map<String, dynamic> data;
  const CtMarksHistogram({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final courses = data['courses'] as Map<String, dynamic>;
    final List<CtMarkEntry> entries = [];
    final List<Color> courseColors = [
      Colors.cyanAccent,
      Colors.blueAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.greenAccent,
      Colors.redAccent,
    ];

    int colorIndex = 0;
    final Map<String, Color> courseColorMap = {};

    courses.forEach((course, exams) {
      courseColorMap[course] = courseColors[colorIndex % courseColors.length];
      colorIndex++;
      for (int i = 0; i < (exams as List).length; i++) {
        final pair = exams[i] as List;
        final percent = (pair[0] / pair[1]) * 100;
        entries.add(
          CtMarkEntry(
            course: course,
            exam: i + 1,
            obtained: pair[0],
            total: pair[1],
            percent: percent,
          ),
        );
      }
    });

    entries.sort((a, b) {
      int cmp = a.course.compareTo(b.course);
      if (cmp != 0) return cmp;
      return a.exam.compareTo(b.exam);
    });

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              minY: 0,
              gridData: FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 20,
                    getTitlesWidget: (value, meta) {
                      if (value % 20 == 0) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              barGroups: List.generate(entries.length, (i) {
                final entry = entries[i];
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: entry.percent,
                      color: courseColorMap[entry.course],
                      width: 16,
                      borderRadius: BorderRadius.circular(6),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: 100,
                        color: Colors.white.withAlpha(30),
                      ),
                    ),
                  ],
                );
              }),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) =>
                      Colors.black.withValues(alpha: 0.92),
                  tooltipBorderRadius: BorderRadius.circular(18),
                  tooltipMargin: 12,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final entry = entries[group.x.toInt()];
                    return BarTooltipItem(
                      '${entry.course} CT${entry.exam}\n',
                      GoogleFonts.poppins(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: '${entry.obtained}/${entry.total}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 30,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          children: courseColorMap.entries.map((e) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: e.value,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  e.key,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
