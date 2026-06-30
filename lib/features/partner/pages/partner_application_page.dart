import 'package:flutter/material.dart';

import '../services/partner_service.dart';

class PartnerApplicationPage extends StatefulWidget {
  const PartnerApplicationPage({
    super.key,
  });

  @override
  State<PartnerApplicationPage>
  createState() =>
      _PartnerApplicationPageState();
}

class _PartnerApplicationPageState
    extends State<PartnerApplicationPage> {

  final PartnerService
  _partnerService =
  PartnerService();

  bool _loading = false;

  Future<void> _submitApplication(
      String type) async {

    try {

      setState(() {
        _loading = true;
      });

      await _partnerService
          .submitApplication(

        applicationType: type,
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          backgroundColor:
          Colors.green,

          content: Text(

            'Application submitted successfully.',
          ),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Join iServe-U Partner Network',
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(

          padding:
          const EdgeInsets.all(20),

          child: Column(

          children: [

            const SizedBox(
              height: 20,
            ),

            const Icon(

              Icons.handshake,

              size: 80,
              color: Colors.orange,
            ),

            const SizedBox(
              height: 20,
            ),

            const Text(

              'Join Our Partner Network',

              textAlign: TextAlign.center,

              style: TextStyle(

                fontSize: 22,

                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            const Text(

              'This section is for individuals and businesses who want to work with iServe-U.\n\nChoose your partnership category below and submit your application. Our team will review your application and contact you after approval.',

              textAlign: TextAlign.center,

              style: TextStyle(

                color: Colors.black54,

                fontSize: 14,
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            Container(

              width: double.infinity,

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color: Colors.orange.shade50,

                borderRadius:
                BorderRadius.circular(12),
              ),

              child: const Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(

                    'Who should apply?',

                    style: TextStyle(

                      fontWeight:
                      FontWeight.bold,

                      fontSize: 16,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    '🚴 Deliver orders and earn with iServe-U.',
                  ),

                  SizedBox(height: 8),

                  Text(
                    ' List your business, receive orders and grow your business with iServe-U.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),


            SizedBox(

              width: double.infinity,

              height: 60,

              child: ElevatedButton.icon(

                onPressed:
                _loading
                    ? null
                    : () {

                  _submitApplication(
                    'delivery_partner',
                  );
                },

                icon: const Icon(
                  Icons.delivery_dining,
                ),

                label: const Text(
                  'Apply as Delivery Partner',
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            SizedBox(

              width: double.infinity,

              height: 60,

              child: ElevatedButton.icon(

                onPressed:
                _loading
                    ? null
                    : () {

                  _submitApplication(
                    'restaurant_partner',
                  );
                },

                icon: const Icon(
                  Icons.storefront,
                ),

                label: const Text(
                  'Apply as Provider',
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}