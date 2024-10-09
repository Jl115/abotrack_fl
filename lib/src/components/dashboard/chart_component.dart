import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:abotrack_fl/src/controller/abo_controller.dart';

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
        height: 200,
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: monthlyPayments
                    .asMap()
                    .entries
                    .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                    .toList(),
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

  Widget _buildBarChart(List<double> monthlyPayments) {
    return Center(
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            barGroups: monthlyPayments
                .asMap()
                .entries
                .map((entry) => BarChartGroupData(
                      x: entry.key,
                      barRods: [BarChartRodData(toY: entry.value)],
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(List<Abo> abos) {
    return Center(
      child: SizedBox(
        height: 200,
        child: PieChart(
          PieChartData(
            sections: abos
                .asMap()
                .entries
                .map((entry) => PieChartSectionData(
                      color: _getColorForIndex(entry.key),
                      value: entry.value.price,
                      title: entry.value.name,
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ))
                .toList(),
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
    final monthlyPayments = aboController.abos.map((abo) {
      return abo.isMonthly ? abo.price : abo.price / 12;
    }).toList();

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
