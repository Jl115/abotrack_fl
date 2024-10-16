import 'package:abotrack_fl/src/components/base/drawer_component.dart';
import 'package:abotrack_fl/src/components/dashboard/aboo_list_component.dart';
import 'package:abotrack_fl/src/components/dashboard/chart_component.dart';
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
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
      drawer: drawer.customDrawer(context),
      body: Stack(
        children: [
          ListView(
            physics: Theme.of(context).platform == TargetPlatform.iOS
                ? const ClampingScrollPhysics() // For a more rigid scroll on iOS
                : const AlwaysScrollableScrollPhysics(), // Allow normal scroll on Android
            children: const [
              ChartComponent(),
              SizedBox(height: 20),
              AboListComponent(),
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
