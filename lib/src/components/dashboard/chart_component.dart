import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartComponent extends StatefulWidget {
  const ChartComponent({super.key});

  @override
  _ChartComponentState createState() => _ChartComponentState();
}

class _ChartComponentState extends State<ChartComponent> {
  int _currentGraph = 0;

  void _changeGraph() {
    setState(() {
      _currentGraph = (_currentGraph + 1) % 2; // Toggle between two graphs
    });
  }

  Widget _buildLineChart() {
    return Center(
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: [
                  FlSpot(0, 1),
                  FlSpot(1, 3),
                  FlSpot(2, 2),
                  FlSpot(3, 5),
                  FlSpot(4, 4),
                ],
                isCurved: true,
                barWidth: 3,
                dotData: FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return Center(
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            barGroups: [
              BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 5)]),
              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 3)]),
              BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 4)]),
              BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 7)]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Container(
        height: 300,
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
                padding: const EdgeInsets.all(8.0),
                child:
                    _currentGraph == 0 ? _buildLineChart() : _buildBarChart(),
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
