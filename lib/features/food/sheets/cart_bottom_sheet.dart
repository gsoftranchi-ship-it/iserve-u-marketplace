import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../forms/delivery_address_form.dart';
import '../../../screens/food_dining/food_services.dart';

class CartBottomSheet
    extends StatelessWidget {

  final FoodService cart;

  final BuildContext
  cartSheetContext;

  final TextEditingController
  phoneController;

  final TextEditingController
  pincodeController;

  final TextEditingController
  addressController;

  final TextEditingController
  landmarkController;

  final TextEditingController
  noteController;



  const CartBottomSheet({

    super.key,

    required this.cart,

    required this.cartSheetContext,

    required this.phoneController,

    required this.pincodeController,

    required this.addressController,

    required this.landmarkController,

    required this.noteController,


  });

  @override
  Widget build(BuildContext context) {

    return Consumer<FoodService>(

      builder: (context, cart, child) => Container(

        constraints: BoxConstraints(

          maxHeight:
          MediaQuery.of(context)
              .size
              .height * 0.85,
        ),

        decoration:
        const BoxDecoration(

          color: Colors.white,

          borderRadius:
          BorderRadius.vertical(

            top: Radius.circular(25),
          ),
        ),

        padding: EdgeInsets.only(

          left: 24,
          right: 24,
          top: 24,

          bottom:
          MediaQuery.of(context)
              .viewInsets
              .bottom + 24,
        ),

        child: SingleChildScrollView(

          keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior
              .onDrag,

          child: Column(

            mainAxisSize:
            MainAxisSize.min,

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              Row(

                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

                children: [

                  Text(

                    "Cart Summary (${cart.totalItems})",

                    style:
                    const TextStyle(

                      fontSize: 20,

                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),

                  IconButton(

                    onPressed: () =>
                        Navigator.pop(
                            context),

                    icon: const Icon(
                        Icons.close),
                  ),
                ],
              ),

              const Divider(),

              SizedBox(

                height: 180,

                child: cart.items.isEmpty

                    ? const Center(

                  child: Text(
                    "Your cart is empty",
                  ),
                )

                    : ListView.builder(

                  itemCount:
                  cart.items.length,

                  itemBuilder:
                      (context, i) {

                    var item =
                    cart.items.values
                        .toList()[i];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [

                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    "₹${item.price}",
                                    style: const TextStyle(
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.orange,
                              ),
                              onPressed: () {
                                cart.decrementQuantity(item.id);
                              },
                            ),

                            Text(
                              "${item.quantity}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            IconButton(
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                cart.addToCart(
                                  item.id,
                                  item.name,
                                  item.price,
                                  item.restaurantId,
                                  item.restaurantName,
                                );
                              },
                            ),

                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () {

                                while (
                                cart.items.containsKey(item.id)
                                ) {
                                  cart.decrementQuantity(
                                    item.id,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(

                width: double.infinity,

                padding: const EdgeInsets.all(12),

                margin: const EdgeInsets.only(
                  top: 12,
                  bottom: 12,
                ),

                decoration: BoxDecoration(

                  color: Colors.orange.shade50,

                  borderRadius:
                  BorderRadius.circular(12),
                ),

                child: const Row(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Icon(
                      Icons.location_on,
                      color: Colors.orange,
                    ),

                    SizedBox(width: 10),

                    Expanded(

                      child: Text(

                        'Your profile address has been loaded automatically. You may edit these details if this order is for a different delivery location.',

                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              DeliveryAddressForm(

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

              const SizedBox(height: 16),

              const Divider(),

              Padding(

                padding:
                const EdgeInsets.symmetric(
                  vertical: 20,
                ),

                child: Row(

                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

                  children: [

                    const Text(

                      "Total Amount",

                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    Text(

                      "₹${cart.totalAmount.toStringAsFixed(2)}",

                      style:
                      const TextStyle(

                        fontSize: 22,

                        fontWeight:
                        FontWeight.w900,

                        color:
                        Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}