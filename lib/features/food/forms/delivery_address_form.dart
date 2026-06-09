import 'package:flutter/material.dart';

class DeliveryAddressForm
    extends StatelessWidget {

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

  const DeliveryAddressForm({

    super.key,

    required this.phoneController,
    required this.pincodeController,
    required this.addressController,
    required this.landmarkController,
    required this.noteController,
  });

  @override
  Widget build(BuildContext context) {

    return Column(

      children: [

        TextField(

          controller: phoneController,

          keyboardType:
          TextInputType.phone,

          decoration: InputDecoration(

            labelText:
            "Contact Number",

            hintText:
            "Enter delivery contact number",

            border:
            OutlineInputBorder(

              borderRadius:
              BorderRadius.circular(12),
            ),

            prefixIcon:
            const Icon(Icons.phone),
          ),
        ),

        const SizedBox(height: 12),

        TextField(

          controller:
          pincodeController,

          keyboardType:
          TextInputType.number,

          maxLength: 6,

          decoration: InputDecoration(

            labelText: "Pincode",

            hintText:
            "Enter delivery pincode",

            border:
            OutlineInputBorder(

              borderRadius:
              BorderRadius.circular(12),
            ),

            prefixIcon:
            const Icon(Icons.pin_drop),
          ),
        ),

        const SizedBox(height: 12),

        TextField(

          controller:
          addressController,

          minLines: 3,
          maxLines: 5,

          keyboardType:
          TextInputType.multiline,

          textInputAction:
          TextInputAction.newline,

          decoration: InputDecoration(

            labelText:
            "Delivery Address",

            hintText:
            "Enter complete delivery address",

            border:
            OutlineInputBorder(

              borderRadius:
              BorderRadius.circular(12),
            ),

            prefixIcon:
            const Icon(Icons.location_on),
          ),
        ),

        const SizedBox(height: 12),

        TextField(

          controller:
          landmarkController,

          decoration: InputDecoration(

            labelText: "Landmark",

            hintText:
            "Nearby building / gate / hostel",

            border:
            OutlineInputBorder(

              borderRadius:
              BorderRadius.circular(12),
            ),

            prefixIcon:
            const Icon(Icons.place),
          ),
        ),

        const SizedBox(height: 12),

        TextField(

          controller: noteController,

          decoration: InputDecoration(

            labelText:
            "Delivery Notes",

            hintText:
            "Floor / room / instructions",

            border:
            OutlineInputBorder(

              borderRadius:
              BorderRadius.circular(12),
            ),

            prefixIcon:
            const Icon(Icons.note),
          ),
        ),
      ],
    );
  }
}