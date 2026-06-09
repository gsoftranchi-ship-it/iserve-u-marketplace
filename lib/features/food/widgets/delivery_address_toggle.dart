import 'package:flutter/material.dart';

class DeliveryAddressToggle
    extends StatelessWidget {

  final bool useDefaultAddress;

  final ValueChanged<bool> onChanged;

  const DeliveryAddressToggle({

    super.key,

    required this.useDefaultAddress,

    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      margin: const EdgeInsets.only(
        bottom: 16,
      ),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(

        color: Colors.orange.shade50,

        borderRadius:
        BorderRadius.circular(12),
      ),

      child: SwitchListTile(

        contentPadding:
        EdgeInsets.zero,

        value: useDefaultAddress,

        title: const Text(

          "Use Default Profile Address",

          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),

        subtitle: Text(

          useDefaultAddress

              ? "Delivery details will be loaded from your profile."

              : "Enter a different delivery address.",
        ),

        onChanged: onChanged,
      ),
    );
  }
}