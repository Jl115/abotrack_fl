import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:abotrack_fl/src/controller/abo_controller.dart';

class AboListComponent extends StatelessWidget {
  const AboListComponent({super.key});

  @override

  /// Build method for the AboListComponent widget.
  ///
  /// This method creates the layout for the AboListComponent widget. It contains a
  /// ListView with a Slidable widget for each abo. The user can swipe the
  /// Slidable widget to the left to edit the abo, and swipe it to the right to
  /// delete the abo.
  ///
  /// The method also adds a Drawer to the Scaffold, which is used to navigate
  /// between the different views of the app.
  ///
  /// The background color of the Scaffold is set to a light gray color, and
  /// the AppBar is set to have a transparent background and no shadow.
  Widget build(BuildContext context) {
    final aboController = Provider.of<AboController>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
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
            itemCount: aboController.abos.length,
            // Inside ListView.builder of AboView
            itemBuilder: (context, index) {
              final abo = aboController.abos[index];
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 16,
                ),
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
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
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
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        icon: Icons.delete,
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
                              abo.name,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              abo.isMonthly ? 'Monthly' : 'Yearly',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 16),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Start Date: ${abo.startDate.toLocal().toString().split(' ')[0]}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                            Text(
                              'End Date: ${abo.endDate.toLocal().toString().split(' ')[0]}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${abo.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
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
