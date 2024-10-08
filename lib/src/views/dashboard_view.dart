import 'package:abotrack_fl/src/components/base/drawer_component.dart';
import 'package:abotrack_fl/src/components/dashboard/chart_component.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:flutter/material.dart';

class DashboardView extends StatelessWidget {
  DashboardView({super.key});
  static const String dashboard = '/dashboard';
  static const String settings = '/settings';
  static const String abo = '/abo';

  //Class Imports
  final DrawerComponent drawer = DrawerComponent();

  @override
  Widget build(BuildContext context) {
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
      body: ListView(
        physics: Theme.of(context).platform == TargetPlatform.iOS
            ? const ClampingScrollPhysics() // For a more rigid scroll on iOS
            : const AlwaysScrollableScrollPhysics(), // Allow normal scroll on Android
        children: [
          ChartComponent(),
          const SizedBox(height: 20),
          _buildStyledListView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
          print('Floating action button pressed');
        },
        backgroundColor: const Color.fromARGB(232, 222, 248, 248),
        child: const Icon(Icons.add), // Swap icon
      ),
    );
  }

  Widget _buildStyledListView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 780,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: const Color.fromARGB(255, 218, 218, 218),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            shrinkWrap: true,
            itemCount: 20,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 16,
                ),
                child: Slidable(
                  key: ValueKey(index),
                  startActionPane: ActionPane(
                    motion: const BehindMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          // Handle edit action
                          print('Edit item $index');
                        },
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Edit',
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const BehindMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          // Handle delete action
                          print('Delete item $index');
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 100, 100, 100),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Abo ${index + 1}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              '|||',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            Text(
                              'Price',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'End date',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
