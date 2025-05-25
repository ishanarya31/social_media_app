import 'package:flutter/material.dart';

class BioBox extends StatelessWidget {

  final String bio;
  const BioBox({super.key , required this.bio});

  @override
  Widget build(BuildContext context) {
    return Container(
      //padding inside
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        //color
        color: Theme.of(context).colorScheme.secondary,
      ),

      width: double.infinity,

      child: Text(bio.isNotEmpty ? bio: "Empty Bio..",
        style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary
        ),
      ),
    );
  }
}
