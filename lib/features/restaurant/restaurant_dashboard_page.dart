  import 'package:flutter/material.dart';
  import 'restaurant_menu_page.dart';
  import 'restaurant_profile_page.dart';
  import 'restaurant_offers_page.dart';
  import '../../../screens/admin/orders_page.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';


  class RestaurantDashboardPage extends StatefulWidget {
    const RestaurantDashboardPage({super.key});

    @override
    State<RestaurantDashboardPage> createState() =>
        _RestaurantDashboardPageState();
  }

  class _RestaurantDashboardPageState
      extends State<RestaurantDashboardPage> {


    @override
    Widget build(BuildContext context) {

      final width =
          MediaQuery.of(context).size.width;

      final crossAxisCount =
      width > 1200
          ? 4
          : width > 700
          ? 2
          : 1;

      return Scaffold(

        appBar: AppBar(
          title: const Text(
            'Restaurant Dashboard',
          ),
        ),

          body: SingleChildScrollView(
            child: Column(
            children: [

              StreamBuilder<QuerySnapshot>(

                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .where(
                  'restaurantId',
                  isEqualTo:
                  FirebaseAuth.instance.currentUser!.uid,
                )
                    .snapshots(),

                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return Container(
                      margin: const EdgeInsets.all(20),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final orders = snapshot.data!.docs;

                  int totalDelivered = 0;
                  double totalRevenue = 0;

                  int todayDelivered = 0;
                  double todayRevenue = 0;

                  double totalEarnings = 0;
                  double todayEarnings = 0;

                  double totalCommission = 0;
                  double totalDeliveryCharges = 0;

                  for (var order in orders) {

                    final data =
                    order.data() as Map<String, dynamic>;

                    final status =
                    (data['status'] ?? '')
                        .toString()
                        .toUpperCase();

                    if (status == 'DELIVERED') {

                      totalDelivered++;

                      totalRevenue +=
                          (data['totalAmount'] ?? 0)
                              .toDouble();
                      totalEarnings +=
                          (data['restaurantEarning'] ?? 0)
                              .toDouble();
                      totalCommission +=
                          (data['platformCommission'] ?? 0)
                              .toDouble();

                      totalDeliveryCharges +=
                          (data['deliveryCharge'] ?? 0)
                              .toDouble();

                      if (data['deliveredAt'] != null) {

                        final deliveredDate =
                        (data['deliveredAt'] as Timestamp)
                            .toDate();

                        final now = DateTime.now();

                        if (deliveredDate.year == now.year &&
                            deliveredDate.month == now.month &&
                            deliveredDate.day == now.day) {

                          todayDelivered++;

                          todayRevenue +=
                              (data['totalAmount'] ?? 0)
                                  .toDouble();
                          todayEarnings +=
                              (data['restaurantEarning'] ?? 0)
                                  .toDouble();
                        }
                      }
                    }
                  }

                  return Container(

                    margin: const EdgeInsets.all(12),

                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.green.shade200,
                      ),
                    ),

                    child: Column(

                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        const Text(
                          "SALES REPORT",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Row(

                          children: [

                            Expanded(

                              child: Container(

                                padding:
                                const EdgeInsets.all(12),

                                decoration: BoxDecoration(

                                  color: Colors.white,

                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),

                                child: Column(

                                  children: [

                                    const Text(
                                      "TODAY",
                                      style: TextStyle(
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      "$todayDelivered Orders",
                                    ),

                                    Text(
                                      "₹${todayRevenue.toStringAsFixed(0)}",
                                    ),

                                    Text(
                                      "₹${todayEarnings.toStringAsFixed(0)} Earnings",
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(

                              child: Container(

                                padding:
                                const EdgeInsets.all(12),

                                decoration: BoxDecoration(

                                  color: Colors.white,

                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),

                                child: Column(

                                  children: [

                                    const Text(
                                      "OVERALL",
                                      style: TextStyle(
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      "$totalDelivered Orders",
                                    ),

                                    Text(
                                      "₹${totalRevenue.toStringAsFixed(0)}",
                                    ),

                                    Text(
                                      "₹${totalEarnings.toStringAsFixed(0)} Earnings",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Container(

                          padding:
                          const EdgeInsets.all(12),

                          decoration: BoxDecoration(

                            color: Colors.white,

                            borderRadius:
                            BorderRadius.circular(12),
                          ),

                          child: Column(

                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [

                              const Text(

                                "SETTLEMENT",

                                style: TextStyle(
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Row(

                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,

                                children: [

                                  const Text(
                                    "Platform Fee",
                                  ),

                                  Text(
                                    "₹${totalCommission.toStringAsFixed(0)}",
                                  ),
                                ],
                              ),

                              Row(

                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,

                                children: [

                                  const Text(
                                    "Delivery Charges",
                                  ),

                                  Text(
                                    "₹${totalDeliveryCharges.toStringAsFixed(0)}",
                                  ),
                                ],
                              ),

                              const Divider(),

                              Row(

                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,

                                children: [

                                  const Text(

                                    "Net Earnings",

                                    style: TextStyle(
                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                  ),

                                  Text(

                                    "₹${totalEarnings.toStringAsFixed(0)}",

                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

        GridView.count(

          shrinkWrap: true,

          physics:
          const NeverScrollableScrollPhysics(),

          padding:
          const EdgeInsets.all(20),

          crossAxisCount:
          crossAxisCount,

          childAspectRatio: 2.2,

          crossAxisSpacing: 20,

          mainAxisSpacing: 20,

          children: [

            _dashboardCard(
              context,
              title: "Orders",
              icon: Icons.receipt_long,
              color: Colors.deepOrange,
              page: const OrdersPage(
                userRole: 'restaurant_partner',
              ),
            ),

            _dashboardCard(
              context,
              title: "Menu",
              icon: Icons.restaurant_menu,
              color: Colors.green,
              page:
              const RestaurantMenuPage(),
            ),

            _dashboardCard(
              context,
              title: "Offers",
              icon: Icons.local_offer,
              color: Colors.blue,
              page:
              const RestaurantOffersPage()
            ),

            _dashboardCard(
              context,
              title: "Profile",
              icon: Icons.store,
              color: Colors.purple,
              page:
              const RestaurantProfilePage()
            ),
          ],
        ),

      ],
     ),
    ),
    );
   }

    Widget _dashboardCard(
        BuildContext context, {

          required String title,

          required IconData icon,

          required Color color,

          required Widget page,
        }) {

      return InkWell(

        borderRadius:
        BorderRadius.circular(20),

        onTap: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => page,
            ),
          );
        },

        child: Container(

          decoration: BoxDecoration(

            borderRadius:
            BorderRadius.circular(20),

            gradient: LinearGradient(

              colors: [

                color,

                color.withValues(alpha: 0.7),
              ],
            ),

            boxShadow: const [

              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
              ),
            ],
          ),

          child: Column(

            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [

              Icon(
                icon,
                size: 55,
                color: Colors.white,
              ),

              const SizedBox(height: 15),

              Text(

                title,

                style: const TextStyle(

                  color: Colors.white,

                  fontSize: 20,

                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }