import 'package:abotrack_fl/src/components/base/drawer_component.dart';
import 'package:abotrack_fl/src/components/dashboard/aboo_list_component.dart';
import 'package:abotrack_fl/src/components/dashboard/analytics_component.dart';
import 'package:abotrack_fl/src/components/dashboard/chart_component.dart';
import 'package:abotrack_fl/src/components/dashboard/search_filter_component.dart';
import 'package:abotrack_fl/src/components/dashboard/upcoming_renewals_component.dart';
import 'package:abotrack_fl/src/controller/abo_controller.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardView extends StatelessWidget {
  DashboardView({super.key});
  static const String dashboard = '/dashboard';
  static const String settings = '/settings';
  static const String abo = '/abo';

  final DrawerComponent drawer = DrawerComponent();

  @override

  /// Build method for the DashboardView widget.
  ///
  /// This method creates the layout for the dashboard view. It contains a
  /// ChartComponent and an AboListComponent, which are both displayed in a
  /// ListView. The ChartComponent is used to display the monthly cost of the
  /// abos, while the AboListComponent is used to display the list of abos.
  ///
  /// The method also adds a FloatingActionButton to the bottom right corner
  /// of the screen. When pressed, this button opens a dialog to add a new abo.
  ///
  /// The background color of the Scaffold is set to a light gray color, and
  /// the AppBar is set to have a transparent background and no shadow.
  Widget build(BuildContext context) {
    final aboController = Provider.of<AboController>(context);

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        shadowColor: Colors.transparent,
        elevation: 0,
        toolbarOpacity: 1,
        actions: [
          IconButton(
            icon: Icon(aboController.sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
            tooltip: 'Sort by start date',
            onPressed: () {
              aboController.toggleSortOrder();
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            tooltip: 'Filter subscriptions',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) {
                  final TextEditingController nameController = TextEditingController(text: aboController.filterQuery);
                  DateTime? startDate = aboController.filterStartDate;
                  DateTime? endDate = aboController.filterEndDate;
                  
                  return StatefulBuilder(
                    builder: (context, setDialogState) {
                      return AlertDialog(
                        title: Text('Filter Subscriptions'),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name:', style: theme.textTheme.labelLarge),
                              TextField(
                                controller: nameController,
                                decoration: InputDecoration(hintText: 'Enter name'),
                              ),
                              const SizedBox(height: 16),
                              Text('Date Range:', style: theme.textTheme.labelLarge),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('From:', style: theme.textTheme.bodySmall),
                                        TextButton(
                                          onPressed: () async {
                                            DateTime? picked = await showDatePicker(
                                              context: context,
                                              initialDate: startDate ?? DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2100),
                                            );
                                            if (picked != null) {
                                              setDialogState(() => startDate = picked);
                                            }
                                          },
                                          child: Text(startDate?.toLocal().toString().split(' ')[0] ?? 'Any'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('To:', style: theme.textTheme.bodySmall),
                                        TextButton(
                                          onPressed: () async {
                                            DateTime? picked = await showDatePicker(
                                              context: context,
                                              initialDate: endDate ?? DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2100),
                                            );
                                            if (picked != null) {
                                              setDialogState(() => endDate = picked);
                                            }
                                          },
                                          child: Text(endDate?.toLocal().toString().split(' ')[0] ?? 'Any'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              aboController.clearAllFilters();
                              Navigator.of(ctx).pop();
                            },
                            child: Text('Clear'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              aboController.filterAbosByName(nameController.text);
                              aboController.filterAbosByDateRange(startDate, endDate);
                              Navigator.of(ctx).pop();
                            },
                            child: Text('Apply'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
      drawer: drawer.customDrawer(context),
      body: Stack(
        children: [
          ListView(
            physics: Theme.of(context).platform == TargetPlatform.iOS
                ? const ClampingScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            children: [
              const ChartComponent(),
              const SizedBox(height: 20),
              const AnalyticsComponent(),
              const SizedBox(height: 20),
              const UpcomingRenewalsComponent(),
              const SizedBox(height: 20),
              const SearchFilterComponent(),
              const SizedBox(height: 20),
              const AboListComponent(),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 50,
            child: Center(
              child: Container(
                  padding: const EdgeInsets.all(8),
                  height: 58,
                  width: 250,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: theme.cardColor,
                  ),
                  child: Center(
                    child: Text(
                      'Monthly cost: ${aboController.getMonthlyCost().toStringAsFixed(2)}\$',
                      style: theme.textTheme.bodyLarge,
                    ),
                  )),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => aboController.showAddAboDialog(context),
        backgroundColor: theme.floatingActionButtonTheme.backgroundColor,
        child: const Icon(Icons.add), // Add icon
      ),
    );
  }
}
