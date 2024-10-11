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
          color: Theme.of(context).cardColor, // Use theme color for background
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                        backgroundColor: Theme.of(context)
                            .primaryColor, // Theme color for edit action
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
                        backgroundColor: Theme.of(context)
                            .splashColor, // Theme error color for delete action
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
                      color: Theme.of(context)
                          .primaryColorDark, // Use darker primary color for list item background
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              abo.isMonthly ? 'Monthly' : 'Yearly',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Start Date: ${abo.startDate.toLocal().toString().split(' ')[0]}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                            ),
                            Text(
                              'End Date: ${abo.endDate.toLocal().toString().split(' ')[0]}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${abo.price.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.white,
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
    );
  }
}
