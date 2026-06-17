import 'package:flutter/material.dart';
import '../services/support_service.dart';
import 'my_tickets_page.dart';
class SupportPage extends StatefulWidget {

  const SupportPage({
    super.key,
  });

  @override
  State<SupportPage> createState() =>
      _SupportPageState();
}

class _SupportPageState
    extends State<SupportPage> {

  final TextEditingController
  _messageController =
  TextEditingController();

  String _category =
      'Order Issue';


  final List<String> _categories = [

    'Order Issue',
    'Payment Issue',
    'Delivery Issue',
    'Restaurant Issue',
    'Technical Issue',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Support Center',
        ),
      ),
      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            SizedBox(

              width: double.infinity,

              child: ElevatedButton.icon(

                onPressed: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                      const MyTicketsPage(),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.list_alt,
                ),

                label: const Text(
                  'My Tickets',
                ),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(

              initialValue: _category,

              decoration:
              const InputDecoration(

                labelText:
                'Category',
              ),

              items: _categories
                  .map(
                    (e) =>
                    DropdownMenuItem(

                      value: e,

                      child: Text(e),
                    ),
              )
                  .toList(),

              onChanged: (value) {

                if (value != null) {

                  setState(() {

                    _category =
                        value;
                  });
                }
              },
            ),

            const SizedBox(
              height: 20,
            ),

            TextField(

              controller:
              _messageController,

              maxLines: 5,

              decoration:
              const InputDecoration(

                labelText:
                'Describe your issue',

                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            SizedBox(

              width:
              double.infinity,

              child:
              ElevatedButton(

                onPressed: () async {

                  final message =
                  _messageController.text.trim();

                  if (message.isEmpty) {

                    ScaffoldMessenger.of(context)
                        .showSnackBar(

                      const SnackBar(
                        content:
                        Text('Please describe the issue'),
                      ),
                    );

                    return;
                  }
                  debugPrint('SUBMIT BUTTON CLICKED');

                  await SupportService()
                      .createTicket(

                    category: _category,

                    message: message,
                  );

                  _messageController.clear();

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context)
                      .showSnackBar(

                    const SnackBar(
                      content:
                      Text('Support ticket submitted'),
                    ),
                  );
                },

                child: const Text(
                  'Submit Ticket',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}