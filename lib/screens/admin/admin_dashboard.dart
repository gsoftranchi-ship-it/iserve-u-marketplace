import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF1F3F6),

      appBar: AppBar(

        elevation: 0,

        backgroundColor: const Color(0xFF0A2540),

        title: const Text(
          "Business Intelligence",

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy(
          'timestamp',
          descending: true,
        )
            .snapshots(),

        builder: (context, snapshot) {

          // ===================================================
          // LOADING
          // ===================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ===================================================
          // ERROR
          // ===================================================

          if (snapshot.hasError) {

            return Center(

              child: Padding(

                padding: const EdgeInsets.all(20),

                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [

                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Unable to load orders",

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // ===================================================
          // EMPTY
          // ===================================================

          if (!snapshot.hasData) {

            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;



          // ===================================================
          // ANALYTICS
          // ===================================================

          int totalOrders = 0;
          double totalRevenue = 0;

          double totalCommission = 0;

          int todayOrders = 0;
          double todayRevenue = 0;

          double todayCommission = 0;

          for (final doc in docs) {

            final data =
            doc.data() as Map<String, dynamic>?;

            final status =
            (data?['status'] ?? '')
                .toString()
                .toUpperCase();

            if (status == 'DELIVERED') {

              totalOrders++;

              totalRevenue +=
                  (data?['totalAmount'] ?? 0)
                      .toDouble();

              totalCommission +=
                  (data?['platformCommission'] ?? 0)
                      .toDouble();

              if (data?['deliveredAt'] != null) {

                final deliveredDate =
                (data!['deliveredAt']
                as Timestamp)
                    .toDate();

                final now = DateTime.now();

                final isToday =
                    deliveredDate.year == now.year &&
                        deliveredDate.month == now.month &&
                        deliveredDate.day == now.day;

                if (isToday) {

                  todayOrders++;

                  todayRevenue +=
                      (data['totalAmount'] ?? 0)
                          .toDouble();

                  todayCommission +=
                      (data['platformCommission'] ?? 0)
                          .toDouble();
                }
              }
            }
          }

          // ===================================================
          // BODY
          // ===================================================

          return Column(
            children: [

              _buildStatsHeader(
                totalRevenue,
                totalOrders,
                totalCommission,
                todayOrders,
                todayRevenue,
                todayCommission,
              ),

              _buildDeliveryRequests(),

              const Padding(
                padding: EdgeInsets.all(16),

                child: Align(
                  alignment: Alignment.centerLeft,

                  child: Text(
                    "RECENT ORDERS",

                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              if (docs.isNotEmpty)

                Expanded(

                child: ListView.builder(

                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),

                  itemCount: docs.length,

                  itemBuilder: (context, index) {

                    final orderDoc = docs[index];

                    final order =
                    orderDoc.data()
                    as Map<String, dynamic>?;

                    final customerName =
                        order?['customerName']
                            ?? "Unknown Client";

                    final totalAmount =
                        order?['totalAmount']
                            ?? 0;

                    final itemCount =
                        (order?['items'] as List?)
                            ?.length ?? 0;

                    final status =
                        order?['status']
                            ?? 'Pending';

                    return Card(

                      margin:
                      const EdgeInsets.only(
                        bottom: 12,
                      ),

                      elevation: 0,

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(15),
                      ),

                      child: ListTile(

                        contentPadding:
                        const EdgeInsets.all(12),

                        leading:
                        const CircleAvatar(

                          backgroundColor:
                          Color(0xFF0A2540),

                          child: Icon(
                            Icons.receipt_long,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),

                        title: Text(
                          customerName,

                          style: const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        subtitle: Text(
                          "₹$totalAmount | $itemCount Items",
                        ),

                        trailing:
                        _buildStatusDropdown(
                          orderDoc,
                          status,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // =========================================================
  // STATUS DROPDOWN
  // =========================================================

  Widget _buildStatusDropdown(
      DocumentSnapshot doc,
      String? currentStatus,
      ) {

    const statuses = [
      'Pending',
      'Accepted',
      'Completed',
      'Delivered',
    ];

    final safeStatus =
    statuses.contains(currentStatus)
        ? currentStatus
        : 'Pending';

    return Container(

      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
      ),

      decoration: BoxDecoration(
        color: Colors.grey.shade100,

        borderRadius:
        BorderRadius.circular(8),
      ),

      child: DropdownButton<String>(

        value: safeStatus,

        underline: const SizedBox(),

        icon: const Icon(
          Icons.arrow_drop_down,
          color: Colors.orange,
        ),

        items: statuses.map((status) {

          return DropdownMenuItem<String>(

            value: status,

            child: Text(
              status,

              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),

        onChanged: (value) async {

          if (value == null) return;

          try {

            await doc.reference.update({
              'status': value,
            });

          } catch (e) {
            debugPrint(
              "Status Update Error: $e",
            );
          }
        },
      ),
    );
  }
  Widget _buildDeliveryRequests() {

    return StreamBuilder<QuerySnapshot>(

      stream: FirebaseFirestore.instance
          .collection('users')
          .where(
        'deliveryRequest',
        isEqualTo: true,
      )
          .snapshots(),

      builder: (context, snapshot) {

        if (!snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {

          return const SizedBox();
        }

        final users =
            snapshot.data!.docs;

        return Container(

          margin: const EdgeInsets.all(16),

          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:
            BorderRadius.circular(16),
          ),

          child: Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              const Text(

                "DELIVERY PARTNER REQUESTS",

                style: TextStyle(

                  fontWeight:
                  FontWeight.w900,

                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 16),

              ...users.map((userDoc) {

                final user =
                userDoc.data()
                as Map<String, dynamic>;

                return Card(

                  margin:
                  const EdgeInsets.only(
                    bottom: 12,
                  ),

                  child: ListTile(

                    leading: const CircleAvatar(

                      backgroundColor:
                      Colors.orange,

                      child: Icon(
                        Icons.delivery_dining,
                        color: Colors.white,
                      ),
                    ),

                    title: Text(
                      user['name'] ?? '',
                    ),

                    subtitle: Text(
                      user['email'] ?? '',
                    ),

                    trailing: ElevatedButton(

                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.green,
                      ),

                      onPressed: () async {

                        await FirebaseFirestore
                            .instance
                            .collection('users')
                            .doc(userDoc.id)
                            .update({

                          'role':
                          'delivery_partner',

                          'deliveryRequest':
                          false,
                        });
                      },

                      child: const Text(

                        "APPROVE",

                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // HEADER STATS
  // =========================================================

  Widget _buildStatsHeader(
      double revenue,
      int count,
      double commission,
      int todayOrders,
      double todayRevenue,
      double todayCommission,
      ) {

    return Container(

      width: double.infinity,

      padding:
      const EdgeInsets.symmetric(
        vertical: 30,
        horizontal: 20,
      ),

      decoration: const BoxDecoration(

        color: Color(0xFF0A2540),

        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),

      child: LayoutBuilder(

        builder: (context, constraints) {

          final isMobile =
              constraints.maxWidth < 600;

          return isMobile

              ? Column(
            children: [

              _statTile(
                "Total Revenue",
                "₹${revenue.toStringAsFixed(0)}",
                Colors.greenAccent,
              ),

              const SizedBox(height: 15),

              _statTile(
                "Total Orders",
                count.toString(),
                Colors.orangeAccent,
              ),

              const SizedBox(height: 15),

              _statTile(
                "Total Commission",
                "₹${commission.toStringAsFixed(0)}",
                Colors.amberAccent,
              ),

              const Divider(
                color: Colors.white24,
                height: 30,
              ),

              _statTile(
                "Today's Orders",
                todayOrders.toString(),
                Colors.cyanAccent,
              ),

              const SizedBox(height: 15),

              _statTile(
                "Today's Revenue",
                "₹${todayRevenue.toStringAsFixed(0)}",
                Colors.lightGreenAccent,
              ),

              const SizedBox(height: 15),

              _statTile(
                "Today's Commission",
                "₹${todayCommission.toStringAsFixed(0)}",
                Colors.yellowAccent,
              ),
            ],
          )

              : Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceAround,

            children: [

              _statTile(
                "Total Revenue",
                "₹${revenue.toStringAsFixed(0)}",
                Colors.greenAccent,
              ),

              _statTile(
                "Orders",
                count.toString(),
                Colors.orangeAccent,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statTile(
      String label,
      String value,
      Color color,
      ) {

    return Column(
      children: [

        Text(
          label,

          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          value,

          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // EMPTY STATE
  // =========================================================
  // ignore: unused_element
  Widget _buildEmptyState() {


    return const Center(

      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [

          Icon(
            Icons.receipt_long_outlined,
            size: 70,
            color: Colors.grey,
          ),

          SizedBox(height: 20),

          Text(
            "No orders found in database.",

            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}