import 'package:flutter/material.dart';

class OnlinePaymentSheet
    extends StatelessWidget {

  final String qrUrl;

  final String merchant;

  final String upiId;

  final TextEditingController
  transactionController;

  final VoidCallback
  onPaymentSubmit;

  const OnlinePaymentSheet({

    super.key,

    required this.qrUrl,

    required this.merchant,

    required this.upiId,

    required this.transactionController,

    required this.onPaymentSubmit,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(

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

          children: [

            const Text(

              "Online Payment",

              style: TextStyle(

                fontSize: 22,

                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            if (qrUrl
                .toString()
                .isNotEmpty)

              ClipRRect(

                borderRadius:
                BorderRadius.circular(
                  16,
                ),

                child: Image.network(

                  qrUrl,

                  width: 220,
                  height: 220,

                  fit: BoxFit.contain,

                  errorBuilder: (
                      context,
                      error,
                      stackTrace,
                      ) {

                    return Container(

                      width: 220,
                      height: 220,

                      alignment:
                      Alignment.center,

                      decoration:
                      BoxDecoration(

                        color: Colors
                            .grey
                            .shade200,

                        borderRadius:
                        BorderRadius.circular(
                            16),
                      ),

                      child: const Text(
                        "QR Failed To Load",
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            Text(

              merchant,

              style: const TextStyle(

                fontWeight:
                FontWeight.bold,

                fontSize: 18,
              ),
            ),

            const SizedBox(height: 8),

            SelectableText(

              upiId,

              style: TextStyle(

                color:
                Colors.blue.shade900,

                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(

              controller:
              transactionController,

              textCapitalization:
              TextCapitalization
                  .characters,

              keyboardType:
              TextInputType.text,

              textInputAction:
              TextInputAction.done,

              autocorrect: false,

              enableSuggestions:
              false,

              decoration:
              InputDecoration(

                labelText:
                "Transaction ID / UTR Number",

                hintText:
                "Enter payment reference",

                border:
                OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(
                      12),
                ),

                prefixIcon:
                const Icon(
                  Icons.receipt_long,
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(

              width: double.infinity,

              height: 55,

              child: ElevatedButton(

                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  const Color(
                    0xFFFF6A00,
                  ),

                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                  ),
                ),

                onPressed:
                onPaymentSubmit,

                child: const Text(

                  "I HAVE PAID",

                  style: TextStyle(

                    color: Colors.white,

                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}