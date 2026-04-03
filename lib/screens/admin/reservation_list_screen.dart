// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../models/reservation_model.dart';
import '../../services/reservation_service.dart';

class ReservationListScreen extends StatelessWidget {
  const ReservationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = ReservationService();

    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: StreamBuilder<List<ReservationModel>>(
                stream: service.getReservations(),
                builder: (context, snapshot) {
                  final reservations = snapshot.data ?? [];

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _infoBox(),
                      const SizedBox(height: 16),

                      ...reservations.map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _reservationCard(context, r, service),
                          )),

                      _buildStats(reservations),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Row(
              children: [
                Icon(Icons.arrow_back, color: Colors.white),
                SizedBox(width: 6),
                Text("Retour", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Gestion des réservations",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Validez et gérez les réservations",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _infoBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F0FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.star, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Les apprenants logés ont la priorité sur les réservations.",
            ),
          ),
        ],
      ),
    );
  }

  Widget _reservationCard(
    BuildContext context,
    ReservationModel r,
    ReservationService service,
  ) {
    Color statusColor;
    String statusText;

    switch (r.status) {
      case "approved":
        statusColor = Colors.green;
        statusText = "Approuvé";
        break;
      case "rejected":
        statusColor = Colors.red;
        statusText = "Rejeté";
        break;
      default:
        statusColor = Colors.orange;
        statusText = "En attente";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  r.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (r.role == "Apprenant logé")
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text("⭐ Logé"),
                ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: statusColor),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Text(r.documentTitle),

          const SizedBox(height: 6),
          Text("Demandé le ${r.date}",
              style: const TextStyle(fontSize: 12)),

          if (r.status == "pending") ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        service.updateStatus(r.id, "approved"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                      foregroundColor: Colors.green,
                    ),
                    child: const Text("Approuver"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        service.updateStatus(r.id, "rejected"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.red,
                    ),
                    child: const Text("Rejeter"),
                  ),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _buildStats(List<ReservationModel> list) {
    final pending = list.where((e) => e.status == "pending").length;
    final approved = list.where((e) => e.status == "approved").length;
    final rejected = list.where((e) => e.status == "rejected").length;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat(pending.toString(), "En attente", Colors.orange),
          _stat(approved.toString(), "Approuvées", Colors.green),
          _stat(rejected.toString(), "Rejetées", Colors.red),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color)),
        Text(label),
      ],
    );
  }
}