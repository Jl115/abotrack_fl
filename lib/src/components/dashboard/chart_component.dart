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

  /// Toggle between the three graphs.
  ///
  /// This function is called when the user clicks the swap icon in the
  /// top-right corner of the graph. It changes the `_currentGraph` state
  /// variable to the next graph. The modulo operator is used to cycle back
  /// to 0 when the end of the list is reached.
  void _changeGraph() {
    setState(() {
      _currentGraph = (_currentGraph + 1) % 3; // Toggle between three graphs
    });
  }

  /// Build a line chart of the monthly payments.
  ///
  /// This function creates a line chart where the x-axis represents the
  /// months of the year and the y-axis represents the total cost of all
  /// abos for that month. The chart is zoomable and has a grid background
  /// for improved readability. The line is slightly thicker than usual to
  /// make it easier to see, and small dots are shown at each data point to
  /// make it clearer where the data points are. The area below the line is
  /// also filled in with a light blue color to make it easier to see the
  /// total cost of the abos for each month.
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

  /// Builds a BarChart widget with the given [monthlyPayments].
  ///
  /// The chart displays the monthly payments, with the current month highlighted
  /// in red. The chart title is not shown, and the x-axis is labeled with the
  /// month names. The y-axis is labeled with the payment amounts. The chart also
  /// shows a grid to help with visualization.
  ///
  /// The chart size is set to 350x350 to make it easier to read.
  ///
  /// The bar width is set to 16 to make them easier to see.
  ///
  /// The font size for the x-axis labels is increased to 12 to make them easier
  /// to read.
  ///
  /// The font size for the y-axis labels is increased to 12 to make them easier
  /// to read.
  ///
  /// The chart is centered horizontally and vertically.
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

  /// Builds a PieChart widget with the given [abos].
  ///
  /// The chart displays the abos as slices of a pie, with each slice labeled
  /// with the name of the abo and its price. The chart title is not shown, and
  /// the slices are colored differently to make them easier to distinguish.
  ///
  /// The chart size is set to 350x350 to make it easier to read.
  ///
  /// The radius of each slice is set to 60 to make them easier to see.
  ///
  /// The font size for the slice labels is increased to 12 to make them easier
  /// to read.
  ///
  /// The slices are spaced apart by 2 units to make them easier to distinguish.
  ///
  /// The chart is centered horizontally and vertically.
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

  /// Returns a color for the given index. The color is generated by cycling through
  /// a list of colors. If the index is larger than the length of the list, the
  /// color is wrapped around to the beginning of the list.
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

  /// Builds a widget to display a chart of the monthly payments of the abos.
  ///
  /// The widget displays a chart of the monthly payments of the abos. The chart
  /// can be switched between a line chart, a bar chart, and a pie chart. The
  /// user can press the swap icon on the top right to change the chart type.
  ///
  /// The chart displays the monthly payments of the abos in a specific order.
  /// The order is determined by the start date of the abos. The abos are sorted
  /// by their start date, and the monthly payments are calculated accordingly.
  ///
  /// The chart is displayed inside a container with a rounded rectangle shape.
  /// The container has a light gray background color. The chart is centered
  /// horizontally and vertically inside the container.
  ///
  /// This method is called from the [DashboardView] widget.
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
