import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'food_services.dart';
import 'order_status.dart';
import '../../features/food/sheets/payment_method_sheet.dart';
import '../../features/food/sheets/online_payment_sheet.dart';
import '../../features/food/sheets/cart_bottom_sheet.dart';
import '../../features/food/services/order_service.dart';
import '../../features/profile/guards/profile_guard.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}



class _FoodPageState extends State<FoodPage>
    with SingleTickerProviderStateMixin {
  String foodFilter = 'All';
  String selectedRestaurant =
      'All Restaurants';

  final OrderService
  _orderService =
   OrderService();
  bool _isOrderLoading = false;
  bool useDefaultAddress = true;
  String searchQuery = '';

  late TabController _tabController;

  final TextEditingController addressController =
  TextEditingController();

  final TextEditingController pincodeController =
  TextEditingController();


  final TextEditingController landmarkController =
  TextEditingController();

  final TextEditingController noteController =
  TextEditingController();
  final TextEditingController phoneController =
  TextEditingController();
  final TextEditingController transactionController =
  TextEditingController();

  Future<void> _loadDefaultAddress() async {

    try {

      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final doc =
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid)
          .get();

      if (!doc.exists) return;

      final data =
          doc.data() ?? {};

      if (phoneController.text.isEmpty) {

        phoneController.text =
            data['phone'] ?? '';
      }

      if (addressController.text.isEmpty) {

        addressController.text =
            data['address'] ?? '';
      }

      if (landmarkController.text.isEmpty) {

        landmarkController.text =
            data['landmark'] ?? '';
      }

      if (pincodeController.text.isEmpty) {

        pincodeController.text =
            data['pincode'] ?? '';
      }

    } catch (e) {

      debugPrint(
        'Profile Autofill Error: $e',
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _tabController =
        TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    addressController.dispose();
    phoneController.dispose();
    pincodeController.dispose();
    landmarkController.dispose();
    noteController.dispose();
    transactionController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        elevation: 0,

        backgroundColor: Colors.white,
        foregroundColor: Colors.black,

        title: const Text(

          "Food & Dining",

          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [

          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Search Food'),
                    content: TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter food name',
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            searchQuery = '';
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Clear'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Search'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.search),
          ),
          Consumer<FoodService>(

            builder: (context, cart, child) => Badge(

              label: Text(
                cart.totalItems.toString(),
              ),

              isLabelVisible:
              cart.totalItems > 0,

              child: IconButton(

                onPressed: () =>
                    _showCartSheet(
                      context,
                      cart,
                    ),

                icon: const Icon(
                  Icons.shopping_cart_outlined,
                ),
              ),
            ),
          ),
        ],

        bottom: TabBar(

          controller: _tabController,

          labelColor: Colors.orange,
          unselectedLabelColor: Colors.grey,

          indicatorColor: Colors.orange,

          tabs: const [

            Tab(text: "🍽 Regular Food"),
            Tab(text: "📅 Weekly Tiffin"),
            Tab(text: "🗓 Monthly Tiffin"),
          ],
        ),
      ),

        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('food_menu')
                    .where(
                  'available',
                  isEqualTo: true,
                )
                    .where(
                  'restaurantActive',
                  isEqualTo: true,
                )
                    .snapshots(),
                builder: (context, snapshot) {

                  final restaurants = <String>{
                    'All Restaurants'
                  };

                  if (snapshot.hasData) {
                    for (final doc in snapshot.data!.docs) {
                      final data =
                      doc.data() as Map<String, dynamic>;

                      final restaurantName =
                      data['restaurantName'];

                      if (restaurantName != null &&
                          restaurantName
                              .toString()
                              .trim()
                              .isNotEmpty) {
                        restaurants.add(
                          restaurantName,
                        );
                      }
                    }
                  }

                  return DropdownButtonFormField<String>(

                    initialValue: selectedRestaurant,

                    decoration: InputDecoration(

                      labelText: 'Restaurant',

                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),

                    items: restaurants
                        .map(
                          (restaurant) =>
                          DropdownMenuItem(
                            value: restaurant,
                            child: Text(
                              restaurant,
                            ),
                          ),
                    )
                        .toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedRestaurant =
                            value ??
                                'All Restaurants';
                      });
                    },
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [

                    ChoiceChip(
                      label: const Text('All'),
                      selected: foodFilter == 'All',
                      onSelected: (_) {
                        setState(() {
                          foodFilter = 'All';
                        });
                      },
                    ),

                    const SizedBox(width: 8),

                    ChoiceChip(
                      label: const Text('Veg'),
                      selected: foodFilter == 'Veg',
                      onSelected: (_) {
                        setState(() {
                          foodFilter = 'Veg';
                        });
                      },
                    ),

                    const SizedBox(width: 8),

                    ChoiceChip(
                      label: const Text('Non Veg'),
                      selected: foodFilter == 'Non Veg',
                      onSelected: (_) {
                        setState(() {
                          foodFilter = 'Non Veg';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMenuGrid("Regular"),
                  _buildMenuGrid("Weekly Tiffin"),
                  _buildMenuGrid("Monthly Tiffin"),
                ],
              ),
            ),
          ],
        ),
    );
  }


  Widget _buildMenuGrid(String serviceType) {
    Padding(
      padding: const EdgeInsets.all(12),

      child: Row(
        children: [

          ChoiceChip(
            label: const Text('All'),
            selected: foodFilter == 'All',
            onSelected: (_) {
              setState(() {
                foodFilter = 'All';
              });
            },
          ),

          const SizedBox(width: 10),

          ChoiceChip(
            label: const Text('Veg'),
            selected: foodFilter == 'Veg',
            onSelected: (_) {
              setState(() {
                foodFilter = 'Veg';
              });
            },
          ),

          const SizedBox(width: 10),

          ChoiceChip(
            label: const Text('Non Veg'),
            selected: foodFilter == 'Non Veg',
            onSelected: (_) {
              setState(() {
                foodFilter = 'Non Veg';
              });
            },
          ),
        ],
      ),
    );

    return StreamBuilder<QuerySnapshot>(



      stream: FirebaseFirestore.instance
          .collection('food_menu')
          .where(
        'serviceType',
        isEqualTo: serviceType,
      )
          .where(
        'available',
        isEqualTo: true,
      )
          .where(
        'restaurantActive',
        isEqualTo: true,
      )
          .snapshots(),

      builder: (context, snapshot) {

        if (snapshot.connectionState ==
            ConnectionState.waiting) {

          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {

          return const Center(

            child: Text(
              "No items available in this category.",
            ),
          );
        }

        final menuItems = snapshot.data!.docs.where((doc) {

          final data =
          doc.data() as Map<String, dynamic>;

          final name =
          (data['name'] ?? '')
              .toString()
              .toLowerCase();

          final foodType =
          (data['foodType'] ?? '')
              .toString();

          final matchesSearch =
              searchQuery.isEmpty ||
                  name.contains(searchQuery);

          final matchesFoodType =
              foodFilter == 'All' ||
                  foodType == foodFilter;
          final restaurantName =
          (data['restaurantName'] ?? '')
              .toString();

          final matchesRestaurant =
              selectedRestaurant ==
                  'All Restaurants' ||
                  restaurantName ==
                      selectedRestaurant;

          return matchesSearch &&
              matchesFoodType &&
              matchesRestaurant;

        }).toList();

        return LayoutBuilder(

          builder: (context, constraints) {

            int crossAxisCount;

            if (constraints.maxWidth < 600) {
              crossAxisCount = 1;
            } else if (constraints.maxWidth < 900) {
              crossAxisCount = 2;
            } else if (constraints.maxWidth < 1200) {
              crossAxisCount = 3;
            } else {
              crossAxisCount = 4;
            }

            return Center(

              child: ConstrainedBox(

                constraints:
                const BoxConstraints(
                  maxWidth: 1400,
                ),

                child: GridView.builder(

                  padding:
                  const EdgeInsets.all(20),

                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(

                    crossAxisCount:
                    crossAxisCount,

                    childAspectRatio:
                    constraints.maxWidth < 600
                        ? 0.65
                        : constraints.maxWidth < 900
                        ? 0.72
                        : 0.85,

                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),

                  itemCount: menuItems.length,

                  itemBuilder: (context, index) {

                    var data =
                    menuItems[index].data()
                    as Map<String, dynamic>;

                    return _buildFoodCard(
                      menuItems[index].id,
                      data['name'] ?? "Unknown",
                      data['price']?.toString() ?? "0",
                      data['image'] ?? "",
                      data['description'] ?? "",
                      data['restaurantName'] ?? "Restaurant",
                      data['restaurantId'] ?? "",
                      data['discountPercent'] ?? 0,
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFoodCard(
      String id,
      String name,
      String price,
      String imageUrl,
      String description,
      String restaurantName,
      String restaurantId,
      int itemDiscountPercent,
      )
  {

    return StreamBuilder<QuerySnapshot>(

      stream: FirebaseFirestore.instance
          .collection('restaurant_offers')
          .where(
        'restaurantId',
        isEqualTo: restaurantId,
      )
          .where(
        'active',
        isEqualTo: true,
      )
          .limit(1)
          .snapshots(),

      builder: (context, offerSnapshot) {

        String offerTitle = '';
        int discountPercent = 0;

        if (offerSnapshot.hasData &&
            offerSnapshot.data!.docs.isNotEmpty) {

          final offerData =
          offerSnapshot.data!.docs.first.data()
          as Map<String, dynamic>;

          offerTitle =
              offerData['title'] ?? '';

          discountPercent =
              offerData['discountPercent'] ?? 0;
        }
        final menuPrice =
            double.tryParse(price) ?? 0;
        int actualDiscount = 0;

        if (itemDiscountPercent > 0) {

          actualDiscount =
              itemDiscountPercent;

        } else if (discountPercent > 0) {

          actualDiscount =
              discountPercent;
        }

        final finalPrice =
            menuPrice -
                (menuPrice *
                    actualDiscount /
                    100);

        return Consumer<FoodService>(


      builder: (context, cart, child) {

        final cartItem =
        cart.items[id];

        final bool isInCart =
            cartItem != null;

        return Card(

          elevation: 3,

          clipBehavior: Clip.antiAlias,

          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(12),
          ),

          child: Column(

            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Stack(
                  children: [

                    SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: Image(
                        image: imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : const AssetImage(
                          'assets/images/iserveu_default.png',
                        ) as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),

                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius:
                          BorderRadius.circular(6),
                        ),
                        child: Text(
                          actualDiscount > 0
                              ? "$actualDiscount% OFF"
                              : "SPECIAL",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(

                padding:
                const EdgeInsets.all(8.0),

                child: Column(

                  mainAxisSize:
                  MainAxisSize.min,

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      restaurantName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0A2540),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (offerTitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 4,
                        ),
                        child: Text(
                          "🔥 $offerTitle",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),

                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        if (actualDiscount > 0)
                          Text(
                            "₹${menuPrice.toInt()}",
                            style: const TextStyle(
                              color: Colors.grey,
                              decoration:
                              TextDecoration.lineThrough,
                            ),
                          ),

                        Text(
                          "₹${finalPrice.toInt()}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight:
                            FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),

                        if (actualDiscount > 0)
                          Text(
                            "$actualDiscount% OFF",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    SizedBox(

                      width: double.infinity,
                      height: 32,

                      child: isInCart

                          ? Container(

                        decoration:
                        BoxDecoration(

                          color: Colors
                              .orange
                              .shade50,

                          borderRadius:
                          BorderRadius
                              .circular(
                              8),

                          border: Border.all(
                            color:
                            Colors.orange,
                            width: 1,
                          ),
                        ),

                        child: Row(

                          mainAxisAlignment:
                          MainAxisAlignment
                              .spaceEvenly,

                          children: [

                            IconButton(

                              padding:
                              EdgeInsets.zero,

                              icon: const Icon(
                                Icons.remove,
                                size: 18,
                                color:
                                Colors.orange,
                              ),

                              onPressed: () =>
                                  cart.decrementQuantity(
                                      id),
                            ),

                            Text(

                              "${cartItem.quantity}",

                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight
                                    .bold,

                                color: Colors
                                    .black87,
                              ),
                            ),

                            IconButton(

                              padding:
                              EdgeInsets.zero,

                              icon: const Icon(
                                Icons.add,
                                size: 18,
                                color:
                                Colors.orange,
                              ),

                              onPressed: () =>
                                  cart.addToCart(
                                    id,
                                    name,
                                    finalPrice,
                                    restaurantId,
                                    restaurantName,
                                  ),
                            ),
                          ],
                        ),
                      )

                          : ElevatedButton(

                        onPressed: () {
                          if (cart.items.isNotEmpty) {
                            final existingRestaurantId =
                                cart.items.values.first.restaurantId;

                            if (existingRestaurantId != restaurantId) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                    'You can order from only one restaurant at a time. Please clear your cart first.',
                                  ),
                                ),
                              );
                              return;
                            }
                          }

                          cart.addToCart(
                            id,
                            name,
                            finalPrice,
                            restaurantId,
                            restaurantName,
                          );
                        },

                        style:
                        ElevatedButton
                            .styleFrom(

                          backgroundColor:
                          const Color(
                              0xFF0A2540),

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                                8),
                          ),

                          padding:
                          EdgeInsets.zero,
                        ),

                        child: const Text(

                          "Add",

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
        );
      },
    );
  }

  void _showCartSheet(
      BuildContext context,
      FoodService cart,
      ) {

    final cartSheetContext = context;
    _loadDefaultAddress();

    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (context) => Consumer<FoodService>(

        builder: (context, cart, child) => Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            CartBottomSheet(

              cart: cart,

              cartSheetContext:
              cartSheetContext,

              phoneController:
              phoneController,

              pincodeController:
              pincodeController,

              addressController:
              addressController,

              landmarkController:
              landmarkController,

              noteController:
              noteController,
            ),

            Padding(

              padding:
              const EdgeInsets.symmetric(
                horizontal: 24,
              ),

              child: SizedBox(

                width: double.infinity,
                height: 55,

                child: ElevatedButton(

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    const Color(0xFFFF6A00),

                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                  ),

                  onPressed:
                  cart.items.isEmpty
                      ? null
                      : () async {
                    final profileReady =
                    await ProfileGuard
                        .checkProfileCompletion(
                      context,
                    );

                    if (!profileReady) {
                      return;
                    }
                    if (!context.mounted) return;

                    if (phoneController.text
                        .trim()
                        .length < 10) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context)
                          .showSnackBar(

                        const SnackBar(

                          content: Text(
                            "Please enter valid contact number",
                          ),
                        ),
                      );

                      return;
                    }

                    if (addressController.text
                        .trim()
                        .isEmpty) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context)
                          .showSnackBar(

                        const SnackBar(

                          content: Text(
                            "Please enter delivery address",
                          ),
                        ),
                      );

                      return;
                    }

                    final allowedPincodes = [

                      '814133',
                    ];

                    final enteredPin =
                    pincodeController.text
                        .trim();

                    bool isServiceable =
                    allowedPincodes.any(
                          (pin) => pin == enteredPin,
                    );

                    if (!isServiceable) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context)
                          .showSnackBar(

                        const SnackBar(

                          backgroundColor:
                          Colors.red,

                          content: Text(

                            'Currently delivery is available only in Godda service area.',
                          ),
                        ),
                      );

                      return;
                    }
                    final pricingDoc =
                    await FirebaseFirestore.instance
                        .collection('admin_settings')
                        .doc('pricing')
                        .get();
                    if (!context.mounted) return;

                    final pricingData =
                        pricingDoc.data() ?? {};

                    final minimumOrderAmount =
                    (pricingData['minimumOrderAmount'] ?? 99)
                        .toDouble();

                    if (cart.totalAmount < minimumOrderAmount) {

                      if (!context.mounted) return;

                      final remaining =
                          minimumOrderAmount -
                              cart.totalAmount;

                      ScaffoldMessenger.of(context)
                          .showSnackBar(

                        SnackBar(

                          backgroundColor: Colors.orange,

                          content: Text(
                            'Minimum order is ₹${minimumOrderAmount.toInt()}. Add ₹${remaining.toInt()} more.',
                          ),
                        ),
                      );

                      return;
                    }

                    showModalBottomSheet(


                      context: context,

                      backgroundColor:
                      Colors.white,

                      shape:
                      const RoundedRectangleBorder(

                        borderRadius:
                        BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),

                      builder: (context) {

                        return PaymentMethodSheet(

                          onOnlinePayment: () async {

                            final parentContext =
                                this.context;

                            Navigator.pop(context);

                            await Future.delayed(

                              const Duration(
                                milliseconds: 300,
                              ),
                            );

                            if (!parentContext.mounted) {
                              return;
                            }

                            _showOnlinePaymentSheet(

                              parentContext,

                              cartSheetContext,

                              cart,
                            );
                          },

                          onCashOnDelivery: () async {

                            Navigator.pop(context);

                            Navigator.pop(
                              cartSheetContext,
                            );

                            await _placeOrder(

                              this.context,

                              cart,

                              paymentMethod: 'COD',

                              paymentStatus:
                              PaymentStatus.unpaid,
                            );
                          },
                        );
                      },
                    );
                  },

                  child: const Text(

                    "PLACE ORDER NOW",

                    style: TextStyle(

                      color: Colors.white,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  Future<void> _placeOrder(

      BuildContext context,
      FoodService cart, {



        required String paymentMethod,
        required String paymentStatus,

        String transactionId = '',
      }) async {

    if (_isOrderLoading) return;

    _isOrderLoading = true;

    try {

      await _orderService.placeOrder(

        items:
        cart.items.values.map((item) {

          return {

            'foodId': item.id,

            'name': item.name,

            'price': item.price,

            'quantity': item.quantity,

            'restaurantId': item.restaurantId,

            'restaurantName': item.restaurantName,
          };
        }).toList(),

        totalAmount:
        cart.totalAmount,

        paymentMethod:
        paymentMethod,

        paymentStatus:
        paymentStatus,

        transactionId:
        transactionId,

        customerPhone:
        phoneController.text.trim(),

        deliveryAddress:
        addressController.text.trim(),

        landmark:
        landmarkController.text.trim(),

        deliveryNote:
        noteController.text.trim(),

        pincode:
        pincodeController.text.trim(),
      );

      cart.clearCart();

      if (!context.mounted) {
        return;
      }

      noteController.clear();
      transactionController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          backgroundColor: Colors.green,

          content: Text(
            "Order Placed Successfully!",
          ),
        ),
      );
// REFRESH UI
      if (mounted) {
        setState(() {});
      }

// SUCCESS


    } catch (e) {

      debugPrint(
        "Order Error: $e",
      );

    } finally {

      _isOrderLoading = false;
    }
  }
  void _showOnlinePaymentSheet(

      BuildContext context,
      BuildContext cartSheetContext,
      FoodService cart,
      ) {

    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.white,

      shape: const RoundedRectangleBorder(

        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),

      builder: (context) {

        return StreamBuilder<DocumentSnapshot>(

          stream: FirebaseFirestore
              .instance
              .collection('app_settings')
              .doc('payment')
              .snapshots(),

          builder: (context, snapshot) {

            final data =
            snapshot.data?.data()
            as Map<String, dynamic>?;

            final upiId =
                data?['upiId'] ?? '';

            final merchant =
                data?['merchantName'] ?? '';

            final qrUrl =
                data?['qrImage'] ?? '';


            return OnlinePaymentSheet(

              qrUrl: qrUrl,

              merchant: merchant,

              upiId: upiId,

              transactionController:
              transactionController,

              onPaymentSubmit: () async {

                if (transactionController.text
                    .trim()
                    .isEmpty) {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(

                    const SnackBar(

                      backgroundColor:
                      Colors.red,

                      content: Text(

                        "Please enter Transaction ID / UTR Number",
                      ),
                    ),
                  );

                  return;
                }

                Navigator.pop(context);

                Navigator.pop(
                  cartSheetContext,
                );

                await _placeOrder(

                  this.context,

                  cart,

                  paymentMethod:
                  'ONLINE',

                  paymentStatus:
                  PaymentStatus.submitted,

                  transactionId:
                  transactionController.text
                      .trim(),
                );
              },
            );
          },
        );
      },
    );
  }
}