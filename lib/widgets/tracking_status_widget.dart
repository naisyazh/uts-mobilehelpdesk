import 'package:flutter/material.dart';

class TrackingStatusWidget extends StatelessWidget {
  final String status;

  const TrackingStatusWidget({super.key, required this.status});

  Color getColor() {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Proses":
        return Colors.blue;
      case "Selesai":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: getColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: getColor()),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: getColor(),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}