import 'package:flutter/material.dart';

class CourtReservationScreen extends StatelessWidget {
  final int courtId;
  final String courtName;

  const CourtReservationScreen({
    super.key,
    required this.courtId,
    required this.courtName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservar $courtName'),
      ),
      body: Center(
        child: Text('Tela de reserva para $courtName (ID: $courtId)'),
      ),
    );
  }
}
