import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:abotrack_fl/src/controller/abo_controller.dart';
import 'package:intl/intl.dart';

class ChartComponent extends StatefulWidget {
  const ChartComponent({super.key});

  @override
  _ChartComponentState createState() => _ChartComponentState();
}

class _ChartComponentState extends State<ChartComponent> {
  int _currentGraph = 0;

  void _changeGraph() {
    setState(() {
      _currentGraph = (_currentGraph + 1) % 3; // Toggle between three graphs
    });
  }

  Widget _buildLineChart(List<double> monthlyPayments) {
    return Center(
      child: SizedBox(
        height: 350,
        child: LineChart(
          LineChartData(
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final month = DateFormat.MMM()
                        .format(DateTime(2024, value.toInt() + 1));
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(month,
                          style: const TextStyle(
                              fontSize: 12)), // Increased font size
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: monthlyPayments
                    .asMap()
                    .entries
                    .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                    .toList(),
                isCurved: true,
                barWidth: 5, // Slightly thicker line for better visibility
                dotData: const FlDotData(
                    show: true), // Show dots to make data points clearer
                belowBarData: BarAreaData(
                    show: true, color: Colors.lightBlue.withOpacity(0.3)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(List<double> monthlyPayments) {
    final currentMonth = DateTime.now().month - 1; // 0-based index for month

    return Center(
      child: SizedBox(
        height: 350, // Increased height for better readability
        child: BarChart(
          BarChartData(
            barGroups: monthlyPayments
                .asMap()
                .entries
                .map((entry) => BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: entry.key == currentMonth
                              ? Colors.red
                              : Colors.blue, // Highlight current month in red
                          width: 16, // Increase bar width for better visibility
                        ),
                      ],
                    ))
                .toList(),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final month = DateFormat.MMM()
                        .format(DateTime(2024, value.toInt() + 1));
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                        child:
                            Text(month, style: const TextStyle(fontSize: 12)),
                      ), // Increased font size
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 12));
                  },
                ),
              ),
            ),
            gridData: const FlGridData(show: true),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(List<Abo> abos) {
    return Center(
      child: SizedBox(
        height: 350, // Increased height for better readability
        child: PieChart(
          PieChartData(
            sections: abos
                .asMap()
                .entries
                .map((entry) => PieChartSectionData(
                      color: _getColorForIndex(entry.key),
                      value: entry.value.price,
                      title:
                          '${entry.value.name}\n${entry.value.price.toStringAsFixed(2)}',
                      radius: 60, // Increased radius for better visibility
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ))
                .toList(),
            sectionsSpace:
                2, // Spacing between sections for better differentiation
          ),
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    // Generate different colors for each slice
    const colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.yellow,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final aboController = Provider.of<AboController>(context);

    // Calculate monthly payments, converting yearly to equivalent monthly
    final monthlyPayments = List.generate(12, (index) => 0.0);
    for (var abo in aboController.abos) {
      int startMonth = abo.startDate.month - 1;
      double monthlyCost = abo.isMonthly ? abo.price : abo.price / 12;
      monthlyPayments[startMonth] += monthlyCost;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 400, // Increased container height for better readability
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: const Color.fromARGB(255, 218, 218, 218),
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 16.0, bottom: 16.0, left: 16.0, right: 16.0),
                child: _currentGraph == 0
                    ? _buildLineChart(monthlyPayments)
                    : _currentGraph == 1
                        ? _buildBarChart(monthlyPayments)
                        : _buildPieChart(aboController.abos),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.swap_horiz, color: Colors.black),
                onPressed: _changeGraph,
                tooltip: 'Change Graph',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
