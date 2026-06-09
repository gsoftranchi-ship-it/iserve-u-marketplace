import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
class MenuManagerPage extends StatefulWidget {
  const MenuManagerPage({super.key});

  @override
  State<MenuManagerPage> createState() => _MenuManagerPageState();
}

class _MenuManagerPageState extends State<MenuManagerPage> {

  // 🔥 IMAGE PICKER
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),

      appBar: AppBar(
        title: const Text(
          "Restaurant Menu Manager",
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

                                ? Image.network(
                              imageUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
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
        label: const Text("Add Food Item"),
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
    XFile? pickedImage;

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

              setStateDialog(() {
                isUploading = true;
              });

              try {

                String imageUrl = "";

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

                    await storageRef.putFile(

                      File(pickedImage!.path),

                      SettableMetadata(
                        contentType: 'image/jpeg',
                      ),
                    );
                  }
                  imageUrl =
                  await storageRef
                      .getDownloadURL();
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

                  "price": double.parse(
                    priceController.text.trim(),
                  ),
                  "discountPercent": int.tryParse(
                    discountController.text.trim(),
                  ) ?? 0,

                  "category": selectedCategory,

                  "foodType": selectedFoodType,

                  "serviceType": selectedServiceType,

                  "available": true,

                  "image": imageUrl,

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
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(16),
              ),

              title: const Text(
                "Add New Menu Item",
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
                              "Add Food Photo",
                            ),
                          ],
                        ),
                      ),
                    ),

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
                        "Tiffin"
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
                          selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(

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
                      ],

                      onChanged: (value) {

                        setStateDialog(() {

                          selectedFoodType = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(

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

    String selectedFoodType =
        item['foodType'] ?? 'Veg';

    String selectedServiceType =
        item['serviceType'] ?? 'Regular';

    showDialog(
      context: context,
      builder: (_) {

        return AlertDialog(

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

                      decoration:
                      const InputDecoration(
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

                      initialValue:
                      selectedCategory,

                      decoration:
                      const InputDecoration(
                        labelText: "Category",
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

                      ].map((e) {

                        return DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        );

                      }).toList(),

                      onChanged: (value) {

                        setStateDialog(() {

                          selectedCategory =
                          value!;
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
                          child: Text(
                            "Regular Food",
                          ),
                        ),

                        DropdownMenuItem(
                          value: "Weekly Tiffin",
                          child: Text(
                            "Weekly Tiffin",
                          ),
                        ),

                        DropdownMenuItem(
                          value: "Monthly Tiffin",
                          child: Text(
                            "Monthly Tiffin",
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

                await item.reference.update({

                  'name':
                  nameController.text.trim(),

                  'description':
                  descriptionController.text.trim(),

                  'category':
                  selectedCategory,

                  'foodType':
                  selectedFoodType,

                  'serviceType':
                  selectedServiceType,

                  'price':
                  double.parse(
                    priceController.text.trim(),
                  ),
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
}

