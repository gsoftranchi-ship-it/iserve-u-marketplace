import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../screens/food_dining/image_optimizer_service.dart';
import 'package:cached_network_image/cached_network_image.dart';


class MenuManagerPage extends StatefulWidget {
  const MenuManagerPage({super.key});

  @override
  State<MenuManagerPage> createState() => _MenuManagerPageState();
}

class _MenuManagerPageState extends State<MenuManagerPage> {
  static const List<String> marketplaceCategories = [

    "🛒 Daily Needs",
    "💊 Health & Wellness",
    "👗 Fashion & Lifestyle",
    "💄 Beauty",
    "🎉 Festival & Gifts",
    "🏠 Home & Kitchen",
    "📱 Electronics",
    "📚 Education & Office",
    "🚗 Automobile",
    "⚽ Sports & Hobby",
    "🐾 Pets & Agriculture",
    "🎨 Handmade & Local",
    "🏪 Business Supplies",
    "📦 Others",

  ];

  // 🔥 IMAGE PICKER
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),

      appBar: AppBar(
        title: const Text(
          "Store Item Manager",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0A2540),
        foregroundColor: Colors.white,
      ),

      // 🔥 MENU LIST
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('food_menu')
            .where(
          'restaurantId',
          isEqualTo: currentUser.uid,
        )
            .orderBy(
          'createdAt',
          descending: true,
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
                "No menu items available.",
              ),
            );
          }

          final items = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              12,
              12,
              12,
              100,
            ),
            itemCount: items.length,

            itemBuilder: (context, index) {

              var item = items[index];

              String imageUrl =
                  item['image'] ?? '';

              return Card(
                elevation: 3,
                margin:
                const EdgeInsets.only(bottom: 12),

                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(12),

                  child: Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Row(

                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          ClipRRect(

                            borderRadius:
                            BorderRadius.circular(8),

                            child: imageUrl.isNotEmpty

                                ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,

                              placeholder: (context, url) =>
                              const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),

                              errorWidget: (context, url, error) =>
                              const Icon(Icons.image_not_supported),
                            )

                                : Container(
                              width: 70,
                              height: 70,
                              color: Colors.orange[100],

                              child: const Icon(
                                Icons.fastfood,
                                color: Colors.orange,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(

                            child: Column(

                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children: [

                                Text(
                                  item['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  "Category: ${item['category']}",
                                ),

                                Text(
                                  "Food Type: ${item['foodType']}",
                                ),

                                Text(
                                  "Service: ${item['serviceType']}",
                                ),
                                const SizedBox(height: 6),

                                if ((item['description'] ?? '')
                                    .toString()
                                    .isNotEmpty)

                                  Text(

                                    item['description'],

                                    maxLines: 3,

                                    overflow:
                                    TextOverflow.ellipsis,

                                    style: TextStyle(

                                      color: Colors.grey[700],

                                      fontSize: 13,
                                    ),
                                  ),

                                const SizedBox(height: 8),

                                Builder(
                                  builder: (_) {

                                    final data =
                                    item.data()
                                    as Map<String, dynamic>;

                                    final price =
                                    (data['price'] ?? 0)
                                        .toDouble();

                                    final discount =
                                    (data['discountPercent'] ?? 0)
                                        .toDouble();

                                    final finalPrice =
                                        price -
                                            (price * discount / 100);

                                    return Column(

                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                      children: [

                                        if (discount > 0)
                                          Text(

                                            "₹${price.toInt()}",

                                            style: const TextStyle(
                                              decoration:
                                              TextDecoration.lineThrough,
                                              color: Colors.grey,
                                            ),
                                          ),

                                        Text(

                                          "₹${finalPrice.toInt()}",

                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 18,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                        ),

                                        if (discount > 0)

                                          Text(

                                            "${discount.toInt()}% OFF",

                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontWeight:
                                              FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(

                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                        children: [

                          TextButton.icon(

                            onPressed: () {

                              _showEditItemDialog(
                                context,
                                item,
                              );
                            },

                            icon: const Icon(
                              Icons.edit,
                            ),

                            label: const Text(
                              "Edit",
                            ),
                          ),

                          Row(

                            children: [

                              Switch(

                                value:
                                item['available'] ?? true,

                                onChanged: (value) async {

                                  await item.reference.update({

                                    'available': value,
                                  });
                                },
                              ),

                              IconButton(

                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),

                                onPressed: () async {

                                  try {

                                    if (imageUrl.isNotEmpty) {

                                      await FirebaseStorage.instance
                                          .refFromURL(imageUrl)
                                          .delete();
                                    }

                                  } catch (_) {}

                                  await item.reference.delete();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),


      // 🔥 FLOATING BUTTON
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
      FloatingActionButton.extended(
        backgroundColor: Colors.orange,


        onPressed: () =>

            _showAddItemDialog(context),

        icon: const Icon(Icons.add),
        label: const Text("Add Item"),
      ),
    );
  }

  // ======================================================
  // 🔥 ADD ITEM DIALOG
  // ======================================================
  final currentUser =
  FirebaseAuth.instance.currentUser!;

  void _showAddItemDialog(BuildContext context) {

    final TextEditingController nameController =
    TextEditingController();

    final TextEditingController priceController =
    TextEditingController();
    final TextEditingController discountController =
    TextEditingController(
      text: '0',
    );
    final TextEditingController descriptionController =
    TextEditingController();

    String selectedCategory = "Lunch";
    String selectedFoodType = "Veg";
    String selectedServiceType = "Regular";
    String selectedMarketplaceCategory =
        marketplaceCategories.first;
    String selectedDeliveryTime = '1-2 Days';
    String selectedReturnPolicy = 'No Return';

    int selectedReturnDays = 0;

    String selectedReturnCondition = 'Sealed Pack Only';
    final deliveryTimeOptions = [
      '30 Minutes',
      '1 Hour',
      '2 Hours',
      'Same Day',
      '1-2 Days',
      '3-5 Days',
      '7 Days',
    ];
    XFile? pickedImage;
    XFile? pickedImage2;
    XFile? pickedImage3;

    bool isUploading = false;

    showDialog(
      context: context,

      builder: (context) {

        return StatefulBuilder(
          builder: (context, setStateDialog) {

            // 🔥 PICK IMAGE
            Future<void> pickImage() async {

              final image =
              await _picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 75,
              );

              if (image != null) {
                setStateDialog(() {
                  pickedImage = image;
                });
              }
            }

            // 🔥 SAVE ITEM
            Future<void> saveItem() async {

              if (nameController.text.isEmpty ||
                  priceController.text.isEmpty) {

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content:
                    Text("Please fill all fields"),
                  ),
                );

                return;
              }
              final price = double.tryParse(
                priceController.text.trim(),
              );

              if (price == null || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Please enter valid price",
                    ),
                  ),
                );
                return;
              }

              setStateDialog(() {
                isUploading = true;
              });

              try {

                String imageUrl = "";
                String imageUrl2 = "";
                String imageUrl3 = "";

                // ==================================================
                // 🔥 UPLOAD IMAGE
                // ==================================================

                if (pickedImage != null) {

                  String fileName =
                  DateTime.now()
                      .millisecondsSinceEpoch
                      .toString();

                  Reference storageRef =
                  FirebaseStorage.instance
                      .ref()
                      .child(
                    'food_images/$fileName.jpg',
                  );

                  // ✅ WEB SUPPORT
                  if (kIsWeb) {

                    Uint8List bytes =
                    await pickedImage!.readAsBytes();

                    await storageRef.putData(

                      bytes,

                      SettableMetadata(
                        contentType: 'image/jpeg',
                      ),
                    );

                  } else {

                    final optimizedFile =
                    await ImageOptimizerService
                        .convertToStandardWebP(
                      File(pickedImage!.path),
                    );

                    if (optimizedFile != null) {
                      await storageRef.putFile(
                        optimizedFile,
                        SettableMetadata(
                          contentType: 'image/jpeg',
                        ),
                      );
                    }
                  }
                  imageUrl =
                  await storageRef
                      .getDownloadURL();
                }
                // IMAGE 2
                if (pickedImage2 != null) {

                  String fileName =
                      "${DateTime.now().millisecondsSinceEpoch}_2";

                  Reference storageRef =
                  FirebaseStorage.instance
                      .ref()
                      .child(
                    'food_images/$fileName.jpg',
                  );

                  if (kIsWeb) {

                    Uint8List bytes =
                    await pickedImage2!.readAsBytes();

                    await storageRef.putData(
                      bytes,
                      SettableMetadata(
                        contentType: 'image/jpg',
                      ),
                    );

                  } else {

                    final optimizedFile =
                    await ImageOptimizerService
                        .convertToStandardWebP(
                      File(pickedImage2!.path),
                    );

                    if (optimizedFile != null) {
                      await storageRef.putFile(
                        optimizedFile,
                        SettableMetadata(
                          contentType: 'image/jpeg',
                        ),
                      );
                    }
                  }

                  imageUrl2 =
                  await storageRef.getDownloadURL();
                }

// IMAGE 3
                if (pickedImage3 != null) {

                  String fileName =
                      "${DateTime.now().millisecondsSinceEpoch}_3";

                  Reference storageRef =
                  FirebaseStorage.instance
                      .ref()
                      .child(
                    'food_images/$fileName.jpg',
                  );

                  if (kIsWeb) {

                    Uint8List bytes =
                    await pickedImage3!.readAsBytes();

                    await storageRef.putData(
                      bytes,
                      SettableMetadata(
                        contentType: 'image/jpeg',
                      ),
                    );

                  } else {

                    final optimizedFile =
                    await ImageOptimizerService
                        .convertToStandardWebP(
                      File(pickedImage3!.path),
                    );

                    if (optimizedFile != null) {
                      await storageRef.putFile(
                        optimizedFile,
                        SettableMetadata(
                          contentType: 'image/jpeg',
                        ),
                      );
                    }
                  }

                  imageUrl3 =
                  await storageRef.getDownloadURL();
                }
                final profileDoc =
                await FirebaseFirestore.instance
                    .collection('profiles')
                    .doc(currentUser.uid)
                    .get();

                final profileData =
                    profileDoc.data() ?? {};

                final restaurantName =
                    profileData['name'] ??
                        profileData['restaurantName'] ??
                        'Restaurant';

                // ==================================================
                // 🔥 SAVE TO FIRESTORE
                // ==================================================

                await FirebaseFirestore.instance
                    .collection('food_menu')
                    .add({

                  "restaurantId": currentUser.uid,

                  "restaurantName": restaurantName,

                  "restaurantActive": true,

                  "name": nameController.text.trim(),

                  "description":
                  descriptionController.text.trim(),

                  "price": price,

                  "discountPercent": int.tryParse(
                    discountController.text.trim(),
                  ) ?? 0,

                  "category": selectedServiceType == "Marketplace Product"
                      ? selectedMarketplaceCategory
                      : selectedCategory,

                  "foodType": selectedFoodType,

                  "serviceType": selectedServiceType,

                  "deliveryTime":
                  selectedServiceType == "Marketplace Product"
                      ? selectedDeliveryTime
                      : "",
                  "returnPolicy": selectedReturnPolicy,

                  "returnDays": selectedReturnDays,

                  "returnCondition": selectedReturnCondition,

                  "available": true,

                  "allowCOD": true,

                  "image": imageUrl,
                  "image2": imageUrl2,
                  "image3": imageUrl3,

                  "createdAt":
                  FieldValue.serverTimestamp(),
                });

                if (context.mounted) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Menu item added successfully!",
                      ),
                    ),
                  );
                }

              } catch (e) {

                setStateDialog(() {
                  isUploading = false;
                });

                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      "Error: $e",
                    ),
                  ),
                );
              }
            }

            // ==================================================
            // 🔥 DIALOG UI
            // ==================================================

            return AlertDialog(
              contentPadding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(16),
              ),

              title: const Text(
                "Add New Item",
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [

                    // ✅ IMAGE PICKER
                    GestureDetector(
                      onTap: pickImage,

                      child: Container(
                        height: 140,
                        width: 140,

                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius:
                          BorderRadius.circular(
                            12,
                          ),
                        ),

                        child: pickedImage != null

                        // ✅ WEB SUPPORT
                            ? kIsWeb
                            ? FutureBuilder<
                            Uint8List>(
                          future:
                          pickedImage!
                              .readAsBytes(),

                          builder: (
                              context,
                              snapshot,
                              ) {

                            if (!snapshot
                                .hasData) {

                              return const Center(
                                child:
                                CircularProgressIndicator(),
                              );
                            }

                            return ClipRRect(
                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),

                              child: Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        )

                        // ✅ MOBILE SUPPORT
                            : ClipRRect(
                          borderRadius:
                          BorderRadius.circular(
                            12,
                          ),

                          child: Image.file(
                            File(
                              pickedImage!
                                  .path,
                            ),

                            fit: BoxFit.cover,
                          ),
                        )

                        // ✅ PLACEHOLDER
                            : const Column(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 45,
                              color: Colors.grey,
                            ),

                            SizedBox(height: 8),

                            Text(
                              "Add Item Photo",
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (selectedServiceType == "Marketplace Product") ...[

                      const SizedBox(height: 12),

                      Row(
                        children: [

                          Expanded(
                            child: _buildMarketplaceImageBox(
                              "Image 2",
                              pickedImage2,
                                  () async {

                                final image =
                                await _picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 75,
                                );

                                if (image != null) {
                                  setStateDialog(() {
                                    pickedImage2 = image;
                                  });
                                }
                              },
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _buildMarketplaceImageBox(
                              "Image 3",
                              pickedImage3,
                                  () async {

                                final image =
                                await _picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 75,
                                );

                                if (image != null) {
                                  setStateDialog(() {
                                    pickedImage3 = image;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 20),

                    // ✅ NAME
                    TextField(
                      controller: nameController,

                      maxLines: 2,

                      minLines: 1,

                      decoration: const InputDecoration(
                        labelText: "Item Name",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ✅ PRICE
                    TextField(
                      controller: priceController,

                      keyboardType:
                      TextInputType.number,

                      decoration:
                      const InputDecoration(
                        labelText: "Price (₹)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextField(

                      controller: discountController,

                      keyboardType: TextInputType.number,

                      decoration: const InputDecoration(
                        labelText: "Discount (%)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextField(

                      controller:
                      descriptionController,

                      maxLines: 3,

                      decoration:
                      const InputDecoration(

                        labelText:
                        "Menu Description",

                        hintText:
                        "2 Roti, Dal Fry, Rice, Salad",

                        border:
                        OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ✅ CATEGORY
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                        initialValue: selectedCategory,

                      decoration:
                      const InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(),
                      ),

                      items: [
                        "Breakfast",
                        "Lunch",
                        "Dinner",
                        "Snacks",
                        "Juices",
                        "Beverages",
                        "Desserts",
                        "Tiffin",
                        "iServe-U Marketplace",


                      ]
                          .map(
                            (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ),
                      )
                          .toList(),

                        onChanged: (value) {
                          setStateDialog(() {

                            if (selectedServiceType == "Marketplace Product") {
                              selectedMarketplaceCategory = value!;
                            } else {
                              selectedCategory = value!;
                            }

                          });
                        }
                    ),

                    if (selectedServiceType == "Marketplace Product") ...[

                      const SizedBox(height: 15),

                      DropdownButtonFormField<String>(
                        isExpanded: true,

                        initialValue: selectedMarketplaceCategory,

                        decoration: const InputDecoration(
                          labelText: "Marketplace Category",
                          border: OutlineInputBorder(),
                        ),

                        items: marketplaceCategories.map((e) {

                          return DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          );

                        }).toList(),

                        onChanged: (value) {

                          setStateDialog(() {

                            selectedMarketplaceCategory = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 15),

                      DropdownButtonFormField<String>(
                        initialValue: selectedDeliveryTime,

                        decoration: const InputDecoration(
                          labelText: "Delivery Time",
                          border: OutlineInputBorder(),
                        ),

                        items: deliveryTimeOptions.map((e) {

                          return DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          );

                        }).toList(),

                        onChanged: (value) {

                          setStateDialog(() {

                            selectedDeliveryTime =
                                value ?? '1-2 Days';
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        initialValue: selectedReturnPolicy,
                        decoration: const InputDecoration(
                          labelText: "Return Policy",
                          border: OutlineInputBorder(),
                        ),
                        items: const [

                          DropdownMenuItem(
                            value: "No Return",
                            child: Text("No Return"),
                          ),

                          DropdownMenuItem(
                            value: "Replacement Only",
                            child: Text("Replacement Only"),
                          ),

                          DropdownMenuItem(
                            value: "Return & Refund",
                            child: Text("Return & Refund"),
                          ),

                        ],
                        onChanged: (value) {

                          setStateDialog(() {

                            selectedReturnPolicy = value!;

                          });

                        },
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<int>(
                        initialValue: selectedReturnDays,
                        decoration: const InputDecoration(
                          labelText: "Return Window",
                          border: OutlineInputBorder(),
                        ),
                        items: const [

                          DropdownMenuItem(
                            value: 0,
                            child: Text("0 Days"),
                          ),

                          DropdownMenuItem(
                            value: 3,
                            child: Text("3 Days"),
                          ),

                          DropdownMenuItem(
                            value: 7,
                            child: Text("7 Days"),
                          ),

                          DropdownMenuItem(
                            value: 10,
                            child: Text("10 Days"),
                          ),

                          DropdownMenuItem(
                            value: 15,
                            child: Text("15 Days"),
                          ),

                          DropdownMenuItem(
                            value: 30,
                            child: Text("30 Days"),
                          ),

                        ],
                        onChanged: (value) {

                          setStateDialog(() {

                            selectedReturnDays = value!;

                          });

                        },
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        initialValue: selectedReturnCondition,
                        decoration: const InputDecoration(
                          labelText: "Return Condition",
                          border: OutlineInputBorder(),
                        ),
                        items: const [

                          DropdownMenuItem(
                            value: "Sealed Pack Only",
                            child: Text("Sealed Pack Only"),
                          ),

                          DropdownMenuItem(
                            value: "Unused Only",
                            child: Text("Unused Only"),
                          ),

                          DropdownMenuItem(
                            value: "Original Packaging Required",
                            child: Text("Original Packaging Required"),
                          ),

                          DropdownMenuItem(
                            value: "Any Condition",
                            child: Text("Any Condition"),
                          ),

                        ],
                        onChanged: (value) {

                          setStateDialog(() {

                            selectedReturnCondition = value!;

                          });

                        },
                      ),

                      const SizedBox(height: 12),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),


                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.shade200,
                          ),
                        ),

                        child: const Row(
                          children: [

                            Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.orange,
                            ),

                            SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                "Marketplace products support multiple images and zoom view.",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: selectedFoodType,

                      decoration: const InputDecoration(
                        labelText: "Food Type",
                        border: OutlineInputBorder(),
                      ),

                      items: const [

                        DropdownMenuItem(
                          value: "Veg",
                          child: Text("Veg"),
                        ),

                        DropdownMenuItem(
                          value: "Non Veg",
                          child: Text("Non Veg"),
                        ),

                        DropdownMenuItem(
                          value: "Product",
                          child: Text("Product"),
                        ),
                      ],

                      onChanged: (value) {

                        setStateDialog(() {

                          selectedFoodType = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: selectedServiceType,

                      decoration: const InputDecoration(
                        labelText: "Service Type",
                        border: OutlineInputBorder(),
                      ),

                      items: const [

                        DropdownMenuItem(
                          value: "Regular",
                          child: Text("Regular Food"),
                        ),

                        DropdownMenuItem(
                          value: "Weekly Tiffin",
                          child: Text("Weekly Tiffin"),
                        ),

                        DropdownMenuItem(
                          value: "Monthly Tiffin",
                          child: Text("Monthly Tiffin"),
                        ),

                        DropdownMenuItem(
                          value: "Marketplace Product",
                          child: Text(
                            "Marketplace",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],

                      onChanged: (value) {

                        setStateDialog(() {

                          selectedServiceType = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // ✅ ACTION BUTTONS
              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text("Cancel"),
                ),

                isUploading

                    ? const Padding(
                  padding: EdgeInsets.all(10),
                  child:
                  CircularProgressIndicator(),
                )

                    : ElevatedButton.icon(

                  onPressed: saveItem,

                  icon: const Icon(Icons.save),

                  label: const Text(
                    "Save Item",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditItemDialog(
      BuildContext context,
      QueryDocumentSnapshot item,
      ) {

    final nameController =
    TextEditingController(
      text: item['name'],
    );

    final priceController =
    TextEditingController(
      text: item['price'].toString(),
    );
    final discountController =
    TextEditingController(
      text:
      (item['discountPercent'] ?? 0)
          .toString(),
    );

    final descriptionController =
    TextEditingController(
      text: item['description'] ?? '',
    );

    String selectedCategory =
        item['category'] ?? 'Lunch';

    String selectedMarketplaceCategory =
    marketplaceCategories.contains(item['category'])
        ? item['category']
        : marketplaceCategories.first;

    if (item['serviceType'] == "Marketplace Product" &&
        !marketplaceCategories.contains(item['category'])) {
      selectedMarketplaceCategory =
          marketplaceCategories.first;
    }


    String selectedFoodType =
        item['foodType'] ?? 'Veg';

    String selectedServiceType =
        item['serviceType'] ?? 'Regular';

    String selectedDeliveryTime =
        item['deliveryTime'] ?? '1-2 Days';
    String selectedReturnPolicy =
        item['returnPolicy'] ?? 'No Return';

    int selectedReturnDays =
        item['returnDays'] ?? 0;

    String selectedReturnCondition =
        item['returnCondition'] ??
            'Sealed Pack Only';

    showDialog(
      context: context,
      builder: (_) {

        return AlertDialog(
          contentPadding: const EdgeInsets.all(16),

          title: const Text(
            "Edit Menu Item",
          ),

          content: StatefulBuilder(
            builder: (context, setStateDialog) {

              return SingleChildScrollView(

                child: Column(

                  mainAxisSize: MainAxisSize.min,

                  children: [

                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Item Name",
                      ),
                    ),

                    TextField(

                      controller: descriptionController,

                      minLines: 3,

                      maxLines: 3,

                      keyboardType:
                      TextInputType.multiline,

                      decoration: const InputDecoration(

                        labelText:
                        "Menu Description",

                        border:
                        OutlineInputBorder(),

                        alignLabelWithHint: true,
                      ),
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      isExpanded: true,

                      initialValue:
                      selectedServiceType == "Marketplace Product"
                          ? selectedMarketplaceCategory
                          : selectedCategory,

                      decoration:
                      const InputDecoration(
                        labelText: "Category",
                      ),

                      items: (selectedServiceType == "Marketplace Product"
                          ? marketplaceCategories
                          : [
                        "Breakfast",
                        "Lunch",
                        "Dinner",
                        "Snacks",
                        "Juices",
                        "Beverages",
                        "Desserts",
                        "Tiffin",
                        "iServe-U Marketplace",
                      ])
                          .map(
                            (e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {

                        setStateDialog(() {

                          if (selectedServiceType == "Marketplace Product") {

                            selectedMarketplaceCategory = value!;

                          } else {

                            selectedCategory = value!;
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(

                      initialValue:
                      selectedFoodType,

                      decoration:
                      const InputDecoration(
                        labelText:
                        "Food Type",
                      ),

                      items: const [

                        DropdownMenuItem(
                          value: "Veg",
                          child: Text("Veg"),
                        ),

                        DropdownMenuItem(
                          value: "Non Veg",
                          child: Text("Non Veg"),
                        ),

                        DropdownMenuItem(
                          value: "Product",
                          child: Text("Product"),
                        ),
                      ],

                      onChanged: (value) {

                        setStateDialog(() {

                          selectedFoodType =
                          value!;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(

                      initialValue:
                      selectedServiceType,
                      decoration:
                      const InputDecoration(
                        labelText:
                        "Service Type",
                      ),

                      items: const [

                        DropdownMenuItem(
                          value: "Regular",
                          child: Text("Regular Food"),
                        ),

                        DropdownMenuItem(
                          value: "Weekly Tiffin",
                          child: Text("Weekly Tiffin"),
                        ),

                        DropdownMenuItem(
                          value: "Monthly Tiffin",
                          child: Text("Monthly Tiffin"),
                        ),

                        DropdownMenuItem(
                          value: "Marketplace Product",
                          child: Text(
                            "Marketplace",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],

                      onChanged: (value) {

                        setStateDialog(() {

                          selectedServiceType =
                          value!;
                        });
                      },
                    ),
                    if (selectedServiceType == "Marketplace Product") ...[

                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(

                        initialValue: selectedDeliveryTime,

                        decoration: const InputDecoration(
                          labelText: "Delivery Time",
                        ),

                        items: const [

                          DropdownMenuItem(
                            value: "30 Minutes",
                            child: Text("30 Minutes"),
                          ),

                          DropdownMenuItem(
                            value: "1 Hour",
                            child: Text("1 Hour"),
                          ),

                          DropdownMenuItem(
                            value: "2 Hours",
                            child: Text("2 Hours"),
                          ),

                          DropdownMenuItem(
                            value: "Same Day",
                            child: Text("Same Day"),
                          ),

                          DropdownMenuItem(
                            value: "1-2 Days",
                            child: Text("1-2 Days"),
                          ),

                          DropdownMenuItem(
                            value: "3-5 Days",
                            child: Text("3-5 Days"),
                          ),

                          DropdownMenuItem(
                            value: "7 Days",
                            child: Text("7 Days"),
                          ),
                        ],

                        onChanged: (value) {

                          setStateDialog(() {

                            selectedDeliveryTime =
                            value!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(

                        initialValue: selectedReturnPolicy,

                        decoration: const InputDecoration(
                          labelText: "Return Policy",
                        ),

                        items: const [

                          DropdownMenuItem(
                            value: "No Return",
                            child: Text("No Return"),
                          ),

                          DropdownMenuItem(
                            value: "Replacement Only",
                            child: Text("Replacement Only"),
                          ),

                          DropdownMenuItem(
                            value: "Return & Refund",
                            child: Text("Return & Refund"),
                          ),

                        ],

                        onChanged: (value) {

                          setStateDialog(() {

                            selectedReturnPolicy = value!;

                          });

                        },
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<int>(

                        initialValue: selectedReturnDays,

                        decoration: const InputDecoration(
                          labelText: "Return Window",
                        ),

                        items: const [

                          DropdownMenuItem(
                            value: 0,
                            child: Text("0 Days"),
                          ),

                          DropdownMenuItem(
                            value: 3,
                            child: Text("3 Days"),
                          ),

                          DropdownMenuItem(
                            value: 7,
                            child: Text("7 Days"),
                          ),

                          DropdownMenuItem(
                            value: 10,
                            child: Text("10 Days"),
                          ),

                          DropdownMenuItem(
                            value: 15,
                            child: Text("15 Days"),
                          ),

                          DropdownMenuItem(
                            value: 30,
                            child: Text("30 Days"),
                          ),

                        ],

                        onChanged: (value) {

                          setStateDialog(() {

                            selectedReturnDays = value!;

                          });

                        },
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(

                        initialValue: selectedReturnCondition,

                        decoration: const InputDecoration(
                          labelText: "Return Condition",
                        ),

                        items: const [

                          DropdownMenuItem(
                            value: "Sealed Pack Only",
                            child: Text("Sealed Pack Only"),
                          ),

                          DropdownMenuItem(
                            value: "Unused Only",
                            child: Text("Unused Only"),
                          ),

                          DropdownMenuItem(
                            value: "Original Packaging Required",
                            child: Text("Original Packaging Required"),
                          ),

                          DropdownMenuItem(
                            value: "Any Condition",
                            child: Text("Any Condition"),
                          ),

                        ],

                        onChanged: (value) {

                          setStateDialog(() {

                            selectedReturnCondition = value!;

                          });

                        },
                      ),
                    ],

                    const SizedBox(height: 12),

                    TextField(

                      controller:
                      priceController,

                      keyboardType:
                      TextInputType.number,

                      decoration:
                      const InputDecoration(
                        labelText:
                        "Price",
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(

                      controller: discountController,

                      keyboardType: TextInputType.number,

                      decoration: const InputDecoration(
                        labelText: "Discount (%)",
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          actions: [

            TextButton(

              onPressed: () {
                Navigator.pop(
                  context,
                );
              },

              child:
              const Text(
                "Cancel",
              ),
            ),

            ElevatedButton(

              onPressed: () async {
                final price = double.tryParse(
                  priceController.text.trim(),
                );

                if (price == null || price <= 0) {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Enter valid price",
                      ),
                    ),
                  );

                  return;
                }

                await item.reference.update({

                  'name':
                  nameController.text.trim(),

                  'description':
                  descriptionController.text.trim(),

                  'category':
                  selectedServiceType == "Marketplace Product"
                      ? selectedMarketplaceCategory
                      : selectedCategory,

                  'foodType':
                  selectedFoodType,

                  'serviceType':
                  selectedServiceType,

                  'deliveryTime':
                  selectedServiceType == "Marketplace Product"
                      ? selectedDeliveryTime
                      : '',
                  'returnPolicy':
                  selectedReturnPolicy,

                  'returnDays':
                  selectedReturnDays,

                  'returnCondition':
                  selectedReturnCondition,

                  'price': price,

                  'discountPercent':
                  int.tryParse(
                    discountController.text.trim(),
                  ) ?? 0,
                });

                if (context.mounted) {

                  Navigator.pop(
                    context,
                  );
                }
              },

              child:
              const Text(
                "Save",
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMarketplaceImageBox(
      String title,
      XFile? image,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        height: 90,

        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius:
          BorderRadius.circular(10),
        ),

        child: image == null

            ? Center(
          child: Text(title),
        )

            : ClipRRect(
          borderRadius:
          BorderRadius.circular(10),

          child: kIsWeb

              ? FutureBuilder<Uint8List>(
            future:
            image.readAsBytes(),

            builder:
                (context, snapshot) {

              if (!snapshot.hasData) {
                return const Center(
                  child:
                  CircularProgressIndicator(),
                );
              }

              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
              );
            },
          )

              : Image.file(
            File(image.path),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

