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
  Widget build(BuildContext context) {
    final aboController = Provider.of<AboController>(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 150, 142, 142),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
                    color: const Color.fromARGB(232, 222, 248, 248),
                  ),
                  child: Center(
                    child: Text(
                      'Monthly cost: ${aboController.getMonthlyCost().toStringAsFixed(2)}\$',
                    ),
                  )),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => aboController.showAddAboDialog(context),
        backgroundColor: const Color.fromARGB(232, 222, 248, 248),
        child: const Icon(Icons.add), // Add icon
      ),
    );
  }
}
