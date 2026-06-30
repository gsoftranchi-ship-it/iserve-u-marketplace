import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../food_dining/order_status.dart';
import '../../features/notifications/services/notification_service.dart';
import 'package:url_launcher/url_launcher.dart';
class OrdersPage extends StatelessWidget {
  final String userRole;

  const OrdersPage({
    super.key,
    required this.userRole,
    });
  Future<void> openGoogleMapsByCoordinates(
      double lat,
      double lng,
      ) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }
  Future<void> assignRider({

    required String orderId,

    required String riderId,

    required String riderName,

    required String riderPhone,

  }) async {

    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({

      'riderId': riderId,

      'riderName': riderName,

      'riderPhone': riderPhone,

      'assignedAt':
      FieldValue.serverTimestamp(),

      'status':
      OrderStatus.riderAssigned,

      'statusUpdatedAt':
      FieldValue.serverTimestamp(),
    });

    await NotificationService().createNotification(
      userId: riderId,

      title: 'New Delivery Assigned',

      body: 'You have been assigned a new delivery.',

      type: 'delivery',
    );
  }

  Future<void> updateOrderStatus(
      String orderId,
      String status,
      ) async {

    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({

      'status': status,

      'statusUpdatedAt':
      FieldValue.serverTimestamp(),
    });
  }
  Future<Map<String, double>> getPricing() async {

    final doc = await FirebaseFirestore.instance
        .collection('admin_settings')
        .doc('pricing')
        .get();

    final data = doc.data() ?? {};

    return {

      'deliveryCharge':
      (data['deliveryCommissionPerOrder'] ?? 25)
          .toDouble(),

      'platformCommission':
      (data['platformChargePerOrder'] ?? 10)
          .toDouble(),
    };
  }
  Future<void> completeDelivery(
      String orderId,
      Map<String, dynamic> data,
      ) async {

    final pricing = await getPricing();

    final totalAmount =
    (data['totalAmount'] ?? 0).toDouble();

    final platformCommission =
    pricing['platformCommission']!;

    final deliveryCharge =
    pricing['deliveryCharge']!;

    final restaurantEarning =
        totalAmount -
            platformCommission -
            deliveryCharge;


    final Map<String, dynamic> updateData = {

      'status': OrderStatus.delivered,

      'deliveredAt': FieldValue.serverTimestamp(),

      'platformCommission': platformCommission,

      'deliveryCharge': deliveryCharge,

      'restaurantEarning': restaurantEarning,

    };

// Mark COD as paid after successful PIN verification
    if (data['paymentMethod'] == 'COD') {
      updateData['paymentStatus'] = 'PAID';
    }


    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update(updateData);


    // Customer
    await NotificationService().createNotification(
      userId: data['userId'],
      title: 'Order Delivered',
      body:
      'Your order has been delivered successfully.',
      type: 'delivery',
    );

    // Restaurant
    await NotificationService().createNotification(
      userId: data['restaurantId'],
      title: 'Order Delivered',
      body: 'Order delivered successfully.',
      type: 'order',
    );

    // Admin
    final adminDocs =
    await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .get();

    for (final admin in adminDocs.docs) {
      await NotificationService().createNotification(
        userId: admin.id,
        title: 'Order Delivered',
        body:
        'An order has been delivered successfully.',
        type: 'order',
      );
    }
  }
  @override
  Widget build(BuildContext context) {

    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    Query query =
    FirebaseFirestore.instance
        .collection('orders');

    // CLIENT FILTER
    if (userRole == 'client' &&
        currentUser != null) {
      query = query.where(
        'userId',
        isEqualTo: currentUser.uid,
      );

    } else if (userRole == 'delivery_partner'
        && currentUser != null) {

      query = query

          .where(

        'riderId',

        isEqualTo:
        currentUser.uid,
      )

          .where(
        'status',
          whereIn: [

            OrderStatus.riderAssigned,

            OrderStatus.pickedUp,

            OrderStatus.outForDelivery,
          ]
      );
    }
    else if (
    userRole == 'restaurant_partner' &&
    currentUser != null
    ) {

    query = query.where(
    'restaurantId',
    isEqualTo: currentUser.uid,
    );

    }

    return Scaffold(

      backgroundColor:
      const Color(0xFFF1F3F6),

      appBar: AppBar(

        title: const Text(

          "Order Tracking",

          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        elevation: 0,

        backgroundColor: Colors.white,

        foregroundColor: Colors.black,

        actions: const [],
      ),

       body: Column(
              children: [

              // DELIVERY REPORT
              if (userRole == 'delivery_partner')

          Padding(

          padding: const EdgeInsets.all(16),

      child: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance

            .collection('orders')

            .where(
          'riderId',
          isEqualTo:
          currentUser?.uid,
        )

            .where(
          'status',
          isEqualTo:
          OrderStatus.delivered,
        )

            .snapshots(),

        builder: (context, snapshot) {
          double cashCollected = 0;
          double amountToDeposit = 0;
          int totalDeliveries = 0;
          double totalEarnings = 0;

          int todayDeliveries = 0;
          double todayEarnings = 0;

          if (snapshot.hasData) {

            final docs = snapshot.data!.docs;

            totalDeliveries = docs.length;

            for (var doc in docs) {

              final data =
              doc.data()
              as Map<String, dynamic>;

              totalEarnings +=
                  (data['deliveryCharge'] ?? 0)
                      .toDouble();
              if ((data['paymentMethod'] ?? '') == 'COD') {

                cashCollected +=
                    (data['totalAmount'] ?? 0)
                        .toDouble();
              }

              if (data['deliveredAt'] != null) {

                final deliveredDate =
                (data['deliveredAt'] as Timestamp)
                    .toDate();

                final now = DateTime.now();

                final isToday =
                    deliveredDate.year == now.year &&
                        deliveredDate.month == now.month &&
                        deliveredDate.day == now.day;

                if (isToday) {

                  todayDeliveries++;

                  todayEarnings +=
                      (data['deliveryCharge'] ?? 0)
                          .toDouble();
                }
              }
            }
            amountToDeposit =
            cashCollected > 0
                ? cashCollected - totalEarnings
                : 0;
          }

          return Container(

            width: double.infinity,

            padding:
            const EdgeInsets.all(18),

            decoration: BoxDecoration(

              color:
              Colors.green.shade50,

              borderRadius:
              BorderRadius.circular(14),

              border: Border.all(
                color:
                Colors.green.shade200,
              ),
            ),

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                const Text(

                  "TODAY'S DELIVERY REPORT",

                  style: TextStyle(

                    fontWeight:
                    FontWeight.bold,

                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "Today's Deliveries: $todayDeliveries",
                ),

                Text(
                  "Today's Earnings: ₹${todayEarnings.toStringAsFixed(0)}",
                ),

                const SizedBox(height: 6),

                Text(
                  "Cash Collected: ₹${cashCollected.toStringAsFixed(0)}",
                ),
                if (cashCollected > 0)

                Text(
                  "Amount To Deposit: ₹${amountToDeposit.toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Divider(),

                Text(
                  "Total Deliveries: $totalDeliveries",
                ),

                Text(
                  "Total Earnings: ₹${totalEarnings.toStringAsFixed(0)}",
                ),
              ],
            ),
          );
        },
      ),
     ),

    Expanded(

    child: StreamBuilder<QuerySnapshot>(

        stream: query
            .orderBy(
          'timestamp',
          descending: true,
        )
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.hasError) {

            debugPrint(
              "❌ Firestore Error: ${snapshot.error}",
            );

            return const Center(
              child: Text(
                "Error: Please check Firebase Indexes",
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final orders =
              snapshot.data?.docs ?? [];

          if (orders.isEmpty) {

            return Center(

              child: Column(

                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [

                  Icon(
                    Icons.receipt_long_outlined,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 16),

                  const Text(

                    "No orders found",

                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const Text(

                    "Try placing a new order from the Food Page",

                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(

            padding:
            const EdgeInsets.all(16),

            itemCount: orders.length,

            itemBuilder: (context, index) {

              // ======================================================
              // DOCUMENT SNAPSHOT
              // ======================================================

              var doc = orders[index];

              // ======================================================
              // ORDER ID
              // ======================================================

              String orderId = doc.id;

              // ======================================================
              // DATA MAP
              // ======================================================

              var data =
              doc.data()
              as Map<String, dynamic>;
              Color statusColor;

              switch (data['status']) {

                case OrderStatus.pending:
                  statusColor = Colors.orange;
                  break;

                case OrderStatus.accepted:
                  statusColor = Colors.blue;
                  break;

                case OrderStatus.preparing:
                  statusColor = Colors.deepOrange;
                  break;

                case OrderStatus.ready:
                  statusColor = Colors.deepPurple;
                  break;

                case OrderStatus.outForDelivery:
                  statusColor = Colors.teal;
                  break;

                case OrderStatus.delivered:
                  statusColor = Colors.green;
                  break;

                  case OrderStatus.riderAssigned:
                  statusColor = Colors.orange;
                  break;

                case OrderStatus.pickedUp:
                  statusColor = Colors.indigo;
                  break;

                case OrderStatus.rejected:
                  statusColor = Colors.orangeAccent;
                  break;

                default:
                  statusColor = Colors.grey;
              }

              return Card(

                margin:
                const EdgeInsets.only(
                    bottom: 12),

                elevation: 0,

                shape:
                RoundedRectangleBorder(

                  borderRadius:
                  BorderRadius.circular(
                      12),

                  side: BorderSide(
                    color:
                    Colors.grey.shade200,
                  ),
                ),

                child: ExpansionTile(

                  leading:
                  const CircleAvatar(

                    backgroundColor:
                    Color(0xFF0A2540),

                    child: Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),

                  title: Row(

                    children: [

                  Expanded(

                  child: Text(

                  "Total: ₹${data['totalAmount']}",

                    overflow:
                    TextOverflow.ellipsis,

                    style: const TextStyle(

                      fontWeight:
                      FontWeight.bold,

                      fontSize: 15,
                    ),
                  ),
                  ),
                      const SizedBox(width: 8),


                      // STATUS BADGE
                Flexible(

                  child: Container(

                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),

                        decoration:
                        BoxDecoration(

                          color: statusColor.withValues(alpha: 0.1),

                          borderRadius:
                          BorderRadius
                              .circular(
                              8),
                        ),

                        child: Text(

                          data['status']
                              .toString()
                              .replaceAll('_', ' ')
                              .toUpperCase(),

                          overflow:
                          TextOverflow.ellipsis,

                          maxLines: 1,

                          style: TextStyle(

                            color: statusColor,

                            fontSize: 10,
                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),
                  ),
                ),
                    ],
                  ),

                  subtitle: Builder(

                    builder: (context) {

                      String formattedDate =
                          "";

                      if (data['timestamp'] !=
                          null) {

                        var date =
                        (data['timestamp']
                        as Timestamp)
                            .toDate();

                        formattedDate =
                        "${date.day}/${date.month} • ${date.hour}:${date.minute}";
                      }

                      return Text(

                        formattedDate,

                        style:
                        const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),

                  children: [

                    const Divider(),

                    // ======================================================
                    // ADMIN PAYMENT VERIFICATION
                    // ======================================================
                    if (data['paymentMethod'] == 'ONLINE')

                      Padding(

                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),

                        child: Container(

                          width: double.infinity,

                          padding: const EdgeInsets.all(14),

                          decoration: BoxDecoration(

                            color: Colors.orange.shade50,

                            borderRadius:
                            BorderRadius.circular(10),

                            border: Border.all(
                              color: Colors.orange.shade200,
                            ),
                          ),

                          child: Column(

                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [

                              const Text(

                                "ONLINE PAYMENT DETAILS",

                                style: TextStyle(

                                  fontWeight:
                                  FontWeight.bold,

                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "Method: ${data['paymentMethod']}",
                              ),

                              Text(
                                "Status: ${data['paymentStatus']}",
                              ),

                              Text(
                                "UTR / TXN ID: ${data['transactionId'] ?? 'Not Provided'}",
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (userRole == 'admin' &&
                        data['paymentMethod'] == 'ONLINE')

                      Padding(

                        padding: const EdgeInsets.all(16),

                        child: SizedBox(

                          width: double.infinity,

                          child: ElevatedButton.icon(

                            style: ElevatedButton.styleFrom(

                              backgroundColor:
                              data['paymentStatus'] == 'verified'
                                  ? Colors.green
                                  : Colors.orange,

                              shape: RoundedRectangleBorder(

                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                            ),

                            onPressed:
                            data['paymentStatus'] == 'verified'

                                ? null

                                : () async {

                              await FirebaseFirestore
                                  .instance
                                  .collection('orders')
                                  .doc(orderId)
                                  .update({

                                'paymentStatus':
                                'verified',
                              });

                              if (!context.mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(

                                const SnackBar(

                                  content: Text(
                                    "Payment Verified",
                                  ),
                                ),
                              );
                            },

                            icon: const Icon(
                              Icons.verified,
                              color: Colors.white,
                            ),

                            label: Text(

                              data['paymentStatus'] == 'verified'

                                  ? "PAYMENT VERIFIED"

                                  : "VERIFY PAYMENT",

                              style: const TextStyle(

                                color: Colors.white,

                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // ======================================================
                    // DELIVERY PIN
                    // ======================================================

                    if (
                    userRole == 'client' ||
                        userRole == 'admin'
                    )
                      Padding(

                        padding: const EdgeInsets.all(16),

                        child: Container(

                          width: double.infinity,

                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),

                          decoration: BoxDecoration(

                            color: Colors.blue.shade50,

                            borderRadius:
                            BorderRadius.circular(10),
                          ),

                          child: Column(

                            children: [

                              const Text(

                                "DELIVERY PIN",

                                style: TextStyle(

                                  fontWeight:
                                  FontWeight.bold,

                                  color: Colors.blue,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(

                                "${data['deliveryPin']}",

                                style: const TextStyle(

                                  fontSize: 22,

                                  fontWeight:
                                  FontWeight.bold,

                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ======================================================
                    // QR CODE
                    // ======================================================
                    if (userRole == 'admin')

                      Padding(

                        padding: const EdgeInsets.all(16),

                        child: Wrap(

                          spacing: 10,
                          runSpacing: 10,

                          children: [



                            // ACCEPT ORDER
                            if (data['status'] == OrderStatus.pending)

                              ElevatedButton.icon(

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),

                                onPressed: () {

                                  showModalBottomSheet(

                                    context: context,

                                    builder: (context) {

                                      return StreamBuilder<QuerySnapshot>(

                                        stream: FirebaseFirestore.instance
                                            .collection('users')
                                            .where(
                                          'role',
                                          isEqualTo:
                                          'restaurant_partner',
                                        )
                                            .where(
                                          'active',
                                          isEqualTo: true,
                                        )
                                            .snapshots(),

                                        builder: (context, snapshot) {

                                          if (!snapshot.hasData) {

                                            return const Center(
                                              child:
                                              CircularProgressIndicator(),
                                            );
                                          }

                                          final restaurants = snapshot.data!.docs;

                                          final orderItems =
                                          List<Map<String, dynamic>>.from(
                                            data['items'] ?? [],
                                          );

                                          final allowedRestaurantIds =
                                          orderItems
                                              .map(
                                                (e) => e['restaurantId']
                                                ?.toString() ??
                                                '',
                                          )
                                              .where(
                                                (id) => id.isNotEmpty,
                                          )
                                              .toSet();

                                          final eligibleRestaurants =
                                          restaurants.where((restaurant) {

                                            return allowedRestaurantIds
                                                .contains(
                                              restaurant.id,
                                            );

                                          }).toList();

                                          return ListView.builder(

                                            itemCount:
                                            eligibleRestaurants.length,

                                            itemBuilder:
                                                (context, index) {

                                                  final restaurant =
                                                  eligibleRestaurants[index];

                                              final restaurantData =
                                              restaurant.data()
                                              as Map<String, dynamic>;

                                              return ListTile(

                                                leading:
                                                const CircleAvatar(

                                                  child: Icon(
                                                    Icons.restaurant,
                                                  ),
                                                ),
                                                title: Text(
                                                  restaurantData['name'] ??
                                                      'Restaurant',
                                                ),

                                                subtitle: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [

                                                    Text(
                                                      restaurantData['phone'] ?? '',
                                                    ),

                                                    Text(
                                                      restaurant.id,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.green,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                trailing:
                                                ElevatedButton(

                                             onPressed: () async {

                                               await FirebaseFirestore.instance
                                                 .collection('orders')
                                                 .doc(orderId)
                                                 .update({

                                               'restaurantId':restaurant.id,

                                                 'restaurantName':
                                                 restaurantData['name'] ?? '',

                                                 'restaurantPhone':
                                                 restaurantData['phone'] ?? '',

                                                 'restaurantAddress':
                                                 restaurantData['address'] ?? '',

                                                 'restaurantLandmark':
                                                 restaurantData['landmark'] ?? '',

                                                 'restaurantLatitude':
                                                 restaurantData['latitude'],

                                                 'restaurantLongitude':
                                                 restaurantData['longitude'],

                                               'status'
                                               :OrderStatus.accepted,

                                               'assignedAt'
                                               :FieldValue.serverTimestamp(),
                                               'statusUpdatedAt':
                                                 FieldValue.serverTimestamp(),
                                              });
                                               await NotificationService().createNotification(

                                                 userId: restaurant.id,

                                                 title: 'New Order Assigned',

                                                 body: 'A new order has been assigned to your restaurant.',

                                                 type: 'order',
                                               );
                                                    if (!context.mounted) {
                                                      return;
                                                    }

                                                    Navigator.pop(
                                                      context,
                                                    );
                                                  },

                                                  child:
                                                  const Text(
                                                    'Assign',
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  );
                                },


                                icon: const Icon(
                                  Icons.store,
                                  color: Colors.white,
                                ),

                                label: const Text(

                                  "ASSIGN STORE",

                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                            // OUT FOR DELIVERY
                            if (data['status'] == OrderStatus.ready)

                              ElevatedButton.icon(

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),

                                onPressed: () {

                                  showModalBottomSheet(

                                    context: context,

                                    builder: (context) {

                                      return StreamBuilder<QuerySnapshot>(

                                        stream: FirebaseFirestore.instance
                                            .collection('users')

                                            .where(
                                          'role',
                                          isEqualTo:
                                          'delivery_partner',
                                        )

                                            .where(
                                          'active',
                                          isEqualTo: true,
                                        )
                                            .snapshots(),

                                        builder: (context, snapshot) {

                                          if (!snapshot.hasData) {

                                            return const Center(
                                              child:
                                              CircularProgressIndicator(),
                                            );
                                          }

                                          final riders =
                                              snapshot.data!.docs;

                                          return ListView.builder(

                                            itemCount: riders.length,

                                            itemBuilder: (context, index) {

                                              final rider =
                                              riders[index];

                                              final riderData =
                                              rider.data()
                                              as Map<String, dynamic>;

                                              return ListTile(

                                                leading: const CircleAvatar(
                                                  child: Icon(
                                                    Icons.delivery_dining,
                                                  ),
                                                ),

                                                title: Text(
                                                  riderData['name'] ?? '',
                                                ),

                                                subtitle: Text(
                                                  riderData['phone'] ?? '',
                                                ),

                                                trailing: ElevatedButton(

                                                  onPressed: () async {

                                                    await assignRider(

                                                      orderId: orderId,

                                                      riderId: rider.id,

                                                      riderName:
                                                      riderData['name'],

                                                      riderPhone:
                                                      riderData['phone'] ?? '',
                                                    );

                                                    if (!context.mounted) {
                                                      return;
                                                    }

                                                    Navigator.pop(context);
                                                  },

                                                  child:
                                                  const Text("Assign"),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  );
                                },

                                icon: const Icon(
                                  Icons.delivery_dining,
                                  color: Colors.white,
                                ),

                                label: const Text(

                                  "ASSIGN RIDER",

                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                             ),
                          ],
                        ),
                      ),
                    if (userRole == 'restaurant_partner')

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [

                            if (data['status'] == OrderStatus.accepted)

                              ElevatedButton.icon(

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),

                                onPressed: () async {

                                  await updateOrderStatus(
                                    orderId,
                                    OrderStatus.preparing,
                                  );
                                },

                                icon: const Icon(
                                  Icons.store,
                                  color: Colors.white,
                                ),

                                label: const Text(
                                  "START PREPARING",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            if (data['status'] == OrderStatus.accepted)

                              ElevatedButton.icon(

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),

                                onPressed: () async {

                                  final reasons = [

                                    'Out Of Stock',

                                    'Product Unavailable',

                                    'Restaurant Closed',

                                    'Delivery Area Not Serviceable',

                                    'Technical Issue',

                                    'Other',
                                  ];

                                  final selectedReason =
                                  await showDialog<String>(

                                    context: context,

                                    builder: (dialogContext) {

                                      return SimpleDialog(

                                        title: const Text(
                                          'Select Rejection Reason',
                                        ),

                                        children: reasons.map((reason) {

                                          return SimpleDialogOption(

                                            onPressed: () {

                                              Navigator.pop(
                                                dialogContext,
                                                reason,
                                              );
                                            },

                                            child: Text(reason),
                                          );

                                        }).toList(),
                                      );
                                    },
                                  );

                                  if (selectedReason == null) {
                                    return;
                                  }

                                  await FirebaseFirestore.instance
                                      .collection('orders')
                                      .doc(orderId)
                                      .update({

                                    'status': OrderStatus.rejected,

                                    'rejectionReason': selectedReason,

                                    'rejectedBy': 'restaurant_partner',

                                    'rejectedAt':
                                    FieldValue.serverTimestamp(),

                                    'statusUpdatedAt':
                                    FieldValue.serverTimestamp(),
                                  });

                                  await NotificationService().createNotification(
                                    userId: data['userId'],
                                    title: 'Order Rejected',
                                    body:
                                    'Restaurant could not process your order.',
                                    type: 'order',
                                  );

                                  final adminDocs =
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .where(
                                    'role',
                                    isEqualTo: 'admin',
                                  )
                                      .get();

                                  for (final admin in adminDocs.docs) {

                                    await NotificationService()
                                        .createNotification(

                                      userId: admin.id,

                                      title: 'Order Rejected',

                                      body:
                                      '${data['restaurantName'] ?? 'Restaurant'} rejected Order #$orderId',

                                      type: 'order',
                                    );
                                  }
                                },

                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),

                                label: const Text(
                                  'REJECT ORDER',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                            if (data['status'] == OrderStatus.preparing)

                              ElevatedButton.icon(

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                ),
                                onPressed: () async {

                                  await updateOrderStatus(
                                    orderId,
                                    OrderStatus.ready,
                                  );

                                  final adminDocs =
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .where('role', isEqualTo: 'admin')
                                      .get();

                                  for (final admin in adminDocs.docs) {

                                    await NotificationService().createNotification(

                                      userId: admin.id,

                                      title: 'Order Ready',

                                      body:
                                      '${data['restaurantName']} marked an order ready.',

                                      type: 'order',
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.done_all,
                                  color: Colors.white,
                                ),

                                label: const Text(
                                  "MARK READY",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    if (userRole == 'restaurant_partner' &&
                        data['returnRequested'] == true &&
                        data['returnStatus'] == 'PENDING') ...[

                      Padding(
                        padding: const EdgeInsets.all(16),

                        child: Container(

                          width: double.infinity,

                          padding: const EdgeInsets.all(16),

                          decoration: BoxDecoration(

                            color: Colors.orange.shade50,

                            borderRadius: BorderRadius.circular(12),

                            border: Border.all(
                              color: Colors.orange,
                            ),
                          ),

                          child: Column(

                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [

                              Text(

                                data['returnType'] == 'REPLACEMENT'
                                    ? "REPLACEMENT REQUEST"
                                    : "RETURN / REFUND REQUEST",

                                style: const TextStyle(

                                  fontWeight: FontWeight.bold,

                                  fontSize: 16,

                                  color: Colors.orange,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                "Type : ${data['returnType']}",
                              ),

                              Text(
                                "Reason : ${data['returnReason']}",
                              ),

                              Text(
                                "Condition : ${data['returnCondition']}",
                              ),

                              const SizedBox(height: 16),

                              Row(

                                children: [

                                  Expanded(

                                    child: ElevatedButton(

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),

                                      onPressed: () async {

                                        await FirebaseFirestore.instance
                                            .collection('orders')
                                            .doc(orderId)
                                            .update({

                                          'returnStatus': 'RESTAURANT_APPROVED',

                                          'restaurantReturnDecisionAt':
                                          FieldValue.serverTimestamp(),
                                        });

                                        // CUSTOMER
                                        await NotificationService().createNotification(

                                          userId: data['userId'],

                                          title:
                                          data['returnType'] == 'REPLACEMENT'
                                              ? 'Replacement Approved'
                                              : 'Return Approved',

                                          body:
                                          'Restaurant approved your request.',

                                          type: 'order',
                                        );

                                        // ADMIN
                                        final adminDocs = await FirebaseFirestore.instance
                                            .collection('users')
                                            .where('role', isEqualTo: 'admin')
                                            .get();

                                        for (final admin in adminDocs.docs) {

                                          await NotificationService().createNotification(

                                            userId: admin.id,

                                            title: 'Restaurant Approved Return',

                                            body:
                                            '${data['restaurantName']} approved ${data['returnType']}.',

                                            type: 'order',
                                          );
                                        }
                                      },

                                      child: const Text(
                                        'APPROVE',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(

                                    child: ElevatedButton(

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),

                                      onPressed: () async {

                                        await FirebaseFirestore.instance
                                            .collection('orders')
                                            .doc(orderId)
                                            .update({

                                          'returnStatus':
                                          'RESTAURANT_REJECTED',

                                          'restaurantReturnDecisionAt':
                                          FieldValue.serverTimestamp(),
                                        });

                                        await NotificationService()
                                            .createNotification(

                                          userId: data['userId'],

                                          title: 'Return Rejected',

                                          body:
                                          'Restaurant rejected your return request.',

                                          type: 'order',
                                        );
                                      },

                                      child: const Text(
                                        'REJECT',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    Padding(

                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),

                        child: Container(

                          width: double.infinity,

                          padding: const EdgeInsets.all(14),

                          decoration: BoxDecoration(

                            color: Colors.teal.shade50,

                            borderRadius:
                            BorderRadius.circular(10),

                            border: Border.all(
                              color: Colors.teal.shade200,
                            ),
                          ),

                          child: Column(

                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [
                              if (
                              userRole == 'admin' ||
                                  userRole == 'delivery_partner'
                              ) ...[
                               if (
                                  userRole == 'admin' &&
                                  (data['restaurantName'] == null ||
                                  data['restaurantName'].toString().isEmpty) &&
                                  (data['items'] as List).isNotEmpty
                                )

                            Container(

                            width: double.infinity,

                           margin: const EdgeInsets.only(
                            bottom: 12,
                            ),

                                   padding: const EdgeInsets.all(12),

                                  decoration: BoxDecoration(

                                  color: Colors.green.shade50,

                          borderRadius:
                          BorderRadius.circular(10),

                            border: Border.all(
                            color: Colors.green.shade300,
                             ),
                           ),

                          child: Column(

                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,

                            children: [

                            const Text(

                                        "ELIGIBLE RESTAURANT",

                                        style: TextStyle(
                                         fontWeight:
                                         FontWeight.bold,
                                          fontSize: 13,
                                      ),
                                    ),

                              const SizedBox(height: 6),

                            Text(

                            data['items'][0]
                          ['restaurantName'] ??
                                        '',

                                        style: const TextStyle(

                                    color: Colors.green,

                                fontWeight:
                                 FontWeight.bold,

                                 fontSize: 16,
                               ),
                            ),

                                   Text(

                                      data['items'][0]
                                    ['restaurantId'] ??
                                          '',

                                    style: const TextStyle(
                                     fontSize: 11,
                                  ),
                                 ),
                              ],
                            ),
                           ),

                                    const Text(
                                      "PICKUP DETAILS",
                                      style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  "Store: ${data['restaurantName'] ?? 'Not Assigned'}",
                                ),

                                Text(
                                  "Phone: ${data['restaurantPhone'] ?? 'N/A'}",
                                ),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Expanded(
                                      child: Text(
                                        "Address: ${data['restaurantAddress'] ?? 'N/A'}",
                                      ),
                                    ),

                                    IconButton(
                                      icon: const Icon(
                                        Icons.navigation,
                                        color: Colors.green,
                                      ),
                                      tooltip: 'Navigate to Restaurant',
                                      onPressed: () {
                                         if (data['restaurantLatitude'] != null &&
                                            data['restaurantLongitude'] != null) {

                                          openGoogleMapsByCoordinates(
                                            (data['restaurantLatitude'] as num)
                                                .toDouble(),
                                            (data['restaurantLongitude'] as num)
                                                .toDouble(),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),

                                Text(
                                  "Landmark: ${data['restaurantLandmark'] ?? 'N/A'}",
                                ),

                                const Divider(),

                              ],
                              const Text(

                                "CUSTOMER DETAILS",

                                style: TextStyle(

                                  fontWeight: FontWeight.bold,

                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "Customer: ${data['customerName'] ?? 'N/A'}",
                              ),

                              Text(
                                "Phone: ${data['customerPhone'] ?? 'N/A'}",
                              ),

                              if (userRole == 'admin' ||
                                  userRole == 'delivery_partner') ...[

                              const SizedBox(height: 6),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Expanded(
                                      child: Text(
                                        "Address: ${data['deliveryAddress'] ?? 'N/A'}",
                                        softWrap: true,
                                      ),
                                    ),

                                    if (data['customerLatitude'] != null &&
                                        data['customerLongitude'] != null)

                                      IconButton(
                                        icon: const Icon(
                                          Icons.navigation,
                                          color: Colors.blue,
                                        ),
                                        tooltip: 'Navigate',
                                        onPressed: () {

                                          openGoogleMapsByCoordinates(
                                            (data['customerLatitude'] as num)
                                                .toDouble(),
                                            (data['customerLongitude'] as num)
                                                .toDouble(),
                                          );
                                        },
                                      ),
                                  ],
                                ),

                              Text(
                                "Landmark: ${data['landmark'] ?? 'N/A'}",
                                softWrap: true,
                              ),

                              Text(
                                "Notes: ${data['deliveryNote'] ?? 'N/A'}",
                                softWrap: true,
                              ),
                              ],

                              const SizedBox(height: 12),
                            if (data['riderName'] != null) ...[

                              const Divider(),

                              const SizedBox(height: 12),

                              const Text(

                                "DELIVERY PARTNER",


                                style: TextStyle(

                                  fontWeight:
                                  FontWeight.bold,

                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "Name: ${data['riderName'] ?? 'Not Assigned'}",
                              ),

                              Text(
                                "Phone: ${data['riderPhone'] ?? 'N/A'}",
                              ),
                              const SizedBox(height: 10),

                              const Divider(),

                              const SizedBox(height: 10),
                           ],
                          ],
                          ),
                        ),
                      ),
                    if (userRole == 'delivery_partner' &&
                        data['status'] ==
                            OrderStatus.riderAssigned)

                      Padding(

                        padding: const EdgeInsets.all(16),

                        child: SizedBox(

                          width: double.infinity,

                          child: ElevatedButton.icon(

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),

                            onPressed: () async {

                              await updateOrderStatus(
                                orderId,
                                OrderStatus.pickedUp,
                              );

                              await NotificationService().createNotification(
                                userId: data['userId'],
                                title: 'Order Picked Up',
                                body: 'Your order has been picked up and will be delivered soon.',
                                type: 'delivery',
                              );

                                // ADMIN NOTIFICATION
                              final adminDocs = await FirebaseFirestore.instance
                                  .collection('users')
                                  .where('role', isEqualTo: 'admin')
                                  .get();

                              for (final admin in adminDocs.docs) {
                                await NotificationService().createNotification(
                                  userId: admin.id,
                                  title: 'Order Picked Up',
                                  body:
                                  '${data['customerName'] ?? 'Customer'} order has been picked up.',
                                  type: 'order',
                                );
                              }
                            },

                            icon: const Icon(
                              Icons.store,
                              color: Colors.white,
                            ),

                            label: const Text(

                              "ARRIVED FOR PICKUP",

                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (userRole == 'delivery_partner' &&
                        data['status'] ==
                            OrderStatus.pickedUp)

                      Padding(

                        padding: const EdgeInsets.all(16),

                        child: SizedBox(

                          width: double.infinity,

                          child: ElevatedButton.icon(

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                            ),

                            onPressed: () async {

                              await updateOrderStatus(
                                orderId,
                                OrderStatus.outForDelivery,
                              );

                              await NotificationService().createNotification(
                                userId: data['userId'],
                                title: 'Order Out For Delivery',
                                body: 'Your order is on the way.',
                                type: 'delivery',
                              );

                                // ADMIN NOTIFICATION
                              final adminDocs = await FirebaseFirestore.instance
                                  .collection('users')
                                  .where('role', isEqualTo: 'admin')
                                  .get();

                              for (final admin in adminDocs.docs) {
                                await NotificationService().createNotification(
                                  userId: admin.id,
                                  title: 'Order Out For Delivery',
                                  body:
                                  '${data['customerName'] ?? 'Customer'} order is now out for delivery.',
                                  type: 'order',
                                );
                              }
                            },

                            icon: const Icon(
                              Icons.delivery_dining,
                              color: Colors.white,
                            ),

                            label: const Text(

                              "START DELIVERY",

                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                    if (userRole == 'delivery_partner' &&
                        data['status'] ==
                            OrderStatus.outForDelivery)

                      Padding(

                        padding: const EdgeInsets.all(16),

                        child: SizedBox(

                          width: double.infinity,

                          child: ElevatedButton.icon(

                            style: ElevatedButton.styleFrom(

                              backgroundColor:
                              Colors.green,
                            ),

                            onPressed: () {

                              final pinController =
                              TextEditingController();
                              final messenger =
                              ScaffoldMessenger.of(context);

                              showDialog(

                                context: context,

                                builder: (dialogContext) {

                                  return AlertDialog(

                                    title: const Text(
                                      "Verify Delivery PIN",
                                    ),

                                    content: TextField(

                                      controller: pinController,

                                      autofocus: true,

                                      keyboardType: TextInputType.number,

                                      textInputAction: TextInputAction.done,

                                      onSubmitted: (_) async {
                                       if (pinController.text
                                            .trim() !=
                                            data['deliveryPin']
                                                .toString()) {

                                          messenger.showSnackBar(

                                            const SnackBar(

                                              backgroundColor:
                                              Colors.red,

                                              content: Text(
                                                "Invalid PIN",
                                              ),
                                            ),
                                          );

                                          return;
                                        }

                                       await completeDelivery(
                                         orderId,
                                         data,
                                       );

                                        if (dialogContext.mounted) {

                                          Navigator.pop(dialogContext);
                                        }

                                        messenger.showSnackBar(

                                          const SnackBar(

                                            backgroundColor: Colors.green,

                                            content: Text("Order Delivered"),
                                          ),
                                        );
                                      },

                                      decoration: const InputDecoration(

                                        hintText: "Enter Customer PIN",
                                      ),
                                    ),

                                    actions: [

                                      TextButton(

                                        onPressed: () {

                                          Navigator.pop(
                                            dialogContext,
                                          );
                                        },

                                        child: const Text(
                                          "Cancel",
                                        ),
                                      ),

                                      ElevatedButton(

                                        onPressed: () async {

                                          FocusScope.of(dialogContext)
                                              .unfocus();

                                           if (pinController.text
                                              .trim() !=
                                              data['deliveryPin']
                                                  .toString()) {

                                            messenger.showSnackBar(

                                              const SnackBar(

                                                backgroundColor:
                                                Colors.red,

                                                content: Text(
                                                  "Invalid PIN",
                                                ),
                                              ),
                                            );

                                            return;
                                          }

                                          await completeDelivery(
                                            orderId,
                                            data,
                                          );

                                          if (dialogContext.mounted) {

                                            Navigator.pop(dialogContext);
                                          }

                                          messenger.showSnackBar(

                                            const SnackBar(

                                              backgroundColor:
                                              Colors.green,

                                              content: Text(
                                                "Order Delivered",
                                              ),
                                            ),
                                          );
                                        },

                                        child: const Text(
                                          "VERIFY",
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },

                            icon: const Icon(
                              Icons.lock_open,
                              color: Colors.white,
                            ),

                            label: const Text(

                              "VERIFY DELIVERY PIN",

                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Text(
                      "STATUS: ${data['status']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),



                      child: Text(

                        "ORDER ITEMS",

                        style: TextStyle(

                          fontWeight: FontWeight.bold,

                          fontSize: 13,
                        ),
                      ),
                    ),


                    if (
                    userRole == 'client' &&
                        (
                            // FOOD
                            (
                                data['serviceType'] == 'Regular' &&
                                    (
                                        data['status'] == OrderStatus.pending ||

                                            (
                                                data['status'] == OrderStatus.accepted &&
                                                    data['assignedAt'] != null &&
                                                    DateTime.now().difference(
                                                      (data['assignedAt'] as Timestamp).toDate(),
                                                    ).inMinutes < 2
                                            )
                                    )
                            )

                                ||

                                // MARKETPLACE
                                (
                                    data['serviceType'] == 'Marketplace Product' &&
                                        (
                                            data['status'] == OrderStatus.pending ||
                                                data['status'] == OrderStatus.accepted ||
                                                data['status'] == OrderStatus.preparing
                                        )
                                )

                                ||

                                // WEEKLY TIFFIN
                                (
                                    data['serviceType'] == 'Weekly Tiffin' &&
                                        (
                                            data['status'] == OrderStatus.pending ||
                                                data['status'] == OrderStatus.accepted
                                        )
                                )

                                ||

                                // MONTHLY TIFFIN
                                (
                                    data['serviceType'] == 'Monthly Tiffin' &&
                                        (
                                            data['status'] == OrderStatus.pending ||
                                                data['status'] == OrderStatus.accepted
                                        )
                                )
                        )
                    )

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),

                            onPressed: () async {

                              final confirm =
                              await showDialog<bool>(

                                context: context,

                                builder: (dialogContext) => AlertDialog(

                                  title: const Text(
                                    'Cancel Order?',
                                  ),

                                  content: const Text(
                                    'Are you sure you want to cancel this order?',
                                  ),

                                  actions: [

                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, false),
                                      child: const Text('No'),
                                    ),

                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, true),
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm != true) return;

                              await FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(orderId)
                                  .update({

                                'status': 'CANCELLED',

                                'rejectedBy': 'customer',

                                'rejectionReason':
                                'Cancelled by Customer',

                                'rejectedAt':
                                FieldValue.serverTimestamp(),

                                'statusUpdatedAt':
                                FieldValue.serverTimestamp(),
                              });

                              final restaurantId =
                              data['restaurantId'];

                              if (restaurantId != null &&
                                  restaurantId.toString().isNotEmpty) {

                                await NotificationService()
                                    .createNotification(

                                  userId: restaurantId,

                                  title: 'Order Cancelled',

                                  body: 'Customer cancelled the order.',

                                  type: 'order',
                                );
                              }
                            },

                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.white,
                            ),

                            label: const Text(
                              'CANCEL ORDER',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                    if (
                    userRole == 'client' &&
                        data['serviceType'] == 'Marketplace Product' &&
                        data['status'] == OrderStatus.delivered &&
                        (data['returnRequested'] != true)
                    )
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                            ),
                            icon: const Icon(
                              Icons.assignment_return,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "RETURN / REFUND",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () async {

                              final reasons = [

                                'Damaged Product',

                                'Wrong Product',

                                'Missing Item',

                                'Quality Issue',

                                'Expired Product',

                                'Other',

                              ];

                              final selectedReason =
                              await showDialog<String>(

                                context: context,

                                builder: (dialogContext) {

                                  return SimpleDialog(

                                    title: const Text(
                                      'Select Return Reason',
                                    ),

                                    children: reasons.map((reason) {

                                      return SimpleDialogOption(

                                        onPressed: () {

                                          Navigator.pop(
                                            dialogContext,
                                            reason,
                                          );

                                        },

                                        child: Text(reason),
                                      );

                                    }).toList(),
                                  );

                                },

                              );

                              if (selectedReason == null) return;

                              final returnType =
                              data['returnPolicy'] == 'Replacement Only'
                                  ? 'REPLACEMENT'
                                  : 'REFUND';

                              await FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(orderId)
                                  .update({

                                'returnRequested': true,

                                'returnRequestedAt': FieldValue.serverTimestamp(),

                                'returnReason': selectedReason,

                                'returnType': returnType,

                                'returnStatus': 'PENDING',

                              });
                              // Notify Restaurant
                              if (data['restaurantId'] != null &&
                                  data['restaurantId'].toString().isNotEmpty) {

                                await NotificationService().createNotification(

                                  userId: data['restaurantId'],

                                  title: data['returnType'] == 'REPLACEMENT'
                                      ? 'Replacement Request'
                                      : 'Return Request',

                                  body:
                                  '${data['customerName']} submitted a ${data['returnType']?.toLowerCase()} request.',

                                  type: 'order',
                                );
                              }

                              // Notify Admin
                              final adminDocs = await FirebaseFirestore.instance
                                  .collection('users')
                                  .where('role', isEqualTo: 'admin')
                                  .get();

                              for (final admin in adminDocs.docs) {

                                await NotificationService().createNotification(

                                  userId: admin.id,

                                  title: 'New Return Request',

                                  body:
                                  '${data['customerName']} submitted a ${data['returnType']?.toLowerCase()} request.',

                                  type: 'order',
                                );
                              }

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(

                                const SnackBar(

                                  content: Text(
                                    'Return request submitted.',
                                  ),

                                ),

                              );
                            },
                          ),
                        ),
                      ),

                    // ======================================================
                    // ORDER ITEMS
                    // ======================================================

                    ...(data['items'] as List).map(

                          (item) => Card(

                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),

                        child: ListTile(

                          leading: const Icon(
                            Icons.fastfood,
                            color: Colors.orange,
                          ),

                          title: Text(

                            item['name'] ?? '',

                            style: const TextStyle(

                              fontWeight: FontWeight.bold,

                              fontSize: 14,
                            ),
                          ),

                          subtitle: Text(
                            "₹${item['price']} each",
                          ),

                          trailing: Container(

                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),

                            decoration: BoxDecoration(

                              color: Colors.orange.shade100,

                              borderRadius:
                              BorderRadius.circular(8),
                            ),

                            child: Text(

                              "x${item['quantity']}",

                              style: const TextStyle(

                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    ),
  ],
 ),
    );
  }
}