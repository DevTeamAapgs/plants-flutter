import 'package:flutter/material.dart';

class DataNotAvailable extends StatelessWidget {
  const DataNotAvailable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "No Records Found",
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 20,
          color: Colors.black,
          shadows: [
            Shadow(
              offset: const Offset(2, 2),
              blurRadius: 3,
              color: Colors.white.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }
}
