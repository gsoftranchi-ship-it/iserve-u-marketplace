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
import 'package:geolocator/geolocator.dart';


class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}



class _FoodPageState extends State<FoodPage>
    with SingleTickerProviderStateMixin {
  String foodFilter = 'All';
  String tiffinType = 'Weekly';
  String marketplaceCategoryFilter = 'All';
  String selectedRestaurant =
      'All Providers';

  final OrderService
  _orderService =
  OrderService();
  bool _isOrderLoading = false;
  bool useDefaultAddress = true;
  String searchQuery = '';
  double? customerLatitude;
  double? customerLongitude;

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

      bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        debugPrint('Location service disabled');
        return;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission ==
          LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        debugPrint('Location permission denied');
        return;
      }

      Position position =
      await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      customerLatitude = position.latitude;
      customerLongitude = position.longitude;

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
    _loadDefaultAddress();

    _tabController.addListener(() {

      if (!_tabController.indexIsChanging) return;

      setState(() {});

      // Food
      if (_tabController.index == 0) {

        if (foodFilter == 'Product') {
          foodFilter = 'All';
        }
      }

      // Tiffin
      else if (_tabController.index == 1) {

        foodFilter = 'All';
      }

      // Marketplace
      else if (_tabController.index == 2) {

        foodFilter = 'Product';
      }
    });
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

          "Store & Dining",

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

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF001F5B),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              labelPadding: EdgeInsets.zero,

              labelColor: Color(0xFFFF6A00),
              unselectedLabelColor:Colors.grey.shade300,

              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),

              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: Color(0xFFFF6A00),
                  width: 4,
                ),
                insets: EdgeInsets.symmetric(
                  horizontal: 16,
                ),
              ),
              indicatorWeight: 3,

              tabs: [
                Tab(text: "Food"),

                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      Text("Tiffin"),

                      SizedBox(width: 4),

                      Icon(
                        Icons.arrow_drop_down,
                        size: 16,
                      ),
                    ],
                  ),
                ),
                Tab(text: "Marketplace"),
              ],
            ),
          ),
        ),
      ),

      body: Column(
        children: [

          const SizedBox(height: 8),

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
                  'All Providers'
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

                    labelText: 'Seller',

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
                              'All Providers';
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
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
                    selectedColor: const Color(0xFFE8F1FF),
                    checkmarkColor: const Color(0xFF0A2540),

                    label: const Text(
                      'All',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: foodFilter == 'All',
                    onSelected: (_) {
                      setState(() {
                        foodFilter = 'All';
                      });
                    },
                  ),

                  if (_tabController.index != 2) ...[
                    const SizedBox(width: 4),

                    ChoiceChip(
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                      selectedColor: const Color(0xFFE8F1FF),
                      checkmarkColor: const Color(0xFF0A2540),

                      label: const Text(
                        'Veg',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selected: foodFilter == 'Veg',
                      onSelected: (_) {
                        setState(() {
                          foodFilter = 'Veg';
                        });
                      },
                    ),

                    const SizedBox(width: 4),

                    ChoiceChip(
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                      selectedColor: const Color(0xFFE8F1FF),
                      checkmarkColor: const Color(0xFF0A2540),

                      label: const Text(
                        'Non Veg',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selected: foodFilter == 'Non Veg',
                      onSelected: (_) {
                        setState(() {
                          foodFilter = 'Non Veg';
                        });
                      },
                    ),
                  ],
                  if (_tabController.index == 2)

                    SizedBox(
                      width: MediaQuery.of(context).size.width < 600
                          ? 215
                          : 260,

                      child: StreamBuilder<QuerySnapshot>(

                        stream: FirebaseFirestore.instance
                            .collection('food_menu')
                            .where(
                          'serviceType',
                          isEqualTo: 'Marketplace Product',
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

                          if (!snapshot.hasData) {
                            return const SizedBox();
                          }

                          final categories = <String>{'All'};

                          for (final doc in snapshot.data!.docs) {

                            final data =
                            doc.data() as Map<String, dynamic>;

                            final category =
                            (data['category'] ?? '')
                                .toString()
                                .trim();

                            if (category.isNotEmpty) {
                              categories.add(category);
                            }
                          }

                          return DropdownButtonFormField<String>(

                            initialValue: marketplaceCategoryFilter,

                            decoration: InputDecoration(
                              hintText: 'All Categories',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              isDense: true,
                            ),

                            items: categories.map((category) {

                              return DropdownMenuItem<String>(

                                value: category,

                                child: Text(
                                  category == 'All'
                                      ? 'All Categories'
                                      : category,
                                ),
                              );

                            }).toList(),

                            onChanged: (value) {

                              setState(() {

                                marketplaceCategoryFilter =
                                    value ?? 'All';
                              });
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_tabController.index == 1)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  children: [

                    ChoiceChip(
                      label: Text(
                        "Weekly Plan",
                        style: TextStyle(
                          color: tiffinType == 'Weekly'
                              ? Colors.white
                              : const Color(0xFF001F5B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      selected: tiffinType == 'Weekly',

                      selectedColor: const Color(0xFFFF6A00),
                      backgroundColor: Colors.white,

                      onSelected: (_) {
                        setState(() {
                          tiffinType = 'Weekly';
                        });
                      },
                    ),

                    ChoiceChip(
                      label: Text(
                        "Monthly Plan",
                        style: TextStyle(
                          color: tiffinType == 'Monthly'
                              ? Colors.white
                              : const Color(0xFF001F5B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      selected: tiffinType == 'Monthly',

                      selectedColor: const Color(0xFFFF6A00),
                      backgroundColor: Colors.white,

                      onSelected: (_) {
                        setState(() {
                          tiffinType = 'Monthly';
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

                _buildMenuGrid(
                  tiffinType == 'Weekly'
                      ? "Weekly Tiffin"
                      : "Monthly Tiffin",
                ),

                _buildMenuGrid("Marketplace Product"),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMenuGrid(String serviceType) {

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
          final category =
          (data['category'] ?? '')
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
                  'All Providers' ||
                  restaurantName ==
                      selectedRestaurant;
          final matchesMarketplaceCategory =

              serviceType !=
                  "Marketplace Product" ||

                  marketplaceCategoryFilter ==
                      'All' ||

                  category ==
                      marketplaceCategoryFilter;



          return matchesSearch &&
              matchesFoodType &&
              matchesRestaurant &&
              matchesMarketplaceCategory;

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
                        ? 0.55
                        : 0.70,

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
                      data['image2'] ?? "",
                      data['image3'] ?? "",
                      data['description'] ?? "",
                      data['restaurantName'] ?? "Restaurant",
                      data['restaurantId'] ?? "",
                      data['discountPercent'] ?? 0,
                      data['deliveryTime'] ?? '',
                      serviceType,
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
      String imageUrl2,
      String imageUrl3,
      String description,
      String restaurantName,
      String restaurantId,
      int itemDiscountPercent,
      String deliveryTime,
      String serviceType,
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
        final images = [
          imageUrl,
          imageUrl2,
          imageUrl3,
        ].where((e) => e.isNotEmpty).toList();


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
                          height: MediaQuery.of(context).size.width < 600
                              ? 220
                              : 270,
                          width: double.infinity,

                          child: PageView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: images.isEmpty ? 1 : images.length,


                            itemBuilder: (context, index) {

                              if (images.isEmpty) {
                                return Image.asset(
                                  'assets/images/iserveu_default.png',
                                  fit: BoxFit.cover,
                                );
                              }

                              return GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) {

                                      final pageController = PageController(
                                        initialPage: index,
                                      );

                                      return Dialog(
                                        backgroundColor: Colors.black,
                                        insetPadding: EdgeInsets.zero,
                                        child: Stack(
                                          children: [
                                          PageView.builder(
                                           controller: pageController,
                                              itemCount: images.length,
                                              itemBuilder: (context, pageIndex) {
                                                return InteractiveViewer(
                                                  panEnabled: false,
                                                  minScale: 1,
                                                  maxScale: 4,
                                                  child: Center(
                                                    child: Container(
                                                      color: Colors.white,
                                                      child: Image.network(
                                                        images[pageIndex],
                                                        fit: BoxFit.contain,
                                                      ),
                                                    )
                                                  ),
                                                );
                                              },
                                            ),
                                      Positioned(
                                        left: 10,
                                           top: 0,
                                            bottom: 0,
                                              child: Center(
                                               child: IconButton(
                                                icon: const Icon(
                                                  Icons.arrow_back_ios,
                                                    color: Colors.white,
                                                        size: 40,
                                                       ),
                                                         onPressed: () {
                                                         pageController.previousPage(
                                                         duration: const Duration(milliseconds: 300),
                                                        curve: Curves.easeInOut,
                                                      );
                                                    },
                                                   ),
                                                 ),
                                                ),

                                              Positioned(
                                                right: 10,
                                                    top: 0,
                                                    bottom: 0,
                                                       child: Center(
                                                       child: IconButton(
                                                  icon: const Icon(
                                                 Icons.arrow_forward_ios,
                                                color: Colors.white,
                                              size: 40,
                                             ),
                                            onPressed: () {
                                           pageController.nextPage(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                          );
                                         },
                                        ),
                                        ),
                                        ),
                                            Positioned(
                                              top: 40,
                                              right: 20,
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 32,
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Image.network(
                                  images[index],
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "${images.length} Photos",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),
                        if (description.isNotEmpty)
                          Center(
                              child: GestureDetector(
                                onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(name),
                                  content: SingleChildScrollView(
                                    child: Text(description),
                                  ),
                                ),
                              );
                            },

                            child: const Text(
                              "View Details",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                         ),

                        const SizedBox(height: 10),

                        Row(
                          children: [

                            Expanded(
                              child: Text(
                                restaurantName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF0A2540),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            if (serviceType == "Marketplace Product" &&
                                deliveryTime.isNotEmpty)
                              Text(
                                "🚚 $deliveryTime",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
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

                        Row(
                          children: [

                            if (actualDiscount > 0)
                              Text(
                                "₹${menuPrice.toInt()}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 15,
                                ),
                              ),

                            if (actualDiscount > 0)
                              const SizedBox(width: 8),

                            Text(
                              "₹${finalPrice.toInt()}",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
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
                    bool allowCOD = true;

                    try {
                      final paymentDoc =
                      await FirebaseFirestore.instance
                          .collection('app_settings')
                          .doc('payment')
                          .get();

                      final paymentData =
                          paymentDoc.data() ?? {};

                      final globalCOD =
                          paymentData['allowCOD'] ?? true;

                      bool productCOD = true;

                      for (final item in cart.items.values) {

                        final productDoc =
                        await FirebaseFirestore.instance
                            .collection('food_menu')
                            .doc(item.id)
                            .get();

                        final productData =
                            productDoc.data() ?? {};

                        final currentProductCOD =
                            productData['allowCOD'] ?? true;

                        if (!currentProductCOD) {

                          productCOD = false;
                          break;
                        }
                      }

                      allowCOD =
                          globalCOD && productCOD;

                    } catch (e) {
                      debugPrint('COD Config Error: $e');
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

                          allowCOD: allowCOD,

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

        customerLatitude:
        customerLatitude,

        customerLongitude:
        customerLongitude,

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