import 'package:flutter/material.dart';

class CampaignInfoSection
    extends StatelessWidget {

  final int priority;

  final int duration;

  final int assetCount;

  final int siteCount;

  const CampaignInfoSection({

    super.key,

    required this.priority,

    required this.duration,

    required this.assetCount,

    required this.siteCount,
  });

  @override
  Widget build(BuildContext context) {

    return Wrap(

      spacing: 10,

      runSpacing: 10,

      children: [

        _chip(
          "Assets: $assetCount",
        ),

        _chip(
          "Priority: $priority",
        ),

        _chip(
          "Sites: $siteCount",
        ),

        _chip(
          "Duration: $duration Days",
        ),
      ],
    );
  }

  Widget _chip(
      String text,
      ) {

    return Container(

      padding:
      const EdgeInsets.symmetric(

        horizontal: 12,

        vertical: 8,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(
          20,
        ),

        border: Border.all(

          color:
          Colors.grey.shade300,
        ),
      ),

      child: Text(

        text,

        style: const TextStyle(
          fontSize: 12,
        ),
      ),
    );
  }
}