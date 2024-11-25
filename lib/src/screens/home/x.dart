import 'package:flutter/material.dart';

class RouteInfoCard extends StatelessWidget {
  final Map<String, dynamic> routeInfo = {
    "route_id": "400874",
    "route_name": "Tungipara, Gopalgonj",
    "total_gate_pass": 1,
    "total_gate_pass_amount": 112335.0,
    "total_customer": 17,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Route Info Card"),
      ),
      body: Center(
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Text(
                  routeInfo["route_name"],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "(${routeInfo["route_id"]})",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const Divider(),
                // Info Rows
                _buildInfoRow(
                  icon: Icons.receipt,
                  label: "Total Gate Passes",
                  value: routeInfo["total_gate_pass"].toString(),
                ),
                _buildInfoRow(
                  icon: Icons.attach_money,
                  label: "Gate Pass Amount",
                  value: routeInfo["total_gate_pass_amount"].toString(),
                ),
                _buildInfoRow(
                  icon: Icons.people,
                  label: "Total Customers",
                  value: routeInfo["total_customer"].toString(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RouteInfoCard(),
  ));
}
