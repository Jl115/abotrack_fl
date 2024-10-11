import 'package:abotrack_fl/src/components/base/drawer_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:abotrack_fl/src/controller/abo_controller.dart';

class AboView extends StatelessWidget {
  AboView({super.key});
  static const String abo = '/abo';
  final DrawerComponent drawer = DrawerComponent();

  @override

  /// Build method for the AboView widget.
  ///
  /// This method creates the layout for the AboView widget. It contains a
  /// ListView with a Slidable widget for each abo. The user can swipe the
  /// Slidable widget to the left to edit the abo, and swipe it to the right to
  /// delete the abo. The user can also add a new abo by pressing the
  /// FloatingActionButton.
  ///
  /// The method also adds a Drawer to the Scaffold, which is used to navigate
  /// between the different views of the app.
  ///
  /// The background color of the Scaffold is set to a light gray color, and
  /// the AppBar is set to have a transparent background and no shadow.
  Widget build(BuildContext context) {
    final aboController = Provider.of<AboController>(context);
    final theme = Theme.of(context); // Get the current theme

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor, // Use theme background color
      appBar: AppBar(
        backgroundColor:
            theme.appBarTheme.backgroundColor, // Use theme AppBar color
        shadowColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 50,
        toolbarOpacity: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.filter_list, color: theme.iconTheme.color),
              onSelected: (value) {
                if (value == 'Oldest') {
                  aboController.filterByOldest();
                } else if (value == 'Newest') {
                  aboController.filterByNewest();
                } else {
                  aboController.clearFilter();
                }
              },
              itemBuilder: (BuildContext context) {
                return ['Oldest', 'Newest', 'Clear Filter']
                    .map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice, style: theme.textTheme.bodyMedium),
                  );
                }).toList();
              },
            ),
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      drawer: drawer.customDrawer(context),
      // Start Body
      body: Stack(
        children: [
          Center(
            child: Container(
              width: 400,
              height: 650,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16),
                color: theme.cardColor, // Use theme card color
              ),
              child: Container(
                height: 780,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: theme.cardColor,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    shrinkWrap: true,
                    itemCount: aboController.abos.length,
                    itemBuilder: (context, index) {
                      final abo = aboController.abos[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Slidable(
                          key: ValueKey(abo.id),
                          startActionPane: ActionPane(
                            motion: const BehindMotion(),
                            extentRatio: 0.25,
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  aboController.showEditAboDialog(context, abo);
                                },
                                backgroundColor: theme.primaryColor,
                                foregroundColor: theme.colorScheme.onPrimary,
                                borderRadius: BorderRadius.circular(16),
                                icon: Icons.edit,
                              ),
                            ],
                          ),
                          endActionPane: ActionPane(
                            motion: const BehindMotion(),
                            extentRatio: 0.25,
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  aboController.deleteAbo(abo.id);
                                },
                                backgroundColor: theme.hintColor,
                                foregroundColor: theme.colorScheme.onError,
                                borderRadius: BorderRadius.circular(16),
                                icon: Icons.delete,
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: theme.primaryColorDark,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      abo.name,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onPrimary,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      abo.isMonthly ? 'Monthly' : 'Yearly',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.hintColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Start Date: ${abo.startDate.toLocal().toString().split(' ')[0]}',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                    ),
                                    Text(
                                      'End Date: ${abo.endDate.toLocal().toString().split(' ')[0]}',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${abo.price.toStringAsFixed(2)}',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onPrimary,
                                        fontSize: 16,
                                      ),
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
            ),
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
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.floatingActionButtonTheme.backgroundColor,
        child: Icon(Icons.add, color: theme.colorScheme.onSecondary),
        onPressed: () {
          aboController.showAddAboDialog(context);
        },
      ),
    );
  }
}
