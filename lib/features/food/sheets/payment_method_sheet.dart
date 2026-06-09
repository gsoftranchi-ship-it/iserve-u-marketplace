import 'package:flutter/material.dart';

class PaymentMethodSheet
    extends StatelessWidget {

  final VoidCallback
  onOnlinePayment;

  final VoidCallback
  onCashOnDelivery;

  const PaymentMethodSheet({

    super.key,

    required this.onOnlinePayment,

    required this.onCashOnDelivery,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(

      padding:
      const EdgeInsets.all(24),

      child: Column(

        mainAxisSize:
        MainAxisSize.min,

        children: [

          const Text(

            "Select Payment Method",

            style: TextStyle(

              fontSize: 20,

              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          SizedBox(

            width: double.infinity,

            height: 55,

            child:
            ElevatedButton.icon(

              style:
              ElevatedButton.styleFrom(

                backgroundColor:
                const Color(
                    0xFF0A2540),

                shape:
                RoundedRectangleBorder(

                  borderRadius:
                  BorderRadius.circular(
                      14),
                ),
              ),

              onPressed:
              onOnlinePayment,

              icon: const Icon(

                Icons.qr_code,

                color: Colors.white,
              ),

              label: const Text(

                "Pay Online",

                style: TextStyle(

                  color: Colors.white,

                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(

            width: double.infinity,

            height: 55,

            child:
            OutlinedButton.icon(

              style:
              OutlinedButton.styleFrom(

                side:
                const BorderSide(
                  color:
                  Colors.orange,
                ),

                shape:
                RoundedRectangleBorder(

                  borderRadius:
                  BorderRadius.circular(
                      14),
                ),
              ),

              onPressed:
              onCashOnDelivery,

              icon: const Icon(

                Icons
                    .payments_outlined,

                color: Colors.orange,
              ),

              label: const Text(

                "Cash on Delivery",

                style: TextStyle(

                  color:
                  Colors.orange,

                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}