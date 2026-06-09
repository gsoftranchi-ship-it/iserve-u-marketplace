import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class DeliveryScannerPage extends StatefulWidget {
  const DeliveryScannerPage({super.key});

  @override
  State<DeliveryScannerPage> createState() =>
      _DeliveryScannerPageState();
}

class _DeliveryScannerPageState
    extends State<DeliveryScannerPage> {

  bool scanned = false;
  final MobileScannerController controller =
  MobileScannerController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(

          "Scan Order QR",

          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor:
        const Color(0xFF0A2540),

        foregroundColor: Colors.white,
      ),

      body: MobileScanner(
        controller: controller,

        onDetect: (capture) async {

          if (scanned) return;

          scanned = true;

          final List<Barcode> barcodes =
              capture.barcodes;

          for (final barcode in barcodes) {

            if (barcode.rawValue == null) {
              continue;
            }

            final String orderId =
            barcode.rawValue!;
            await controller.stop();

            try {

              // ==========================================
              // FETCH ORDER
              // ==========================================

              final orderDoc =
              await FirebaseFirestore.instance
                  .collection('orders')
                  .doc(orderId)
                  .get();

              if (!orderDoc.exists) {

                scanned = false;

                return;
              }

              final orderData =
              orderDoc.data()!;

              final correctPin =
              orderData['deliveryPin']
                  .toString();

              // ==========================================
              // PIN INPUT
              // ==========================================

              final pinController =
              TextEditingController();

              if (!context.mounted) return;

              showDialog(

                context: context,

                barrierDismissible: false,

                builder: (dialogContext) {

                  return AlertDialog(

                    title: const Text(
                      "Verify Delivery PIN",
                    ),

                    content: TextField(

                      controller:
                      pinController,

                      keyboardType:
                      TextInputType.number,

                      decoration:
                      const InputDecoration(

                        hintText:
                        "Enter customer PIN",
                      ),
                    ),

                    actions: [

                      TextButton(

                        onPressed: () {

                          Navigator.pop(
                            dialogContext,
                          );

                          scanned = false;
                        },

                        child: const Text(
                          "Cancel",
                        ),
                      ),

                      ElevatedButton(

                        onPressed: () async {

                          // ==========================
                          // INVALID PIN
                          // ==========================

                          if (pinController.text
                              .trim() !=
                              correctPin) {

                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(

                              const SnackBar(

                                backgroundColor:
                                Colors.red,

                                content: Text(
                                  "Invalid Delivery PIN",
                                ),
                              ),
                            );

                            return;
                          }

                          // ==========================
                          // UPDATE DELIVERY
                          // ==========================

                          await FirebaseFirestore
                              .instance
                              .collection('orders')
                              .doc(orderId)
                              .update({

                            'status':
                            'DELIVERED',

                            'deliveredAt':
                            FieldValue.serverTimestamp(),
                          });

                          if (!context.mounted) {
                            return;
                          }

                          Navigator.pop(
                            dialogContext,
                          );

                          Navigator.pop(context);

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(

                            const SnackBar(

                              backgroundColor:
                              Colors.green,

                              behavior:
                              SnackBarBehavior.floating,

                              content: Text(
                                "Order Delivered Successfully",
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

            } catch (e) {

              debugPrint(
                "Scanner Error: $e",
              );

              scanned = false;
            }
          }
        },
      ),
    );
  }
}