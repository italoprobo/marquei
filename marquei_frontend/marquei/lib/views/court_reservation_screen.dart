import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CourtReservationScreen extends StatefulWidget {
  final int courtId;
  final String courtName;

  const CourtReservationScreen({
    super.key,
    required this.courtId,
    required this.courtName,
  });

  @override
  _CourtReservationScreenState createState() => _CourtReservationScreenState();
}

class _CourtReservationScreenState extends State<CourtReservationScreen> {
  List<DateTime> availableTimes = [];
  List<DateTime> selectedTimes = []; // Lista de horários selecionados
  bool isLoading = true;
  Map<DateTime, bool> reservedTimes = {};

  @override
  void initState() {
    super.initState();
    _generateAvailableTimes();
    _fetchReservedTimes();
  }

  // Gera os horários disponíveis de 16:00 até 00:00
  void _generateAvailableTimes() {
    DateTime now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, now.day, 16, 0);
    DateTime end = DateTime(now.year, now.month, now.day, 0, 0).add(Duration(days: 1));

    for (DateTime time = start; time.isBefore(end); time = time.add(Duration(hours: 1))) {
      availableTimes.add(time);
    }
    setState(() {});
  }

  // Busca os horários reservados no Supabase
  Future<void> _fetchReservedTimes() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('reserva')
        .select('data, hora_inicio, hora_fim')
        .eq('id_quadra', widget.courtId)
        .eq('data', DateTime.now().toIso8601String().substring(0, 10)) // Verifica as reservas de hoje
        .maybeSingle();

    if (response != null) {
      final List reservations = response as List;
      for (var reservation in reservations) {
        DateTime horaInicio = DateTime.parse('${reservation['data']} ${reservation['hora_inicio']}');
        reservedTimes[horaInicio] = true;
      }
    } else {
      print('Nenhuma reserva encontrada para esta quadra.');
    }

    setState(() {
      isLoading = false;
    });
  }

  // Função para confirmar a reserva de múltiplos horários
  Future<void> _confirmReservation() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        for (var time in selectedTimes) {
          final response = await supabase.from('reserva').insert({
            'id_usuario': user.id,
            'id_quadra': widget.courtId,
            'data': time.toIso8601String().substring(0, 10),
            'hora_inicio': time.toIso8601String().substring(11, 19),
            'hora_fim': time.add(Duration(hours: 1)).toIso8601String().substring(11, 19),
            'preco': 50.00, // valor fixo por hora
          });

          if (response.error == null) {
            reservedTimes[time] = true;
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reserva confirmada para ${selectedTimes.length} horário(s)')),
        );
        setState(() {
          selectedTimes.clear(); // Limpa os horários selecionados após a confirmação
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao confirmar reserva: $e')),
        );
      }
    }
  }

  // Função para alternar a seleção de horários
  void _toggleTimeSelection(DateTime time) {
    setState(() {
      if (selectedTimes.contains(time)) {
        selectedTimes.remove(time); // Remove se já estiver selecionado
      } else {
        selectedTimes.add(time); // Adiciona se não estiver selecionado
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservar ${widget.courtName}'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecione um ou mais horários para ${widget.courtName}:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: availableTimes.length,
                      itemBuilder: (context, index) {
                        DateTime time = availableTimes[index];
                        bool isReserved = reservedTimes[time] ?? false;
                        bool isSelected = selectedTimes.contains(time);
                        return GestureDetector(
                          onTap: isReserved
                              ? null
                              : () {
                                  _toggleTimeSelection(time); // Permite a seleção múltipla
                                },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isReserved
                                  ? Colors.grey
                                  : isSelected
                                      ? Colors.blue
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isReserved ? Colors.grey : Colors.blue,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              '${time.hour}:00 - ${time.hour + 1}:00',
                              style: TextStyle(
                                color: isReserved
                                    ? Colors.white
                                    : isSelected
                                        ? Colors.white
                                        : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: selectedTimes.isEmpty
                        ? null
                        : _confirmReservation, // Desabilita o botão se nada estiver selecionado
                    child: Text('Confirmar Reserva (${selectedTimes.length} horário(s))'),
                  ),
                ],
              ),
            ),
    );
  }
}
