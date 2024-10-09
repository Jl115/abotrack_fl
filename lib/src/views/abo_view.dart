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
  Widget build(BuildContext context) {
    final aboController = Provider.of<AboController>(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 150, 142, 142),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 50,
        toolbarOpacity: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list, color: Colors.black),
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
                    child: Text(choice),
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
                color: const Color.fromARGB(255, 218, 218, 218),
              ),
              child: Container(
                height: 780,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: const Color.fromARGB(255, 218, 218, 218),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
        backgroundColor: const Color.fromARGB(255, 218, 218, 218),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          aboController.showAddAboDialog(context);
        },
      ),
    );
  }
}
